## code to prepare `model18` dataset goes here

library(stringr)
library(readr)
library(dplyr)
library(tidyr)
library(here)

# read model and results data from https://fivethirtyeight.com ------------

## District level 538 House model history
## Updated:  2018-11-06 at 01:56
## Archived: 2018-11-06 at 12:06
write_memento(
  url = "https://projects.fivethirtyeight.com/congress-model-2018/house_district_forecast.csv",
  date = "2018-11-06",
  dir = here("data-raw", "models")
)

house_district_forecast <- read_csv(
  file = here("data-raw", "models", "house_district_forecast.csv"),
  col_types = cols(
    forecastdate = col_date(),
    state = col_character(),
    district = col_double(),
    special = col_logical(),
    candidate = col_character(),
    party = col_character(),
    incumbent = col_logical(),
    model = col_character(),
    win_probability = col_double(),
    voteshare = col_double(),
    p10_voteshare = col_double(),
    p90_voteshare = col_double()
  )
)

## Seat level 538 Senate model history
## Updated:  2018-11-06 at 11:06
## Archived: 2018-11-06 at 21:00
write_memento(
  url = "https://projects.fivethirtyeight.com/congress-model-2018/senate_seat_forecast.csv",
  date = "2018-11-06",
  dir = here("data-raw", "models")
)

senate_seat_forecast <- read_csv(
  file = here("data-raw", "models", "senate_seat_forecast.csv"),
  col_types = cols(
    forecastdate = col_date(),
    state = col_character(),
    class = col_double(),
    special = col_logical(),
    candidate = col_character(),
    party = col_character(),
    incumbent = col_logical(),
    model = col_character(),
    win_probability = col_double(),
    voteshare = col_double(),
    p10_voteshare = col_double(),
    p90_voteshare = col_double()
  )
)

# format model history ----------------------------------------------------

## source:    https://fivethirtyeight.com/
## input:     input/*_forecast.csv
## desc:      history of forecasting model top line probabilities
## use:       operationalize probabilistic forecasts from a forecasting model

# format district for race variable
model_district <- house_district_forecast %>%
  mutate(
    district = str_pad(
      string = district,
      width = 2,
      side = "left",
      pad = "0"
    )
  )

# format class for race variable
model_seat <- senate_seat_forecast %>%
  rename(district = class) %>%
  mutate(
    district = str_pad(
      string = district,
      width = 2,
      side = "left",
      pad = "S"
    )
  )

model_combined <-
  bind_rows(model_district, model_seat, .id = "chamber") %>%
  # create race variable for relational join
  unite(
    col = race,
    state, district,
    sep = "-",
    remove = TRUE
  ) %>%
  rename(
    name = candidate,
    date = forecastdate,
    prob = win_probability,
    min_share = p10_voteshare,
    max_share = p90_voteshare
  ) %>%
  mutate(
    chamber = recode(
      .x = chamber,
      "1" = "house",
      "2" = "senate"
    ),
    # only special elections are for senate.
    special = case_when(
      is.na(special) ~ FALSE,
      !is.na(special) ~ special
    ),
    # both caucus with Democrats
    party = case_when(
      name == "Bernard Sanders" ~ "D",
      name == "Angus S. King Jr." ~ "D",
      party == "LIB" ~ "L",
      party == "IND" ~ "I",
      party == "GRE" ~ "G",
      TRUE ~ party
    )
  ) %>%
  mutate(across(prob, round, digits = 4)) %>%
  # convert percent vote share values to decimal
  mutate(across(10:12, ~round(. * 0.01, digits = 4))) %>%
  # keep only named candidates
  filter(name != "Others", name != "Zak Ringelstein") %>%
  # reorder data frame
  select(date, race, name, party, chamber, everything()) %>%
  arrange(date, name)

# separate model data by model format
model_combined <- model_combined %>%
  group_split(model) %>%
  set_names(c("classic", "lite", "deluxe")) %>%
  map(select, -model)

# according to 538, the "classic" model can be used as a default
model18 <- model_combined$classic

# export model data -------------------------------------------------------

write_tsv(model18, here("data-raw", "model18.tsv"))
usethis::use_data(model18, overwrite = TRUE)
