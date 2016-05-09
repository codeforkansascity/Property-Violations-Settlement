displayAcsColumns <- function(acsData) {
  # Displays the ACS columns returned with a census (acs) object
  #
  #  Args:
  #    acsData: An acs object returned by a fetch using the acs package
  #
  #  Returns:
  #    A vector of acs estimate columns
  
  attr(acsData, 'acs.colnames')
}

fetchCensusData <- function(tableNumber, geo = getKcGeo()) {
  # Fetch the census data for the provided table number and area
  #
  #  Args:
  #    tableNumber: The "number" (actually alphanumeric) of the census table to fetch
  #    geo : The geographical area for which to obtain data (defaults to getKcGeo())
  #
  #  Returns:
  #    The acs object containing the data for the table number within the provided
  #    geographical area. The data will be for the 5 years ending in 2014.
  
  acs.fetch(geography = geo, table.number = tableNumber, endyear = "2014", col.names = "pretty" )
}

getKcGeo <- function() {
  # Gets a geographical definition that includes, but is broader than, Kansas City. It includes
  # all tracts and block groups in Cass, Clay, Jackson and Platte counties.
  #
  #  Returns:
  #    A definition of the geographical area including KC that can be used in census data retrievals.
  
  geo.make(state="MO", county=c("Cass", "Clay", "Jackson", "Platte"), tract="*", block.group="*")  
}

convertToBlockGroupDataFrame <- function(acsData) {
  # Converts the estimates in an acs object returned by fetching census data into a data frame.
  # The data is assumed to be at the block group level.
  #
  #  Args:
  #    tableNumber: The "number" (actually alphanumeric) of the census table to fetch
  #    geo : The geographical area for which to obtain data (defaults to getKcGeo())
  #
  #  Returns:
  #    A data frame with a "BG.GEOID" column and all estimates in the supplied data frame.
  
  d <- data.frame(paste0(str_pad(acsData@geography$state, 2, "left", pad="0"),
                    str_pad(acsData@geography$county, 3, "left", pad="0"),
                    str_pad(acsData@geography$tract, 6, "left", pad="0"),
                    str_pad(acsData@geography$blockgroup, 1, "left", pad="0")),
             acsData@estimate[,],
             stringsAsFactors = FALSE)
  names(d)[1] <- "BG.GEOID"
  d
}

lookupCensusTable <- function(nameSearch) {
  # Looks up census tables based on the supplied search and displays the results in an RStudio
  # View.
  #
  #  Args:
  #    nameSearch: The search term to use in the lookup
  #
  #  Returns:
  #    Search results in tabular format
  
  l <- acs.lookup(table.name = nameSearch, endyear = 2014, case.sensitive = FALSE)
  View(l@results)
}

getCensusTableAsDataframe <- function(tableNumber, geo) {
  # Both fetches census data and converts the estimates into a data frame.
  # Assumes data at the block group level.
  #
  #  Args:
  #    d: An acs object returned by a fetch using the acs package
  #
  #  Returns:
  #    A vector of acs estimate columns
  
  t <- fetchCensusData(tableNumber, geo) 
  convertToBlockGroupDataFrame(t)
}
