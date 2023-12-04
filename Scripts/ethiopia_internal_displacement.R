
# Load libraries
library(tidyverse)
library(readxl)

# Read data 
# data can be downloaded from IDMC website: https://www.internal-displacement.org/database/displacement-data

Internal_Displacement_Data <- read_excel("C:/Users/yihun/iCloudDrive/Downloads/IDMC_GIDD_Disasters_Internal_Displacement_Data.xlsx", 
                                         col_types = c("text", "text", "text", 
                                                       "text", "date", "numeric", "numeric", 
                                                       "text", "text", "text"))

Internal_Displacement_Data %>% 
  filter(ISO3 == "ETH") %>% 
  group_by(Year) %>% 
  summarise(Total = sum(`Disaster Internal Displacements (Raw)`))
  view()
