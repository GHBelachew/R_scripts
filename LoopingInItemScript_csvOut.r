#Imported Feb 8/2021
#This is to extract data form the file using any field 

# looping in r 
# by list of any thing
df <- read.csv("Path/AllegBu _Full.csv")
# get list of cites by unique
Cities  <- unique(df$Physical.City)
# Loop through the data frame and extract each city .
# this can be applied to any variable and file is saved in to the excel
# in case it is neded to analyis the data, one might need to inport it again
for(i in Cities) {
  
  df1 <- df[(df$Physical.City %in% c(i)), ]
  write.csv (df1, paste(i,"-City",".csv"), row.names = FALSE)

}



