# Reads the geocoded address file
#    includeOnlyKeyAndGeoid - if true, return only the KIVA.PIN and GEO_ID columns;
#       otherwise, return all columns in the file
readAddresses <- function( includeOnlyKeyAndGeoid = TRUE ) {
  # Reads the geocoded address file
  #
  #  Args:
  #    includeOnlyKeyAndGeoid: if true, return only the KIVA.PIN and GEO_ID columns.
  #    Otherwise, return all columns.
  
  if(file.exists(geoAddPath)) {
    load(geoAddPath)
  } else {
    # read in the code violations data from a csv file
    columnClasses = c(
      #Kiva.Pin
      "integer",
      #County.APN
      "character",
      #Address.Number
      "character",
      #Street
      "character",
      #Street.Type
      "character",
      #Combined.Full.Address
      "character",
      #City
      "character",
      #State
      "character",
      #Longitude
      "double",
      #Latitude
      "double",
      #AFFGEOID
      "character",
      #GEOID
      "character"
    )
    
    addresses <- read.csv("data/address_blockgroup_master.csv", colClasses = columnClasses)
    # clean up temporary objects
    rm(columnClasses)
    
    # match the casing of the violations dataset
    names(addresses)[names(addresses) == 'Kiva.Pin'] <- 'KIVA.PIN'
    
    # save as an RDF file for faster future loading
    save(addresses, file = geoAddPath)
  }
  
  # return only the KIVA.PIN and GEOID if requested
  if(includeOnlyKeyAndGeoid) {
    addresses <- addresses %>% select(KIVA.PIN, GEOID) 
  }
  addresses
}

addBlockGroupToViolations <- function(d) {
  # Adds a GEOID column (representing the census block group) to the violations dataset
  #
  #  Args:
  #    d: A violations data frame
  #
  # Note:    
  #    GEOID is a geographic identifier describing the area to which census data applies.
  #    In our case, the GEOID is a single 12 character field that contains fixed positions for 
  #    the state, county, tract and block group. Example:
  #       290950080002 -> State: 29, County: 095, Tract: 008000, Block Group: 2
  #    More information available here: https://www.census.gov/geo/reference/geoidentifiers.html
  
  # pulls a list of KIVA.PINs with associated GEOIDs from a master address file
  addresses <- readAddresses()
  
  # eliminate duplicate KIVA.PIN entries, which can result when there are multiple doors for an address (e.g., duplex)
  addresses <- unique(addresses)
  
  # join on KIVA.PIN, which best represents a single address or property
  left_join(d, addresses, by = 'KIVA.PIN')
}

