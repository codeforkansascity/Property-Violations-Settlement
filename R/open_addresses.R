addressesWithOpenViolations <- function(d) {
  # Reshapes the violations data frame into a data frame of addresses that have open violations.
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A data frame consisting of addresses with open violations. Each address has summary 
  #    information about the violations still open at the address.

  d <- d %>% 
    addOrdinanceTitles() %>% 
    filter(Status == "Open")
  
  openAddresses <- d %>% 
    arrange(Address, Violation.Entry.Date, Ordinance.Title) %>% 
    group_by(Address, Ordinance.Chapter) %>% 
    summarize(Violation.Count = n(),
              Case.Opened.Date = first(Case.Opened.Date),
              Days.Open = mean(Days.Open), 
              Latitude = first(Latitude),
              Longitude = first(Longitude),
              Zip.Code = first(Zip.Code)) %>% 
    spread(Ordinance.Chapter, Violation.Count, fill = 0) %>% 
    mutate(Violation.Count = `48` + `56`, Property.Ratio = `56` / Violation.Count) %>% 
    select(-(`48`:`56`)) %>% 
    filter(Longitude != '') %>% 
    ungroup()
  
  #list of ordinances for open cases
  openOrdinancesByAddress <- d %>% 
    group_by(Address) %>% 
    summarize(Ordinances = paste(sprintf("%s %s", Violation.Entry.Date, Ordinance.Title), collapse = "<br/>")) %>% 
    ungroup()
  
  openAddresses <- left_join(openAddresses, openOrdinancesByAddress, by = 'Address')
  
  rm(openOrdinancesByAddress)
  openAddresses
}

