byChapter <- function(d) {
  # Groups the violations data by ordinance chapter
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A violations data frame grouped by ordinance chapter
  
  d %>% 
    group_by(Ordinance.Chapter)
}

summarizeByChapter <- function(d) {
  # Summarizes the violations data by chapter
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A new data frame summarizing violations by ordinance chapter
  #    Ordinance.Chapter | Ch.Violation.Count | Ch.Mean.Days.Open |
  #    Ch.Median.Days | Ch.Sd | Percent.Violations
  
  by_chapter(d) %>% 
    summarize(Ch.Violation.Count = n(), 
              Ch.Mean.Days.Open = mean(Days.Open), 
              Ch.Median.Days = median(Days.Open), 
              Ch.Sd = sd(Days.Open, na.rm = TRUE)) %>%
    ungroup() %>% 
    mutate(Percent.Violations = (Ch.Violation.Count / nrow(d))*100.00) %>% 
    arrange(desc(Ch.Violation.Count))
}

topChapters <- function(d) {
  # Filters the violations data to include only the two most important
  # ordinance chapters - nuisance (48) and property (56)
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A violations data frame filtered to only include nuisance and property
  #    violations
  
  d %>% 
    filter(Ordinance.Chapter %in% c('48', '56'))
}