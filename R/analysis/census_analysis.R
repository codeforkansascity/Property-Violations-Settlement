# reshape the violations data to join with census data
violationsByCensusArea <- violations %>% 
  addBlockGroupToViolations() %>% 
  removeRowsWithoutBlockGroups() %>%
  convertToTracts()

violationsByAddressAndCensusArea <- violationsByCensusArea %>% 
  summarizeByAddressWithPropertyViolationRatio() %>% 
  group_by(GEOID) %>% 
  summarize(Mean.Address.Violation.Count = mean(Address.Violation.Count), 
            Mean.Property.Violation.Ratio = mean(Property.Violation.Ratio),
            Mean.Days.Open = mean(Mean.Days.Open))

violationsByCensusArea <- violationsByCensusArea  %>% 
  summarizeByGeoid()

violationsByCensusArea <- left_join(violationsByCensusArea, violationsByAddressAndCensusArea, by = "GEOID")

# bind with census data from the acs package
violAndCensus <- violationsByCensusArea %>% 
  joinWithCensusData("B01003", getKcGeoTract()) %>% 
  joinWithCensusData("B15003", getKcGeoTract()) %>% 
  joinWithCensusData("B01002", getKcGeoTract()) %>% 
  joinWithCensusData("B19013", getKcGeoTract()) %>% 
  joinWithCensusData("B25071", getKcGeoTract()) %>% 
  joinWithCensusData("B11001", getKcGeoTract())

# scrub tracts with no population
violAndCensus <- filter(violAndCensus, violAndCensus[,'Total Population: Total'] > 0)


educationColumns <- c('Education.Population',
                      'Education.None', 
                      'Education.Nursery', 
                      'Education.Kindergarten', 
                      'Education.1st.Grade',
                      'Education.2nd.Grade',
                      'Education.3rd.Grade',
                      'Education.4th.Grade',
                      'Education.5th.Grade',
                      'Education.6th.Grade',
                      'Education.7th.Grade',
                      'Education.8th.Grade',
                      'Education.9th.Grade',
                      'Education.10th.Grade',
                      'Education.11th.Grade',
                      'Education.12th.Grade',
                      'Education.High.School.Diploma',
                      'Education.GED',
                      'Education.College.Less.Than.1.Year',
                      'Education.College.More.Than.1.Year',
                      'Education.Associate.Degree',
                      'Education.Bachelor.Degree',
                      'Education.Master.Degree',
                      'Education.Professional.Degree',
                      'Education.PhD')

# convert the raw education category numbers into percentages
edNumbers <- select(violAndCensus, 7:31)
names(edNumbers) <- educationColumns
edNumbers$Education.No.Diploma <- rowSums(edNumbers[,3:16])
edNumbers$Education.Diploma.GED <- rowSums(edNumbers[,17:18])
edNumbers$Education.Some.College <- rowSums(edNumbers[,19:21])
edNumbers$Education.Grad.Degree <- rowSums(edNumbers[,23:25])
edNumbers <- select(edNumbers, 
                    Education.Population, 
                    Education.None, 
                    Education.No.Diploma, 
                    Education.Diploma.GED, 
                    Education.Some.College,
                    Education.Bachelor.Degree,
                    Education.Grad.Degree)

edPercents <- lapply(select(edNumbers, 2:7), function(x, y) if(y > 0) { x/y } else 0, y = select(edNumbers, 1))
violAndCensus <- select(violAndCensus, -(7:31)) 
edPercents <- as.data.frame(edPercents)
edPercents <- round(100 * edPercents, digits = 2)
names(edPercents) <- names(edNumbers[2:7])
violAndCensus <- bind_cols(violAndCensus, edPercents)

names(violAndCensus)[6:11] <- c('Total.Population',
                                                 'Median.Age.Total',
                                                 'Median.Age.Male',
                                                 'Median.Age.Female',
                                                 'Median.Income',
                                                 'Median.Rent.Percent')

names(violAndCensus)[12:20] <- c('Total.Households',
                                 'Family',
                                 'Family.Married.Couple',
                                 'Family.Other',
                                 'Family.Other.Male.No.Wife',
                                 'Family.Other.Female.No.Husband',
                                 'NonFamily',
                                 'NonFamily.Living.Alone',
                                 'NonFamily.Not.Alone')

write.csv(violAndCensus, 'output/violationsAndCensus.csv', row.names = FALSE)
