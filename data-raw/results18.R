## code to prepare `results18` dataset goes here

# save archived results ---------------------------------------------------

# Midterm election results via ABC and 538
# Used in https://53eig.ht/2PiFb0f
# Published: 2018-12-04 at 17:56
# Archived:  2018-04-04 at 16:08

# Midterm election results via ABC and 538
# Used in https://53eig.ht/2PiFb0f
# Published: 2018-12-04 at 17:56
# Archived:  2018-04-04 at 16:08
write_memento(
  url = paste(
    "https://raw.githubusercontent.com/fivethirtyeight/data/master",
    "forecast-review",
    "forecast_results_2018.csv",
    sep = "/"
  ),
  date = "2019-04-04",
  dir = here("data-raw", "results")
)

forecast_results <- read_csv(
  file = here::here("data-raw", "results", "forecast_results_2018.csv"),
  col_types  = cols(
    cycle = col_integer(),
    Democrat_Won = col_logical(),
    Republican_Won = col_logical(),
    uncalled = col_logical(),
    forecastdate = col_date(format = "%m/%d/%y"),
    category = col_factor(
      ordered = TRUE,
      levels = c(
        "Solid D",
        "Likely D",
        "Lean D",
        "Tossup (Tilt D)",
        "Tossup (Tilt R)",
        "Lean R",
        "Likely R",
        "Safe R"
      )
    )
  )
)

# format election results -------------------------------------------------

## source:    https://fivethirtyeight.com/
## input:     input/forecast_results_2018.csv
## desc:      final predictions and election results
## use:       assess the accuracy of both predictive methods

results18 <- forecast_results %>%
  filter(
    branch != "Governor",
    version == "classic",
    uncalled == FALSE
  ) %>%
  separate(
    col = race,
    into = c("state", "district"),
    sep = "-"
  ) %>%
  rename(winner = Democrat_Won) %>%
  mutate(
    district = str_pad(district, width = 2,  pad   = "0"),
    category = fct_recode(
      .f = category,
      "Tilt D" = "Tossup (Tilt D)",
      "Tilt R" = "Tossup (Tilt R)"
      "Like D" = "Likely D"
      "Like R" = "Likely R"
    )
  ) %>%
  unite(
    state, district,
    col = race,
    sep = "-"
  ) %>%
  select(year = cycle, race, category, winner)


# add partisan lean -------------------------------------------------------

# Average difference between how a district votes and the country
# Updated:  2018-11-19 at 16:13
# Archived: 2018-04-04 at 16:05
write_memento(
  date = "2019-04-04",
  dir = here("data-raw", "results"),
  url = paste(
    "https://raw.githubusercontent.com/fivethirtyeight/data/master",
    "partisan-lean",
    "fivethirtyeight_partisan_lean_DISTRICTS.csv",
    sep = "/"
  )
)

partisan_lean_DISTRICTS <- read_csv(
  file = here("data-raw", "results", "fivethirtyeight_partisan_lean_DISTRICTS.csv"),
  col_types = cols(
    district = col_character(),
    pvi_538 = col_character()
  )
)

write_memento(
  date = "2019-04-04",
  dir = here("data-raw", "results"),
  url = paste(
    "https://raw.githubusercontent.com/fivethirtyeight/data/master",
    "partisan-lean",
    "fivethirtyeight_partisan_lean_STATES.csv",
    sep = "/"
  )
)

partisan_lean_STATES <- read_csv(
  file = here("data-raw", "results", "fivethirtyeight_partisan_lean_STATES.csv"),
  col_types = cols(
    state = col_character(),
    pvi_538 = col_character()
  )
)

# Separate lean value and replace state name with state abbreviation
lean_states <- partisan_lean_STATES %>%
  separate(
    col = pvi_538,
    into = c("party", "lean"),
    sep = "\\+",
    convert = TRUE
  ) %>%
  rename(race = state) %>%
  mutate(race = paste(state.abb, "S1", sep = "-"))

# Seperate lean value and pad district number for race code
lean_district <- partisan_lean_DISTRICTS %>%
  separate(
    col = pvi_538,
    into = c("party", "lean"),
    sep = "\\+",
    convert = TRUE
  ) %>%
  separate(
    col = district,
    into = c("state", "race"),
    sep = "\\-"
  ) %>%
  mutate(race = str_pad(race, width = 2, pad = "0")) %>%
  unite(
    col = race,
    state, race,
    sep = "-"
  )

# Turn single number into negative-positive spectrum
lean18 <-
  bind_rows(lean_states, lean_district) %>%
  mutate(
    lean = case_when(
      party == "D" ~ lean * -1,
      party == "R" ~ lean
    )
  )

results18 <- left_join(
  x = results18,
  y = lean18,
  by = "race"
)

results18 <- relocate(results18, lean, .before = category)

# export results ----------------------------------------------------------

write_tsv(results18, here("data-raw", "results18.tsv"))
usethis::use_data(results18, overwrite = TRUE)
