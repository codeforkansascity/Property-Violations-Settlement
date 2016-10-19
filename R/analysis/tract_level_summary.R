# add census tract GEOID to violation records
violationsWithTract <- violations %>%
  filter(Days.Open > 180 & Status == 'Open') %>%
  filter(Status == 'Open') %>% 
  addBlockGroupToViolations() %>% 
  removeRowsWithoutBlockGroups() %>%
  convertToTracts()

# summary per cited address for each tract
violationsSummaryByAddressPerTract <- violationsWithTract %>% 
  summarizeByAddressWithPropertyViolationRatio() %>% 
  group_by(GEOID) %>% 
  summarize(Mean.Address.Violation.Count = mean(Address.Violation.Count), 
            Mean.Property.Violation.Ratio = mean(Property.Violation.Ratio),
            Mean.Days.Open = mean(Mean.Days.Open))

# total violations per tract
violationsWithTract <- violationsWithTract  %>% 
  summarizeByGeoid()

# join summary fields
violationsByTract <- left_join(violationsWithTract, violationsSummaryByAddressPerTract, by = "GEOID")

# add total population
violationsByTract <- violationsByTract %>% 
  joinWithCensusData("B01003", getKcGeoTract()) 
  
violationsByTract$PerCapitaViolationCount <- violationsByTract$Violation.Count / violationsByTract$`Total Population: Total`

write.csv(violationsByTract, file = 'output/sixMonthsOpenViolationsByTract.csv', row.names = FALSE)
