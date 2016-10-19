### load required libraries ###
library(plyr)
library(dplyr)
library(lubridate)
library(stringr)
library(tidyr)
library(RSocrata)
library(ggplot2)
library(acs)

### set up the environment ###
options(stringsAsFactors = FALSE)                # change the default for stringsAsFactors to a more intuitive behavior
violationsPath <- "output/violations_data.rdf"   # the path where the processed violation data is stored
geoAddPath <- "output/geo_addresses.rdf"         # location of the geocoded address file in R data format

### load library scripts containing utility functions ###
source('R/library/violations_general.R', echo=FALSE)
source('R/library/geocoded_addresses.R', echo=FALSE)
source('R/library/block_group.R', echo=FALSE)
source('R/library/census.R', echo=FALSE)
source('R/library/alteryx.R', echo=FALSE)
source('R/library/addresses.R', echo=FALSE)
source('R/library/leaflet_example.R', echo=FALSE)
source('R/library/open_addresses.R', echo=FALSE)
source('R/library/ordinance_chapters.R', echo=FALSE)
source('R/library/ordinance_titles.R', echo=FALSE)

### process the data ###

# load the violations data from the rdf file if we have it, otherwise from the open data site
if(file.exists(violationsPath)) {
  print('loading cached local copy of violation data')
  load(violationsPath)
} else {
  print('loading latest violations data from Socrata')
  rawViolations <- read.socrata("https://data.kcmo.org/Housing/Property-Violations/nhtf-e75a")  
  save(rawViolations, file = violationsPath)
}

# prepare violations data - scrub bad data, filter, add more columns
violations <- rawViolations %>% 
  convertViolationDates() %>% 
  topChapters() %>% 
  scrubBadData()