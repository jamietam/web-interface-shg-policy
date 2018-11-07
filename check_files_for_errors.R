## This script runs checks on the following:
## 1) whether there are missing scenario files in the deaths, lyg, and results directories
## 2) the dimensions of each file in case there are missing rows of data
## 3) whether the sum of deaths avoided for all cohorts is negative under 2016 policy scenarios
## 4) whether the ratio of deaths avoided between men and women is greater than 2

where =  paste0("/home/jamietam/source_dataAug2018/US")
setwd(where)

print("AIRLAWS CHECK")

# check if any scenarios are missing
dnum = length(list.files(paste0(where,'/airlaws/deaths')))
lnum = length(list.files(paste0(where,'/airlaws/lyg')))
rnum = length(list.files(paste0(where,'/airlaws/results')))
if (dnum!=216 | lnum!=216 | rnum !=216){
  print(paste0('deathsnum=', dnum, ' | lygnum=', lnum, ' | resultsnum=', rnum))
}

Iwp_set = c(0,1) ### indicator of workplace policy to be implemented 1-yes, 0-no
Ir_set = c(0,1) ### indicator of restaurants policy to be implemented 1-yes, 0-no
Ib_set = c(0,1) ### indicator of bars policy to be implemented 1-yes, 0-no
pacwp_set = c(0.00,0.25,0.50,0.75,1.00) ### percentage already covered by workplace clean air laws
pacr_set = c(0.00,0.25,0.50,0.75,1.00) ### percentage already covered by restaurants clean air laws
pacb_set = c(0.00,0.25,0.50,0.75,1.00) ### percentage already covered by bars clean air laws

for (Iwp in Iwp_set){
  for (Ir in Ir_set){
    for (Ib in Ib_set){
      for (pacwp in pacwp_set){
        for (pacr in pacr_set){
          for (pacb in pacb_set){
            if (Iwp==0 & pacwp>0.00) next
            if (Ir==0 & pacr>0.00) next
            if (Ib==0 & pacb>0.00) next
            name = paste0('w',Iwp,'_r',Ir,'_b',Ib,'_w',format(pacwp,nsmall=2),'_r',format(pacr,nsmall=2), '_b',format(pacb,nsmall=2))

            # skip if file does not exist
            if (!file.exists(paste0(where,'/airlaws/deaths/deaths_',name,'.csv'))) next
            dtest <- read.csv(paste0(where,'/airlaws/deaths/deaths_',name,'.csv'))
            ltest <- read.csv(paste0(where,'/airlaws/lyg/lyg_',name,'.csv'))
            rtest <- read.csv(paste0(where,'/airlaws/results/results_',name,'.csv'))

            # check that each file has correct length
            if (dim(dtest)[1]!=1530 | dim(ltest)[1]!=1530 | dim(rtest)[1]!=2805){
              print(paste0(name," MISSING ROWS"))
            }

            # check death files for negative values and unbalanced ratio
            dtest<-subset(dtest, policy_year==2016&cohort=="ALL")
            if (sum(as.numeric(dtest[,'deaths_avoided_females']))<0 | sum(as.numeric(dtest[,'deaths_avoided_males']))<0){
              print(paste0(name," NEGATIVE TOTAL DEATHS"))
            }
            if ( 2*sum(as.numeric(dtest[,'deaths_avoided_females']))< sum(as.numeric(dtest[,'deaths_avoided_males']))){
              print(paste0(name, "RATIO OF M vs. R DEATHS > 2"))
            }
          }
        }
      }
    }
  }
}

print("TAXES CHECK")

initprices <- c(4.00,4.50,5.00,5.50,6.00,6.50,7.00,7.50,8.00,8.50,9.00,9.50,10.00,10.50)
taxes <- c(1.00,1.50,2.00,2.50,3.00,3.50,4.00,4.50,5.00)

# check if any scenarios are missing
dnum = length(list.files(paste0(where,'/taxes/deaths')))
lnum = length(list.files(paste0(where,'/taxes/lyg')))
rnum = length(list.files(paste0(where,'/taxes/results')))
if (dnum!=127 | lnum!=127 | rnum !=127){
  print(paste0('deathsnum=', dnum, ' | lygnum=', lnum, ' | resultsnum=', rnum))
}
for (initprice in initprices) {
  for (tax in taxes) {
     name = paste0(format(initprice,nsmall=2),'_t',format(tax,nsmall=2))

     dtest <- read.csv(paste0(where,'/taxes/deaths/deaths_',name,'.csv'))
     ltest <- read.csv(paste0(where,'/taxes/lyg/lyg_',name,'.csv'))
     rtest <- read.csv(paste0(where,'/taxes/results/results_',name,'.csv'))

     # check that each file has correct length
     if (dim(dtest)[1]!=1530 | dim(ltest)[1]!=1530 | dim(rtest)[1]!=2805){
       print(paste0(name," MISSING ROWS"))
     }
     # check death files for negative values and unbalanced ratio
     dtest<-subset(dtest, policy_year==2016&cohort=="ALL")
     if (sum(as.numeric(dtest[,'deaths_avoided_females']))<0 | sum(as.numeric(dtest[,'deaths_avoided_males']))<0){
       print(paste0(name," NEGATIVE TOTAL DEATHS"))
     }
     if ( 2*sum(as.numeric(dtest[,'deaths_avoided_females']))< sum(dtest[,'deaths_avoided_males'])){
       print(paste0(name, "RATIO OF M vs. R DEATHS > 2"))
     }
  }
}

print("TCEXP CHECK")

initexp <- c(0.00,0.10,0.20,0.30,0.40,0.50,0.60,0.70,0.80,0.90)
finalexp <- c(0.00,0.10,0.20,0.30,0.40,0.50,0.60,0.70,0.80,0.90,1.00)

# check if any scenarios are missing
dnum = length(list.files(paste0(where,'/tcexp/deaths')))
lnum = length(list.files(paste0(where,'/tcexp/lyg')))
rnum = length(list.files(paste0(where,'/tcexp/results')))
if (dnum!=56 | lnum!=56 | rnum !=56){
  print(paste0('deathsnum=', dnum, ' | lygnum=', lnum, ' | resultsnum=', rnum))
}
for (v1 in initexp) {
  for (v2 in finalexp) {
     if(v1>=v2) next
     name = paste0('initexp',format(v1,nsmall=2),'_policyexp',format(v2,nsmall=2))
     print(name)

     dtest <- read.csv(paste0(where,'/tcexp/deaths/deaths_',name,'.csv'))
     ltest <- read.csv(paste0(where,'/tcexp/lyg/lyg_',name,'.csv'))
     rtest <- read.csv(paste0(where,'/tcexp/results/results_',name,'.csv'))

     # check that each file has correct length
     if (dim(dtest)[1]!=1530 | dim(ltest)[1]!=1530 | dim(rtest)[1]!=2805){
       print(paste0(name," MISSING ROWS"))
     }
     # check death files for negative values and unbalanced ratio
     dtest<-subset(dtest, policy_year==2016&cohort=="ALL")
     if (sum(as.numeric(dtest[,'deaths_avoided_females']))<0 | sum(as.numeric(dtest[,'deaths_avoided_males']))<0){
       print(paste0(name," NEGATIVE TOTAL DEATHS"))
     }
     if (v1>=0.00) {
     print(paste0("females:",as.numeric(dtest[51,'deaths_avoided_females']),"|males:",as.numeric(dtest[51,'deaths_avoided_males'])))
     }
  }
}

  # if ((2*sum(as.numeric(dtest[,'deaths_avoided_females'])))< sum(dtest[,'deaths_avoided_males'])){
    # print(paste0(name, " DEATH RATIO > 2"))
       print(paste0("females:",sum(as.numeric(dtest[,'deaths_avoided_females'])),"|males:",sum(as.numeric(dtest[,'deaths_avoided_males'])))
    # }


print("MLA CHECK")

minages <- c(19,21,25)
pac19_set <- c(0.00, 0.25, 0.50, 0.75,1.00)
pac21_set <- c(0.00, 0.25, 0.50, 0.75,1.00)

# check if any scenarios are missing
dnum = length(list.files(paste0(where,'/mla/deaths')))
lnum = length(list.files(paste0(where,'/mla/lyg')))
rnum = length(list.files(paste0(where,'/mla/results')))
if (dnum!=45 | lnum!=45 | rnum !=45){
  print(paste0('deathsnum=', dnum, ' | lygnum=', lnum, ' | resultsnum=', rnum))
}
for (mla_age in minages) {
  for (pac19 in pac19_set) {
     for (pac21 in pac21_set) {
        if ((pac19+pac21) > 1.00) next
        name = paste0(format(mla_age),'_pac19_',format(pac19,nsmall=2),'_pac21_',format(pac21,nsmall=2))
        dtest <- read.csv(paste0(where,'/mla/deaths/deaths_',name,'.csv'))
        ltest <- read.csv(paste0(where,'/mla/lyg/lyg_',name,'.csv'))
        rtest <- read.csv(paste0(where,'/mla/results/results_',name,'.csv'))
        # check that each file has correct length
        if (dim(dtest)[1]!=1820 | dim(ltest)[1]!=1820 | dim(rtest)[1]!=4040){
          print(paste0(name," MISSING ROWS"))
        }
        # check death files for negative values and unbalanced ratio
        dtest<-subset(dtest, policy_year==2016&cohort=="ALL")
        if (sum(as.numeric(dtest[,'deaths_avoided_females']))<0 | sum(as.numeric(dtest[,'deaths_avoided_males']))<0){
          print(paste0(name," NEGATIVE TOTAL DEATHS"))
        }
        if ((2*sum(as.numeric(dtest[,'deaths_avoided_females'])))< sum(dtest[,'deaths_avoided_males'])){
          print(paste0(name, " DEATH RATIO > 2"))
        }
     }
  }
}
