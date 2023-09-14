# This script is to Prepare flat file of Cycle12 Forecast data.
# Date August 23, 2023
# by Belachew Ayele

# Loading libraries == Note: some libraries will may not be needed but keep the list
library(data.table)
library(ggmap)
library(ggplot2)
library(dplyr)
library(reshape2)
library(reshape)
library(plyr)
library(readxl)

#========================================================================
# Reading Data ; path of data file and name of data source are subject to change
file = "L:/Belachew/2023/ForCycle12/ForecastFINALProduct/Client/Cycle 12 by munic 2020-2060_Templete2_W_Data.xlsx"
df_m <- read_excel(file, skip = 8)
df_muni
df_m <- df_m[ ,1:88] # leave out the last three column because they are not needed
#df_m$...1
# rename columns 1 to 7
old_names <- c("...1","...2", "...3","...4","...5","...6", "...7")
new_names <- c("County", "Munic", "REMI", "Name","TOTSQMI", "LANDSQMI", "WATERSQMI")
df_m <- df_m %>% rename_at(vars(old_names), ~ new_names)
#colnames(df_m)

# Collect all the data for Municipality (these have remicodes  1,2,3,4,5,6,7,8,9,10,11)
df_muni <- subset(df_m, df_m$REMI %in% c(2,3,4,5,6,7,8,9,10,11))  # this is without City of Pittsburgh
 
# Collect data by City of Pittsburgh and rest Allegeny and other counties
df_Cty <- df_m[591:603, ]
df_PGH <- subset(df_Cty, df_Cty$County =="Pittsburgh, City of")
df_rest_allg <- subset(df_Cty, df_Cty$County =="Allegheny")
df_allg <- subset(df_Cty, df_Cty$County =="Allegheny whole") # Allegheny Whole is the sum of Pittsburgh City and df_rest_allg  calculated  in excel
df_SPC_Reg <- subset(df_Cty, df_Cty$County =="SPC Region") 
df_SPc_wo_allg <- subset(df_Cty, df_Cty$County %in% c("Armstrong",
                                     "Butler",
                                     "Beaver",
                                     "Fayette",
                                     "Greene",
                                     "Indiana", 
                                     "Lawrence", 
                                     "Washington",
                                     "Westmoreland"))


# SPC all Counties
df_SPC_all_Cty  <- rbind(df_allg, df_SPc_wo_allg)

# files needed to merge later are
   # 1. df_muni  = all municipality  except Pittsburgh
   # 2. df_PGH   = Pittsburgh Municipality
   # 3. df_SPC_all_Cty = All 10 Counties
   # 4. df_SPC_Reg  = SPc Region total

# But FIPS Code should be added to each before merging
df_muni$FIPS <- ""
df_PGH$FIPS <- ""
df_SPC_all_Cty$FIPS <- ""

# Read municipality FIPS from Master Index
df_muni_FIPS <- read_excel("L:/Belachew/2023/index/0_MASTER_INDEX_C12_v1a_working_032923.xlsx", sheet = "Munic_FIPS", skip=4)
df_muni_FIPS <- df_muni_FIPS[ ,1:4] # extract the fist four columns
df_muni_FIPS <- subset(df_muni_FIPS, df_muni_FIPS$FIPS...3 != "NA")

# Merge df_muni and df_Muni_Fips based 

df_muni2 <- join(df_muni, df_muni_FIPS, by = 'Munic')
df_muni2$FIPS <- df_muni2$FIPS...3

colnames(df_muni2)
# drop "sequence" , "FIPS...3", and "Name"
df_muni2 <- subset(df_muni2, select = -c(Sequence,FIPS...3,92)) #take out  the last three, 92 is t he index  column number for  Name. It it exists two palces

# Replacing Allegheny Name
# Add FIPS code to the counties
df_SPC_all_Cty$County[df_SPC_all_Cty$County == "Allegheny whole"] <- "Allegheny"

#Populate FIPS in df_SPC_all_Cty 
df_SPC_all_Cty$FIPS <- df_SPC_all_Cty$County # replace fips with couty name

df_SPC_all_Cty$FIPS[df_SPC_all_Cty$FIPS == "Allegheny"] <- "05000US42003"
df_SPC_all_Cty$FIPS[df_SPC_all_Cty$FIPS == "Armstrong"] <- "05000US42005"
df_SPC_all_Cty$FIPS[df_SPC_all_Cty$FIPS == "Beaver"] <- "05000US42007"
df_SPC_all_Cty$FIPS[df_SPC_all_Cty$FIPS == "Butler"] <- "05000US42019"
df_SPC_all_Cty$FIPS[df_SPC_all_Cty$FIPS == "Fayette"] <- "05000US42051"
df_SPC_all_Cty$FIPS[df_SPC_all_Cty$FIPS == "Greene"] <- "05000US42059"
df_SPC_all_Cty$FIPS[df_SPC_all_Cty$FIPS == "Indiana"] <- "05000US42063"
df_SPC_all_Cty$FIPS[df_SPC_all_Cty$FIPS == "Lawrence"] <- "05000US42073"
df_SPC_all_Cty$FIPS[df_SPC_all_Cty$FIPS == "Washington"] <- "05000US42125"
df_SPC_all_Cty$FIPS[df_SPC_all_Cty$FIPS == "Westmoreland"] <- "05000US42129"

# add additional code to the municipal FIPS

df_muni2$FIPS2 <- ""

df_muni2$FIPS2 <- paste0("06000US", df_muni2$FIPS)

df_muni2$FIPS <- df_muni2$FIPS2  # calculate FIPS2 to FIPS
df_muni2 <- subset(df_muni2, select = -c(FIPS2)) # drop FIPS2

# add FIPS code to the df_SPC_Reg
df_SPC_Reg$FIPS <-"04000US42SPC" 

# add  FIPS to Pittsburgh City = 06000US4200361000
df_PGH$FIPS <- "06000US4200361000"
df_PGH$County[df_PGH$County == "Pittsburgh, City of"] <- "Allegheny"
df_PGH$Munic[is.na(df_PGH$Munic)] <- "Pittsburgh City"  # NA is replaced by  "Pittsburgh City"
df_PGH$Name <- df_PGH$Munic   # Replace the NA with city name



# Combine df_PGH and df_muni2
df_muni_all <- rbind(df_PGH, df_muni2)

# Sort df_muni_all by county and Municipality names
df_muni_all <- df_muni_all %>% arrange(County, Name)



#Combine All Together
df_all <- rbind(df_SPC_Reg,df_SPC_all_Cty, df_muni_all)

#Put it all in order
colnames(df_all)
df_SPC_all <- df_all[ ,c(1,4,89,5:88)]
df_SPC_all$Name[is.na(df_SPC_all$Name)] <-"" # replacing NA with  blank


# Reshaping the file
df_SPC_All_log <- reshape2::melt(df_SPC_all,id.vars = c("County","Name","FIPS"))

# Out put data to excel
write.csv(df_SPC_all,"L:/Belachew/2023/ForCycle12/ForecastFINALProduct/R/Out/df_SPC_all_C12.csv",row.names = F)
write.csv(df_SPC_All_log,"L:/Belachew/2023/ForCycle12/ForecastFINALProduct/R/Out/df_SPC_All_log_C12.csv",row.names = F)
