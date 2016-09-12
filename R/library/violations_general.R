cleanOrdinanceNumber <- function(d) {
  # Strips unnecessary suffix from Ordinance.Number
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A modified violations data frame
  
  d$Ordinance.Number <- gsub(" C.O.", "", d$Ordinance.Number)
  
  d
}

convertViolationDates <- function(d) {
  # Converts date columns to the POSIXct date format
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A modified violations data frame
  
  d$Case.Opened.Date = mdy(d$Case.Opened.Date)
  d$Case.Closed.Date = mdy(d$Case.Closed.Date)
  # RSocrata pulls this date in the unsupported POSIXlt format
  d$Violation.Entry.Date = as.POSIXct(d$Violation.Entry.Date)
  
  d
}

extractViolationCoordinates <- function(d) {
  # Extracts the latitude and longitude from the Code.Violation.Location column
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A modified violations data frame
  
  regCoordinates <-
    gregexpr("(?<=\\()[^\\)]*(?=\\))",
             d$Code.Violation.Location,
             perl = TRUE)
  coordinates <-
    regmatches(d$Code.Violation.Location, regCoordinates)
  d$Latitude <-
    as.numeric(str_split_fixed(coordinates, ", ", 2)[, 1])
  d$Longitude <-
    as.numeric(str_split_fixed(coordinates, ", ", 2)[, 2])
  # clean up by removing temporary objects
  rm(regCoordinates)
  rm(coordinates)
  
  head(d$Latitude)
  
  d
}

addOrdinanceTitles <- function(d) {
  # Adds an ordinance title column (ord # with descriptive text) to the violations data
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A modified violations data frame
  
  # read KC Ordinance Titles
  ordinanceTitles <- read.csv("data/ordinanceTitles.csv", stringsAsFactors = FALSE)
  d <- d %>%
    cleanOrdinanceNumber() %>% 
    left_join(ordinanceTitles, by = 'Ordinance.Number')
  
  # clean up by removing the temporary dataset
  rm(ordinanceTitles)
  
  # default to ordinance number for ordinances without a title
  d$Ordinance.Title <-
    ifelse(
      is.na(d$Ordinance.Title),
      d$Ordinance.Number,
      d$Ordinance.Title
    )
  
  d
}

scrubBadData <- function(d) {
  # Scrubs rows with:
  #  * empty character fields
  #  * NA values (except the Case.Closed.Date, which is NA for open cases)
  #  * 0 case ids
  #
  #  Args:
  #    d: A violations data frame
  # 
  #  Returns:
  #    A modified violations data frame
  
  # filter out rows with missing data in any column
  errors <- 0
  for(colName in names(d)) {
    colClass <- class(d[,colName])
    if(colClass[1] == 'character') {
      errors <- nrow(d %>% filter(d[,colName] == ''))
      if(errors > 0) {
        print(sprintf("Scrubbing %d rows with empty values in %s column", errors, colName))
        d <- d %>% filter(d[,colName] != '')
      }
    } else if(colName[1] != 'Case.Closed.Date') {
      errors <- nrow(d %>% filter(is.na(d[,colName])))
      if(errors > 0) {
        print(sprintf("Scrubbing %d rows with NA values in %s column", errors, colName))
        d <- d %>% filter(!is.na(d[,colName]))
      }
    }
  }
  
  # filter out 0 case ids
  errors <- nrow(d %>% filter(Case.ID == 0))
  print(sprintf("Scrubbing %d rows with 0s in Case.ID", errors))
  d <- d %>% filter(Case.ID != 0)
}

addTotalViolationsForCaseColumn <- function(d) {
  # Adds a column to the violations data frame providing a count of total
  # violations in the case of which the violation is a part
  #
  #  Args:
  #    d: A violations data frame
  #    useKivaPin: if TRUE, uses the KIVA PIN to represent the address. 
  #       Defaults to FALSE.
  #
  #  Returns:
  #    A modified violations data frame
  
  e <- d %>% 
    group_by(Case.ID) %>% 
    summarize(Violation.Count = n()) %>% 
    ungroup()
  
  left_join(d, e, by = 'Case.ID' )  
}