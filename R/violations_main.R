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

### load main scripts ###
source('R/violations_general.R', echo=FALSE)
source('R/geocoded_addresses.R', echo=FALSE)
source('R/block_group.R', echo=FALSE)
source('R/census.R', echo=FALSE)
### load utility scripts ###
source('R/addresses.R', echo=FALSE)
source('R/leaflet_example.R', echo=FALSE)
source('R/open_addresses.R', echo=FALSE)
source('R/ordinance_chapters.R', echo=FALSE)
source('R/ordinance_titles.R', echo=FALSE)

### process the data ###

# load the violations data from the rdf file if we have it, otherwise from the open data site
if(file.exists(violationsPath)) {
  load(violationsPath)
} else {
  rawViolations <- read.socrata("https://data.kcmo.org/Housing/Property-Violations/nhtf-e75a")  
  save(rawViolations, file = violationsPath)
}

# prepare violations data - scrub bad data, filter, add more columns
violations <- rawViolations %>% 
  convertViolationDates() %>% 
  scrubBadData() %>% 
  addBlockGroupToViolations() %>% 
  removeRowsWithoutBlockGroups() # TODO: potentially remove if data is fixed

# reshape the violations data to join with census data
violationsByCensusArea <- violations %>% blockGroupSummarize()