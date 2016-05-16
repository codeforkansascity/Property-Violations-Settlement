###############################################################################
## demonstrates the use of "wrapper functions" that make the "acs" package 
## a little easier to use to obtain census data
###############################################################################

# define the boundaries of Kansas City for purposes of retrieving census data
kcCensusGeography <- getKcGeo()
# fetch census data - TODO: add support for easier to read columns
kcCensusPopulation <- getCensusTableAsDataframe("B01003", kcCensusGeography)
kcCensusEducation <- getCensusTableAsDataframe("B15003", kcCensusGeography)
kcCensusMedianAge <- getCensusTableAsDataframe("B01002", kcCensusGeography)
kcCensusMedianIncome <- getCensusTableAsDataframe("B19013", kcCensusGeography)
kcCensusMedianRent <- getCensusTableAsDataframe("B25071", kcCensusGeography)