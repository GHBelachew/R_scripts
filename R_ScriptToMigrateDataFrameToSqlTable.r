## This script is to import data frame to SQL Server from r
## This method is highly important to  do do the employment files, because I couldn't import employment files directly to SQL sever

# Call libraries
library(DBI)
library(RODBC)

# Clean up the folder by deleting all files
rm(list = ls()) #  

#Read files to Data frame

#df<- read.csv("C:/Users/Belachew/Desktop/lab/R/Population Pyramid/PopulationData.csv") # Stored file in my folder
df2 <- read.csv("C:/Users/Belachew/Desktop/Mergent/Mergent2018/AllegMI/AllegBu _Full.csv") # Stored file in my folder

# R Source site
#https://www.youtube.com/watch?v=VM-lzkYmyUE


# Define/introduce SQL Server database
con <- DBI::dbConnect(odbc::odbc(),
    driver = "SQL server",
    server = "DESKTOP-40F0OFE\\SQLEXPRESS01",
    #database = "Population",
    database = "Employment",
    Trusted_connection = "True")


# Expoer the data frame to the sql

dbWriteTable(con,"Population",df, overrite = FALSE) # if overtire is needed change the False to true
dbWriteTable(con,"MI18",df2, overrite = FALSE) # if overtire is needed change the False to true

# Don't forget to close your connection
odbcClose(connection)
