## code to prepare `members18` dataset goes here

library(stringr)
library(readr)
library(dplyr)
library(tidyr)
library(here)

# save the archived raw data ----------------------------------------------

## Current members of the 115th
## Archived: 2018-10-22 at 18:11
write_memento(
  url = "https://theunitedstates.io/congress-legislators/legislators-current.csv",
  date = "2018-10-22",
  dir = here("data-raw", "members")
)

legislators_current <- read_csv(
  file = here("data-raw", "members", "legislators-current.csv"),
  col_types = cols(
    birthday = col_date(),
    govtrack_id = col_character()
  )
)

# The ideology and leadership scores of the 115th
# Calculated with cosponsorship analysis
# Archived 2019-01-21 17:13:08
write_memento(
  url = "https://www.govtrack.us/data/analysis/by-congress/115/sponsorshipanalysis_h.txt",
  date = "2019-03-23",
  dir = here("data-raw", "members")
)

sponsorshipanalysis_h <- read_csv(
  file = here("data-raw", "members", "sponsorshipanalysis_h.txt"),
  col_types = cols(
    ID = col_character()
  )
)

write_memento(
  url = "https://www.govtrack.us/data/analysis/by-congress/115/sponsorshipanalysis_s.txt",
  date = "2019-03-23",
  dir = here("data-raw", "members")
)

sponsorshipanalysis_s <- read_csv(
  file = here("data-raw", "members", "sponsorshipanalysis_s.txt"),
  col_types = cols(
    ID = col_character()
  )
)

# format member data ------------------------------------------------------

## source:    https://theunitedstates.io/
## input:     data/raw/members/legislators_current.csv
## desc:      members of the 115th Congress w/ bio and pol info
## use:       supplement prediction history and contextualize election results

members115 <- legislators_current %>%
  unite(
    # create single name
    first_name, last_name,
    col = name,
    sep = " "
  ) %>%
  rename(
    gid     = govtrack_id,
    chamber = type,
    class   = senate_class,
    birth   = birthday
  ) %>%
  select(
    name,
    gid,
    birth,
    state,
    district,
    class,
    party,
    gender,
    chamber
  ) %>%
  arrange(
    chamber
  )

# recode, encode, and pad
members115 <- members115 %>%
  mutate(
    # fix names to match 538
    name = name %>%
      iconv(to = "ASCII//TRANSLIT") %>%
      str_replace_all("Robert Menendez", "Bob Menendez") %>%
      str_replace_all("Robert Casey",    "Bob Casey") %>%
      str_replace_all("Bernard Sanders", "Bernie Sanders"),
    chamber = recode(chamber, "rep" = "house", "sen" = "senate"),
    district = str_pad(district, width = 2, pad = "0"),
    class = str_pad(class, width = 2, pad = "S"),
    party = recode(
      .x = party,
      "Democrat" = "D",
      "Independent" = "D",
      "Republican" = "R"
    ),
    district = if_else(
      condition = is.na(district),
      true = class,
      false = district
    )
  ) %>%
  # create district code as relational key
  unite(
    col = race,
    state, district,
    sep = "-",
    remove = TRUE
  ) %>%
  select(-class) %>%
  arrange(name)

# format member stats for join
members_stats <-
  bind_rows(
    sponsorshipanalysis_h,
    sponsorshipanalysis_s,
    .id = "chamber"
  ) %>%
  select(
    ID,
    chamber,
    party,
    ideology,
    leadership
  ) %>%
  rename(gid = ID) %>%
  mutate(
    gid = as.character(gid),
    chamber = recode(chamber, "1" = "house", "2" = "senate"),
    party = recode(
      .x = party,
      "Democrat" = "D",
      "Independent" = "D",
      "Republican" = "R"
    )
  )

# add stats to frame by GovTrack ID
members115 <- inner_join(
  x = members115,
  y = members_stats,
  by = c("gid", "party", "chamber")
)

# export member data ------------------------------------------------------

write_tsv(members115, here("data-raw", "members115.tsv"))
usethis::use_data(members115, overwrite = TRUE)
