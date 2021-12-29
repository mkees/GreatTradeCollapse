#' CREDENTIALS
#' 
#' Maurice Kees
#' maurice.kees@gmail.com
#' Started on Dec 29, 2021
#'
#'
#'
#'
#' SCRIPT DESCRIPTION
#' 
#' This script prepares the fips classification as used by the US Govt so that state, region and division names can be translated to fips codes
#'
#' It creates the following tables:
#' - states
#' - regions
#' - divisions
#'
#' using 
#'  "state-geocodes-v2015.xls"
#'  "state-geocodes-additional-territories.xls"
#'
#' NOTES
#' 
#' 
#' 
#'
#'
#' TODO
#' 
#' this should be a GENERAL script on its own... for future use
#' 
#' 


# CONFIG ------------------------------------------------------------------


# libraries
library(here)
library(tidyverse)
library(readxl)
library(janitor)

# input files
input_states      <- here("data/state-geocodes-v2015.xls")
input_more_states <- here("data/state-geocodes-additional-territories.xls")

# output files
output_states     <- here("cache/fips_states.rds")
output_divisions  <- here("cache/fips_divisions.rds")
output_regions    <- here("cache/fips_regions.rds")




# CREATE FIPS TABLES ------------------------------------------------------



# create proper state conversion table

states <- read_excel(input_states, skip = 5)
states <- clean_names(states)


# pull out regions
regions <- states %>% 
  filter(str_detect(name, "Region"))

# pull out divisions
divisions <- states %>% 
  filter(str_detect(name, "Division"))

# remove division and region entries
states <- states %>% 
  filter(state_fips != "00")




# cleanup regions
regions <- regions %>% 
  select(region, name) %>% 
  rename(region_id   = region,
         region_name = name)


# cleanup divisions
divisions <- divisions %>% 
  select(division, name, region) %>% 
  rename(division_id   = division,
         division_name = name,
         region_id     = region)


# cleanup states
states <- states %>% 
  select(state_fips, name, region, division) %>% 
  rename(state_name  = name,
         region_id   = region,
         division_id = division) %>% 
  arrange(state_fips)




# add other states/areas often mentioned (Puerto Rico, Virgin Islands...)

more_states <- read_excel(input_more_states)
more_states <- clean_names(more_states)

more_states <- more_states %>% 
  select(fips, state) %>% 
  mutate(fips       = as.character(fips)) %>% 
  rename(state_fips = fips,
         state_name = state)

states <- bind_rows(states, more_states)


# add an entry for "unknown" state
row_to_add <- tibble(state_fips  = "99",
                     state_name  = "Unknown",
                     region_id   = "99",
                     division_id = "99")


states <- states %>% 
  bind_rows(row_to_add)




# OUTPUT ------------------------------------------------------------------

# write tables to inspect
# write_csv(states,    here("cache/tbl_states.csv"))
# write_csv(divisions, here("cache/tbl_divisions.csv"))
# write_csv(regions,   here("cache/tbl_regions.csv"))

# save to cache folder
saveRDS(states,    output_states)
saveRDS(divisions, output_divisions)
saveRDS(regions,   output_regions)


# cleanup environment
rm("divisions", "more_states", "regions", "states", "row_to_add",
   "input_states", "input_more_states",
   "output_divisions", "output_regions", "output_states")

