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
    )
  ) %>%
  unite(
    state, district,
    col = race,
    sep = "-"
  ) %>%
  select(year = cycle, race, category, winner)

# export results ----------------------------------------------------------

write_tsv(results18, here("data-raw", "results18.tsv"))
usethis::use_data(results18, overwrite = TRUE)
