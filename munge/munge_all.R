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
#' Builds the data by purging everything in the cache folder and rebuild all
#' 
#' 
#' 
#' NOTES
#' 
#' 
#' 
#'
#'
#' TODO
#' 
#'
#' 
#' 


library(here)

# remove everything in the cache folder

file_list <- list.files(here("cache"), full.names = TRUE)
file.remove(file_list)



# build data
source(here("munge/create_fips_tables.R"))




# cleanup environment
rm("file_list")

