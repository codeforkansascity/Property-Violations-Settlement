blockGroupSummarize <- function(d) {
  # Summarize the data by block group (described by the GEOID column)
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A new summary data frame with GEOID, Violation.Count
  
  d %>% 
    group_by(GEOID) %>% 
    summarize(Violation.Count = n())
}

removeRowsWithoutBlockGroups <- function(d) {
  # Scrubs rows without GEOIDS (which represents a census block group). This can result from invalid KIVA.PIN data in
  # in the violations data frame.
  #
  #  Args:
  #    d: A violations data frame
  # 
  #  Returns:
  #    A modified violations data frame
  
  print(sprintf("Scrubbing %d rows without GEOIDs", nrow(filter(d, is.na(GEOID)))))
  d %>% 
    filter(!is.na(GEOID))
}