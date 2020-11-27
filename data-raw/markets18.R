## code to prepare `markets18` dataset goes here

library(stringr)
library(readr)
library(dplyr)
library(tidyr)
library(here)

# read market data from https://www.predictit.org/ ------------------------

## Market Data sent by will.jennings@predictit.org
## Detailed price history provided to academic researchers
DailyMarketData <- read_delim(
  file = here("data-raw", "markets", "DailyMarketData.csv"),
  delim = "|",
  na = "n/a",
  col_types = cols(
    MarketId = col_character(),
    ContractName = col_character(),
    ContractSymbol = col_character(),
    Date = col_date(format = "")
  )
)

Market_ME02 <- read_csv(
  file = here("data-raw", "markets", "Market_ME02.csv"),
  col_types = cols(
    ContractID = col_character(),
    Date = col_date(format = "%m/%d/%Y")
  )
)

Contract_NY27 <- read_csv(
  file = here("data-raw", "markets", "Contract_NY27.csv"),
  na = c("n/a", "NA"),
  skip = 156, # this file was a mess
  col_types = cols(
    ContractID = col_character(),
    Date = col_date(format = "%m/%d/%Y")
  )
)

# format markets history ------------------------------------------------------

## source:    https://predictit.org/
## input:     data/raw/models/DailyMarketData.csv
## desc:      history of contract prices for midterm election markets
## use:       operationalize probabalistic forecasts from prediction markets

markets18 <- DailyMarketData %>%
  rename(
    mid    = MarketId,
    name   = MarketName,
    symbol = MarketSymbol,
    party  = ContractName,
    open   = OpenPrice,
    close  = ClosePrice,
    high   = HighPrice,
    low    = LowPrice,
    volume = Volume,
    date   = Date
  ) %>%
  select(date, everything()) %>%
  select(-ContractSymbol)

# get candidate names from full market question
markets18$name[str_which(markets18$name, "Which party will")] <- NA
markets18$name <- word(markets18$name, start = 2, end = 3)

# recode party variables
markets18$party <- recode(
  .x = markets18$party,
  "Democratic or DFL" = "D",
  "Democratic" = "D",
  "Republican" = "R"
)

# remove year information from symbol strings
markets18 <- markets18 %>%
  mutate(
    race = symbol %>%
      str_remove("\\.\\d{2,4}$") %>% # year
      str_remove("(.*)\\.") %>% # names
      str_replace("(?<=[:upper:])SE(.*)$", "S1") %>% # senate
      str_replace("AL", "01") %>% # at large
      str_remove("((?<=\\d))G") %>% # general?
      str_replace("99$", "S2"), # special election
    race = case_when(
      name == "SPEC" ~ "MSS2",
      mid == "3857" ~ "CAS1",
      TRUE ~ race
    ),
    name = case_when(
      name == "PARTY" ~ NA_character_,
      name == "SPEC" ~ NA_character_,
      TRUE ~ name
    ),
    race = race %>%
      str_replace(
        pattern = "([:alpha:]{2})(S\\d|\\d{2})",
        replacement = "\\1-\\2"
      )
  ) %>%
  select(-symbol) %>%
  # remove markets incorectly repeated
  # some not running for re-election
  filter(
    mid != "3455", # Paul Ryan
    mid != "3507", # Jeff Flake
    mid != "3539", # Shea-Porter
    mid != "3521", # Darrell Issa
    mid != "3522", # Repeat of 4825
    mid != "4177", # Repeat of 4232
    mid != "4824"  # Repeat of 4776
  )

# divide the data based on market question syntax
# market questions provided name or party, never both
markets_with_name <- markets18 %>%
  filter(is.na(party)) %>%
  select(-party)

markets_with_party <- markets18 %>%
  filter(is.na(name)) %>%
  select(-name)

# join with members key to add party, then back with rest of market
markets18 <- markets_with_name %>%
  inner_join(members115, by = c("name", "race")) %>%
  select(date, mid, race, party, open, low, high, close, volume) %>%
  bind_rows(markets_with_party)

# add in ME-02 and NY-27 which were left out of initial data
ny_27 <- Contract_NY27 %>%
  rename_all(str_to_lower) %>%
  slice(6:154) %>%
  mutate(
    mid = "4729",
    race = "NY-27",
    party = "R"
  ) %>%
  select(-average)

me_02 <- Market_ME02 %>%
  rename_all(str_to_lower) %>%
  rename(party = longname) %>%
  filter(date != "2018-10-10") %>%
  mutate(mid = "4945", race = "ME-02")

markets_extra <-
  bind_rows(ny_27, me_02) %>%
  select(date, mid, race, party, open, low, high, close, volume)

markets_extra$party[str_which(markets_extra$party, "GOP")] <- "R"
markets_extra$party[str_which(markets_extra$party, "Dem")] <- "D"

# bind with ME-02 and NY-27
markets18 <- bind_rows(markets18, markets_extra)

# export market data ------------------------------------------------------

write_tsv(markets18, here("data-raw", "markets18.tsv"))
usethis::use_data(markets18, overwrite = TRUE)
