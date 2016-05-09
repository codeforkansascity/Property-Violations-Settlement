byAddress <- function(d) {
  # Groups the violations data by address
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A violations data frame grouped by address
  
  d %>% 
    group_by(KIVA.PIN)
}

byAddressAndChapter <- function(d) {
  # Groups the violations data by address and then ordinance chapter
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A violations data frame grouped by address and ordinance chapter
  
  d %>% 
    group_by(KIVA.PIN, Ordinance.Chapter)
}

summarizeByAddress <- function(d) {
  # Groups and summarizes the violations data by address
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A data frame centered on address, rather than individual violations
  #    KIVA.PIN | Violation.Count | Mean.Days.Open | Median.Days.Open
  
  d %>% 
    byAddress() %>% 
    summarize(Violation.Count = n(), 
              Mean.Days.Open = round(mean(Days.Open), digits = 2),
              Median.Days.Open = round(median(Days.Open), digits = 2)) %>% 
    ungroup()
}

summarizeByViolationCountPerAddress <- function(d) {
  # Groups and summarizes the violations data by violation count per address.
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A data frame centered on violation count per address, rather than individual violations
  #    Violation.Count | Median.Days.Open | Mean.Days.Open | Address.Count
  
  d %>% 
    addTotalViolationsForAddressColumn() %>%
    group_by(Violation.Count) %>% 
    summarize(Median.Days.Open = median(Days.Open), 
              Mean.Days.Open = mean(Days.Open), 
              Address.Count = n()) %>% 
    ungroup()
}

addTotalViolationsForAddressColumn <- function(d) {
  # Adds a column to the violations data frame providing a count of total
  # violations for the address to which the violation relates
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A violations data frame with a Violation.Count column added
  
  e <- summarizeByAddress(d)
  left_join(d, select(e, KIVA.PIN, Violation.Count), by = 'KIVA.PIN' )  
}

plotViolationsForAddressFrequency <- function(d) {
  # Plots the frequency of violation counts per address (in other words, the 
  # number of addresses with 1 violation vs 2 vs 3, etc.)
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A plot of address frequency per violation count

    d %>%
      summarizeByAddress() %>% 
      ggplot(aes(x = Violation.Count)) + geom_histogram(binwidth = 1) + 
      scale_x_continuous(limits = c(0,75)) + 
      labs(title = "Violations per Address") +
      xlab("Number of Violations at an Address") +
      ylab("Violation Count")
}

plotMedianDaysOpenByAddressViolationCount <- function(d) {
  # Plots the median days open by the number of violations per address
  # in order to illustrate whether any relationship that might exist 
  # between the number of violations at an address and the time it takes to 
  # resolve those violations.
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A plot of median days open by violation count (per address)
  
  d %>% 
    summarizeByViolationCountPerAddress() %>%
    ggplot(aes(Violation.Count, Median.Days.Open)) +    
    geom_bar(stat="identity") + 
    scale_x_continuous(limits = c(0,75)) + 
    labs(title="Median Days Open by # Violations Per Address (2009-2016)") + 
    xlab("# of Violations") + ylab("Median Days Open") +
    theme(axis.text.x  = element_text(angle=90, vjust=0.5, size=8))  
}

plotMeanDaysOpenByGroupViolationCount <- function(d) {
  # Plots the mean days open by the number of violations per address
  # in order to illustrate whether any relationship that might exist 
  # between the number of violations at an address and the time it takes to 
  # resolve those violations.
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A plot of median days open by violation count (per address)

    d %>% 
      summarizeByViolationCountPerAddress() %>% 
      ggplot(aes(Violation.Count, Mean.Days.Open)) +    
      geom_bar(stat="identity") + 
      scale_x_continuous(limits = c(0,75)) + 
      labs(title="Mean Days Open by # Violations Per Address (2009-2016)") + 
      xlab("# of Violations") + ylab("Mean Days Open") +
      theme(axis.text.x  = element_text(angle=90, vjust=0.5, size=8))  
}

computeCumulativePercentViolationsForAddresses <- function(d)  {
  # Transforms the violations data into a data frame showing the cumulative
  # percent of violations, ranking by the number of violations descending.
  # In other words, the addresses with the highest number of violations
  # are considered first in computing the cumulative percent. The idea is to show
  # the relative impact of the worst offenders.
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A new data frame showing cumulative percentages of both addresses and violations
  #    by violation count per address.
  
  t <- d %>% 
    summarizeByAddress() %>% 
    group_by(Violation.Count) %>% 
    summarize(Address.Count = n())  %>% 
    mutate(Total.Violations = Violation.Count * Address.Count) %>% 
    arrange(desc(Violation.Count))
  c <- t %>% 
    select(2:3) %>% 
    cumsum()  
  
  t$Cum.Address.Count <- c$Address.Count
  t$Cum.Total.Violations <- c$Total.Violations
  
  t %>% 
    mutate(Cum.Percent.Address = round(Cum.Address.Count/sum(Address.Count), digits = 4)*100,
           Cum.Percent.Violations =  round(Cum.Total.Violations/sum(Total.Violations), digits = 4)*100) %>% 
    select(Violation.Count, Cum.Percent.Address, Cum.Percent.Violations)
}

plotCumulativePercentViolations <- function(d) {
  # Plots the cumulative percentage of violations by the cumulative percentage of addresses
  # in order to show the impact (or lack thereof) of the worst offending addresses
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A plot of cumulative percentages of violations per cumulative percentage of addresses.
  
  d %>% 
    computeCumulativePercentViolationsForAddresses() %>% 
    ggplot(aes(x=Cum.Percent.Address, y=Cum.Percent.Violations)) + 
    geom_line() +
    labs(title = "Violations Generated by Addresses") +
    xlab("Percent of  Addresses") +
    ylab("Percent of Violations")
}
