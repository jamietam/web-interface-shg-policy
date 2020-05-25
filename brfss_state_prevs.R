rm(list=ls())

# # Recode BRFSS data
# library(foreign)
# brfss2018 <- read.xport("C:/Users/jamietam/Dropbox/Analysis/BRFSS/brfss2018/LLCP2018.XPT") # Read in BRFSS data
# colnames(brfss2018)
# setwd("C://Users//jamietam//Dropbox//Analysis//BRFSS//")
# # X_RFSMOK3: 1 = Not smoker, 2 = current smoker, 9 = Refused/don't know
# brfss2018$smoker[brfss2018$X_RFSMOK3==1] = 0
# brfss2018$smoker[brfss2018$X_RFSMOK3==2] = 1
# brfss2018$smoker[brfss2018$X_RFSMOK3==9] = NA
# # SEX1: 1=Male, 2 = Female, 7 = don't know, 9 = Refused
# brfss2018$female[brfss2018$SEX1==2] = 1
# brfss2018$female[brfss2018$SEX1==1] = 0
# #X_AGE_G: 1 = 18-24, 2 = 25-34, 3= 35-44, 4=45-54, 5= 55-64, 6 = 65+
# brfss2018$agecat[brfss2018$X_AGE_G==1] = 1
# brfss2018$agecat[brfss2018$X_AGE_G==2] = 2
# brfss2018$agecat[brfss2018$X_AGE_G==3] = 2
# brfss2018$agecat[brfss2018$X_AGE_G==4] = 3
# brfss2018$agecat[brfss2018$X_AGE_G==5] = 3
# brfss2018$agecat[brfss2018$X_AGE_G==6] = 4
# # state = state FIPS code: 66 Guam, 72 Puerto Rico, 78 Virgin Islands
# brfss2018 <- brfss2018[brfss2018$X_STATE<57, ] # excludes U.S. territories, leaving only States and DC (51 total)
# brfssvars = brfss2018[c("X_STSTR","X_LLCPWT","agecat","smoker","female","X_STATE")]
# # save(brfssvars, file= "brfss_2018_data.Rda")

load("brfss_2018_data.Rda")

library(survey)
options(survey.lonely.psu = "adjust") # Set options for allowing a single observation per stratum 

stateabbrev = c("AL", "AK", "AZ", "AR", "CA", 
                "CO", "CT", "DE", "DC", "FL", 
                "GA", "HI", "ID", "IL", "IN", 
                "IA", "KS", "KY", "LA", "ME", 
                "MD", "MA", "MI", "MN", "MS", 
                "MO", "MT", "NE", "NV", "NH", 
                "NJ", "NM", "NY", "NC", "ND",
                "OH", "OK", "OR", "PA", "RI",
                "SC", "SD", "TN", "TX", "UT",
                "VT", "VA", "WA", "WV", "WI", "WY")
statecode = c(1,  2,  4,  5,  6,
              8,  9,  10, 11, 12,
              13, 15, 16, 17, 18,
              19, 20, 21, 22, 23,
              24, 25, 26, 27, 28,
              29, 30, 31, 32, 33,
              34, 35, 36, 37, 38, 
              39, 40, 41, 42, 44,
              45, 46, 47, 48, 49, 
              50, 51, 53, 54, 55, 56)

prevalence2018 = NULL
for (s in 1:51){
  # Create survey design for each state
  statedesign <- svydesign(id=~1, strata = ~X_STSTR, weights = ~X_LLCPWT, data = subset(brfssvars,X_STATE==statecode[s]) ) 

  #18-24
  b1824 = svymean(~smoker,  subset(statedesign,agecat==1), na.rm = TRUE)[1]
  m1824 = svymean(~smoker,  subset(statedesign,female==0 & agecat==1), na.rm = TRUE)[1]
  f1824 = svymean(~smoker,  subset(statedesign,female==1 & agecat==1), na.rm = TRUE)[1]
  
  #25-44
  b2544 = svymean(~smoker,  subset(statedesign,agecat==2), na.rm = TRUE)[1]
  m2544 = svymean(~smoker,  subset(statedesign,female==0 & agecat==2), na.rm = TRUE)[1]
  f2544 = svymean(~smoker,  subset(statedesign,female==1 & agecat==2), na.rm = TRUE)[1]
  
  #45-64
  b4564 = svymean(~smoker,  subset(statedesign,agecat==3), na.rm = TRUE)[1]
  m4564 = svymean(~smoker,  subset(statedesign,female==0 & agecat==3), na.rm = TRUE)[1]
  f4564 = svymean(~smoker,  subset(statedesign,female==1 & agecat==3), na.rm = TRUE)[1]
  
  #65 plus
  b65plus = svymean(~smoker,  subset(statedesign,agecat==4), na.rm = TRUE)[1]
  m65plus = svymean(~smoker,  subset(statedesign,female==0 & agecat==4), na.rm = TRUE)[1]
  f65plus = svymean(~smoker,  subset(statedesign,female==1 & agecat==4), na.rm = TRUE)[1]
  
  #18-99 years old
  b1899 = svymean(~smoker,  statedesign, na.rm = TRUE)[1]
  m1899 = svymean(~smoker,  subset(statedesign,female==0), na.rm = TRUE)[1]
  f1899 = svymean(~smoker,  subset(statedesign,female==1), na.rm = TRUE)[1]
  
  newrow = c(b1899,b1824, b2544, b4564, b65plus, 
             m1899,m1824, m2544, m4564, m65plus, 
             f1899, f1824, f2544, f4564, f65plus)
  prevalence2018 = rbind(prevalence2018,newrow)
}
rownames(prevalence2018)=stateabbrev
colnames(prevalence2018)=c("18-99",  "18-24",  "25-44",  "45-64", "65p",
                           "18-99m", "18-24m","25-44m", "45-64m", "65pm",
                           "18-99f", "18-24f","25-44f", "45-64f", "65pf")

# numbers have been checked and compared with CDC reports https://nccd.cdc.gov/cdi/rdPage.aspx?rdReport=DPH_CDI.ExploreByTopic&islTopic=TOB&islYear=9999&go=GO
round(prevalence2018[,"18-99"]*100,1)

write.csv(prevalence2018, file="prevalence2018.csv")	