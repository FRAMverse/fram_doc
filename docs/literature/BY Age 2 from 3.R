#######################################################################################
###### CODE TO UPDATE AGE 2 RECRUIT SCALARS USING BROOD YEAR AGE 2 FROM 3 METHOD ######
#######################################################################################
# JC; 8/24/2016
# NOTES:
# 1. Make sure the year and file path to databse are set correctly below


# Clear workspace
rm(list=ls(all=TRUE))

# Load required libraries
library(RODBC)

# set start time for purposes of timing code
strt <- Sys.time()

# Set Year
year = 2013

# Set the paths 
paths = list("C:\\data\\FRAM\\Base Period\\Validation\\8.24.16\\2016 Validation_OldBP_8.23.16_test.mdb")
# Set the input file path for the database
infile = paths[[1]]

#####################################
# Pull necessary data from database #
#####################################

con = odbcConnectAccess(infile)
RunID = sqlQuery(con, as.is = TRUE, 
                   paste(sep = '',
                         "SELECT * FROM RunID"))
Cohort = sqlQuery(con, as.is = TRUE, 
                  paste(sep = '',
                        "SELECT * FROM Cohort"))
StockRecruit = sqlQuery(con, as.is = TRUE, 
                 paste(sep = '',
                       "SELECT * FROM StockRecruit"))
close(con)

# Add year field to RunID
RunID$Year <- substr(RunID$RunName,11,14)

# Subset RunID to necessary years
RunID <- subset(RunID,Year %in% c(year,year+1))

# Subeset Cohort and StockRecruit to desired RunIDs
runIDs <- unique(RunID$RunID)
Cohort <- subset(Cohort, RunID %in% runIDs)
StockRecruit <- subset(StockRecruit, RunID %in% runIDs)

i=1
for(i in 1:dim(StockRecruit)[1]) {
    if(StockRecruit$Age[i] == 2) {
        # Get Age 3 Time Step 1 starting cohort from 'year+1'
        runID_yp1 <- RunID[RunID$Year == year+1,2]
        stk <- StockRecruit$StockID[i]
        age <- 3
        ts <- 1
        A3T1 <- Cohort[Cohort$RunID == runID_yp1 & Cohort$StockID == stk & Cohort$Age == age & Cohort$TimeStep == ts,8]
        A3T1 <- round(A3T1,0)
        
        # Get Age 3 Time Step 4 starting cohort from 'year'
        runID_y <- RunID[RunID$Year == year,2]
        stk <- StockRecruit$StockID[i]
        age <- 3
        ts <- 4
        A3T4 <- Cohort[Cohort$RunID == runID_y & Cohort$StockID == stk & Cohort$Age == age & Cohort$TimeStep == ts,8]
        A3T4 <- round(A3T4,0)
        
        # Updated Age 2 Recruit Scalar
        NewRecruitScalar <- round(A3T1 / A3T4 * StockRecruit[i,5],4)
        
        # Get primary key for record in StockRecruit table
        pk <- StockRecruit[i,1]
        
        con = odbcConnectAccess(infile)
        sqlQuery(con, as.is = TRUE,
                 paste(sep = '',
                       "UPDATE StockRecruit SET StockRecruit.RecruitScaleFactor = ",NewRecruitScalar," WHERE (((StockRecruit.PrimaryKey)=",pk,"))"))
        close(con)
    }
}

nd <- Sys.time()
tm <- nd - strt
tm
    