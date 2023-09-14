#===============================================================================
# This script is to Collect decennial 2020 census data
# Date September 14, 2023
# Belachew Ayele, SPC Region 
#===============================================================================

library(tidycensus)
library(tidyverse)
library(sf)


library(reshape2)
library(reshape)
library(dplyr)

census_api_key("XXX", install = FALSE)
# finding the varables
census_2020_vars_p1 <- load_variables(2020,
                                   dataset ="pl")


census_2020_vars_dhc <- load_variables(2020,
                                      dataset ="dhc")

census_2020_vars_dp <- load_variables(2020,
                                       dataset ="dp")


# Write variables to csv
#write.csv(census_2020_vars_p1, "L:/Belachew/2023/ForCycle12/DataForSPC_DataCenter/Flat File/CensusDataTest/Decennial/Document/ensus_2020_vars_p1.csv")

# https://www.youtube.com/watch?v=qiHozT3Vzb8

# https://carolinademography.cpc.unc.edu/2022/05/16/story-recipe-how-to-obtain-census-data-using-r-tidycensus/

# variables for housing occupancy and Population
#===============================================================================
#List of Desired variable and their definition
# Note
# "H1_001N" = Total - Occupancy Status"
# "H1_002N" = Total - Occupied status
# "H1_003N" = Total - vacant status
# "P1_001N" = Total Population
# "P1_002N" = Total Population of one race
# "P1_003N" = Total Population of one race: White alone
# "P1_004N" = Total Population of one race: Black or African American alone
# "P1_005N" = Total Population of one race: American Indian and Alaska Native alone
# "P1_006N" = Total Population of one race: Asian alone
# "P1_007N" = Total Population of one race: Native Hawaiian and Other Pacific Islander alone
# "P1_008N" = Total Population of one race: American Indian and Alaska Native alone
# "P1_009N" = Total Population of two or more races:
# "P2_002N" = Total Hispanic or Latino
# "P2_005N" = Total Not Hispanic or Latino:!!Population of one race:!!White alone


#=============================================================================== 

desired_vars = c(
  "H1_001N",
  "H1_002N",
  "H1_003N",
  "P1_001N",
  "P1_002N",
  "P1_003N",
  "P1_004N",
  "P1_005N",
  "P1_006N",
  "P1_007N",
  "P1_008N",
  "P1_009N",
  "P2_002N",
  "P2_005N" )

#  1. United States 
US_2020 = get_decennial(
  geography = "us",
  #state = "us",
  variables = desired_vars, #<---- here is where I am using the list
  #summary_var = "P2_001N",#<--- creates a column w/'total' variable
  output = "wide",
  year = 2020,
  sumfile = "pl")


# 2. Pennsylvania counties
PA_State_2020 = get_decennial(
  geography = "state",
  state = "PA",
  variables = desired_vars, #<---- here is where I am using the list
  #summary_var = "P2_001N",#<--- creates a column w/'total' variable
  output = "wide",
  year = 2020,
  sumfile = "pl")


# 3.  Pennsylvania counties
SPC_cty_2020 = get_decennial(
  geography = "county",
  state = "PA",
  county = c("Allegheny","Armstrong","Beaver",
             "Butler","Fayette","Greene", "Indiana",
             "Lawrence", "Washington", "Westmoreland"),
  variables = desired_vars, #<---- here is where I am using the list
  #summary_var = "P2_001N",#<--- creates a column w/'total' variable
  output = "wide",
  year = 2020,
  sumfile = "pl")



# 4. Pennsylvania Municipalities
SPC_Muni_2020 = get_decennial(
  geography = "county subdivision",
  state = "PA",
  county = c("Allegheny","Armstrong","Beaver",
             "Butler","Fayette","Greene", "Indiana",
             "Lawrence", "Washington", "Westmoreland"),
  variables = desired_vars, #<---- here is where I am using the list
  #summary_var = "P2_001N",#<--- creates a column w/'total' variable
  output = "wide",
  year = 2020,
  sumfile = "pl")



# 5. Pennsylvania Pittsburgh Metropolitan area.

PA_msa_2020 = get_decennial(
  geography = "metropolitan statistical area/micropolitan statistical area",
  #state = "PA",
  region = "Pittsburgh, PA", 
  variables = desired_vars, #<---- here is where I am using the list
  #summary_var = "P2_001N",#<--- creates a column w/'total' variable
  output = "wide",
  year = 2020,
  sumfile = "pl")

# Extract Pittsburgh metropolitan area using GEOID = 38300
PGH_msa_2020 <- subset(PA_msa_2020,PA_msa_2020$GEOID == "38300")


# Summing for SPC Region Total

SPCReg_w_Total <- SPC_cty_2020 %>% bind_rows(summarise(., across(where(is.numeric), sum),
                                                 across(where(is.character), ~'Total')))

# Renaming totals for SPC counties
SPCReg_w_Total$GEOID[SPCReg_w_Total$GEOID == "Total"] <- "04000US42SPC"
SPCReg_w_Total$NAME[SPCReg_w_Total$NAME == "Total"] <- "42SPC"

SPC_Region_Total <- subset(SPCReg_w_Total, SPCReg_w_Total$GEOID == "04000US42SPC")


# Replace GEOID with appropriate names for the the Prerequisite

US_2020$GEOID[1] <-"01000US"
PA_State_2020$GEOID[1] <- "04000US42"
SPC_cty_2020$GEOID <- paste0("05000US",SPC_cty_2020$GEOID)
SPC_Muni_2020$GEOID <- paste0("06000US",SPC_Muni_2020$GEOID)
PGH_msa_2020$GEOID <- "32000US4238300"



# Sort SPC County and SPC Municipality

SPC_cty_2020 <- SPC_cty_2020 %>%
                arrange((GEOID), NAME)

SPC_Muni_2020 <- SPC_Muni_2020 %>%
                  arrange((GEOID), NAME)


# Putting All together with order
 #1. US_2020
 #2. PA_State_2020
 #3. PGH_msa_2020
 #4. SPC_Region_Total
 #5. SPC_cty_2020
 #6. SPC_Muni_2020

decenial_20_all <- rbind(US_2020,PA_State_2020,PGH_msa_2020,SPC_Region_Total,SPC_cty_2020,SPC_Muni_2020)
