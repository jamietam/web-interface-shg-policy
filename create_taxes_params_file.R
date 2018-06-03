args <- commandArgs(trailingOnly = TRUE)

# setwd("C:/Users/jamietam/Dropbox/CISNET/Policy_Module/")
#args = c(5.00,0.00,2015) # initial price, federal tax increase, year of policy implementation

initprice = as.numeric(args[1]) # initial price per pack
tax = as.numeric(args[2]) # federal tax increase
year = as.numeric(args[3]) # year of policy implementation

newprice = tax+initprice
pricechange = (newprice-initprice)/((newprice+initprice)/2)

ageeffects <- cbind(0:99, # column for ages 0-99
              c(rep(0,10),rep(-2.00,90)), # Cessation elasticities by age
              c(rep(0,10),rep(-0.4,8),rep(-0.3,7),rep(-0.2,20),rep(0,55))) #Initiation Elasticities by age  
colnames(ageeffects) <- c("age","cess_elasticities", "init_elasticities")

sexes = c('males','females')

for (y in 1:length(sexes)){
  # Policy inputs -----------------------------------------------------------
  initeff <- -pricechange*ageeffects[,3] # reduces initiation effect by this amount for each age
  cesseff <- -pricechange*ageeffects[,2] # increases cessation effect by this amount for each age
  
  #inieff=0.1  ### Reduces initiation effect from 1 to 0.9 
  #ceseff=0.5 ### Increases cessation effect from 1 to 1.5 
  inidecay=0.0
  cesdecay=0.2
  iniagemod=1
  cesagemod=1  
    
  # Policy scenario ---------------------------------------------------------
    
  initmod = formatC(initeff[1],3,format="f")
  cessmod = formatC(cesseff[1],3,format="f")
    
  inidecayrate=inidecay
  cessdecayrate=cesdecay
    
  initagemod=formatC(iniagemod[1],3,format="f")
  cessagemod=formatC(cesagemod[1],3,format="f")
  initagemod2 = initagemod
  cessagemod2 = cessagemod
    
  initagelower=0
  initageupper=1
    
  cessagelower=0
  cessageupper=1
    
  initdeploy=year
  cessdeploy=year
    
  for (i in 2:length(ageeffects[,1])) {
  
    initmod=paste(initmod,',',formatC(initeff[i],3,format="f"),sep="") 
    cessmod=paste(cessmod,',',formatC(cesseff[i],3,format="f"),sep="")
    
    inidecayrate=paste(inidecayrate,',',inidecay,sep="")
    cessdecayrate=paste(cessdecayrate,',',cesdecay,sep="")
    
    initagemod=paste(iniagemod,',',initagemod,sep="") 
    cessagemod=paste(cesagemod,',',cessagemod,sep="") 
    
    initagelower=paste(initagelower,',',i-1,sep="")
    initageupper=paste(initageupper,',',i,sep="")
    
    cessagelower=paste(cessagelower,',',i-1,sep="")
    cessageupper=paste(cessageupper,',',i,sep="")
    
    initdeploy=paste(initdeploy,',',year,sep="")
    cessdeploy=paste(cessdeploy,',',year,sep="")
  }
  
  filehead='init_modifier; cess_modifier; init_decay_rate; cess_decay_rate; init_age_modifier; cess_age_modifier; init_age_lower_limit; init_age_upper_limit; cess_age_lower_limit; cess_age_upper_limit; init_policy_deploy_year; cess_policy_deploy_year'
  policyscenario=paste(initmod,'; ',cessmod,'; ',inidecayrate,'; ',cessdecayrate,'; ',initagemod,'; ',cessagemod,'; ',initagelower,'; ',initageupper,'; ',cessagelower,'; ',cessageupper,'; ',initdeploy,'; ',cessdeploy,sep="")
  
  write.table(filehead,paste0('inputstax_',(sexes[y]),'_',format(initprice,nsmall=2),'_t',format(tax,nsmall=2), '_',year,'.csv'),col.names=FALSE,row.names=FALSE,quote=FALSE,eol='\n',)
  write.table(policyscenario,paste0('inputstax_',(sexes[y]),'_',format(initprice,nsmall=2),'_t',format(tax,nsmall=2),'_',year,'.csv'),col.names=FALSE,row.names=FALSE,quote=FALSE,eol='',append='TRUE')
  
  print(paste0('inputstax_',(sexes[y]),'_',format(initprice,nsmall=2),'_t',format(tax,nsmall=2), '_',year,'.csv',' has been created.')) 

}
