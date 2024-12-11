rm(list=ls())
#make sure to install pckgs
library(here)
library(tidyr)
library(dplyr)
library(readxl)
library(openxlsx)
library(lubridate)
library(stringr)

#######Import Data 
data <- read_xlsx(file.path(here::here("Data", "raw"), "Report copy.xlsx"), sheet = 6)
data$Date <- as.Date(data$Date)

print(colnames(data))



#######Monthly returns
monthly_data <- data %>%
  group_by(month = floor_date(Date, "month")) %>% 
  filter(Date == max(Date, na.rm = TRUE)) %>%
  ungroup()

monthly_returns <- monthly_data %>%
  mutate(across(ends_with("TOT RETURN IND"), 
                ~ (. - lag(.)) / lag(.), 
                .names = "rm_{.col}")) %>%  
  rename_with(~ str_remove(.x, " - TOT RETURN IND"), starts_with("rm_")) %>%  
  select(Date, starts_with("rm_")) 

#print(head(monthly_returns))


#######Save rm_funds 
write.xlsx(monthly_returns, file = file.path(here::here("Data"), "rm_funds.xlsx"))

