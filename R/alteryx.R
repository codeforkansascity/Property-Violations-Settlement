addCensusDataFromAlteryx <- function(d) {
  left_join(d, getAlteryxData(), by = 'GEOID')
}

getAlteryxData <- function() {
  alteryxCensus <- read.csv(file = 'data/PropViolations_1stRun.csv')
  alteryxCensus$GEOID <- as.character(alteryxCensus$GEOID)
  alteryxCensus
}