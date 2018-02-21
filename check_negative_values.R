setwd("/home/jamietam/cleanair_results/deathsFeb2018")

Iwp_set = c(0,1) ### indicator of workplace policy to be implemented 1-yes, 0-no
Ir_set = c(0,1) ### indicator of restaurants policy to be implemented 1-yes, 0-no
Ib_set = c(0,1) ### indicator of bars policy to be implemented 1-yes, 0-no
pacwp_set = c(0.00,0.25,0.50,0.75,1.00) ### percentage already covered by workplace clean air laws
pacr_set = c(0.00,0.25,0.50,0.75,1.00) ### percentage already covered by restaurants clean air laws
pacb_set = c(0.00,0.25,0.50,0.75,1.00) ### percentage already covered by bars clean air laws

count=0
totalset = 1
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
            test <- read.csv(paste0('deaths_',name,'.csv'))
            if (sum(test[,'deaths_avoided_females'])<0 | sum(test[,'deaths_avoided_males'])<0){
              print(name)
            }
          }
        }
      }
    }
  }
}
