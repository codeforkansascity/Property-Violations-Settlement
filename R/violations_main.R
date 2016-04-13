### load required libraries ###
library(dplyr)
library(lubridate)
library(stringr)
library(tidyr)
library(RSocrata)

### set up the environment ###
options(stringsAsFactors = FALSE)                # change the default for stringsAsFactors to a more intuitive behavior
violationsPath <- "output/violations_data.rdf"   # the path where the processed violation data is stored
geoAddPath <- "output/geo_addresses.rdf"         # location of the geocoded address file in R data format

### load scripts ###
source('R/violations_general.R', echo=FALSE)
source('R/geocoded_addresses.R', echo=FALSE)
source('R/block_group.R', echo=FALSE)

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