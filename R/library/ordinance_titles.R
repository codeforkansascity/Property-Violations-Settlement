by_ordinance_and_description <- function(d) {
  d %>% 
    group_by(Ordinance.Title, Violation.Description)
}

by_ordinance_and_code <- function(d) {
  d %>% 
    group_by(Ordinance.Title, Violation.Code)
}

by_ordinance <- function(d) {
  d %>% 
    group_by(Ordinance.Title)
}

top_ordinances <- function(d, top_tier_threshold = 2000) {
  d %>% 
    summarize_by_ordinance() %>%  
    ungroup() %>% 
    filter(Violation.Count > top_tier_threshold)
}

summarize_by_ordinance <- function(d) {
  d %>% 
    by_ordinance() %>% 
    summarize(Violation.Count = n(), Median.Days.Open = median(Days.Open), Mean.Days.Open = mean(Days.Open), Ordinance.Chapter = first(Ordinance.Chapter))
}

plot_top_ordinance_frequency <- function(d, top_tier_threshold = 2000) {
  d %>% 
    top_ordinances(top_tier_threshold) %>% 
    ggplot(aes(reorder(Ordinance.Title, -Violation.Count), Violation.Count)) +    
    geom_bar(stat="identity") + 
    labs(title="Number of Violations by Ordinance (2009-2016)") + 
    xlab("Ordinance Title") + ylab("Violations") +
    theme(axis.text.x  = element_text(angle=90, vjust=0.5, size=8))    
}

plot_median_days_open_by_ordinance <- function(d, top_tier_threshold = 2000) {
  d %>% 
    top_ordinances(top_tier_threshold) %>% 
    ggplot(aes(reorder(Ordinance.Title, -Violation.Count), Median.Days.Open)) +    
    geom_bar(stat="identity") + 
    labs(title="Median Days Open by Ordinance (2009-2016)") + 
    xlab("Ordinance Title") + ylab("Violations") +
    theme(axis.text.x  = element_text(angle=90, vjust=0.5, size=8))  
}