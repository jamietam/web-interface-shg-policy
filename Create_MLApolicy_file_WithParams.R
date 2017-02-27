## To run the script in linux "Rscript Create_cleanairpolicy_file_WithParams.R 1 1 1 .4 .4 .4 2015" 

# args <- commandArgs(trailingOnly = TRUE)
setwd("C:/Users/jamietam/Dropbox/GitHub/web-interface-shg-policy/mla")
args = c(19,1.0,0.0,2016)

I19= ifelse(args[1]==19,1,0)
I21= ifelse(args[1]==21,1,0)
I25= ifelse(args[1]==25,1,0)
pac19=as.numeric(args[2])
pac21=as.numeric(args[3])
year = as.numeric(args[4]) # year of policy implementation

ageeffects <- cbind(0:99, # column for ages 0-99
              c(rep(0.05,15),rep(0.10,4),rep(0.0,81)), # effect 19
			        c(rep(0.15,15),rep(0.25,3),rep(0.15,3),rep(0.0,79)), # effect 21
              c(rep(0.15,15),rep(0.30,3),rep(0.20,3),rep(0.05,5),rep(0.0, 74))) # effect 25
colnames(ageeffects) <- c("age","eff_19", "eff_21","eff_25")

# Policy inputs -----------------------------------------------------------
# reduces initiation effect by this amount for each age
initeff = I19*(ageeffects[,"eff_19"]*(1-pac19-pac21))+ 
          I21*(ageeffects[,"eff_21"]*(1-pac19-pac21)+(ageeffects[,"eff_21"]-ageeffects[,"eff_19"])*pac19)+
          I25*(ageeffects[,"eff_25"]*(1-pac19-pac21)+(ageeffects[,"eff_25"]-ageeffects[,"eff_19"])*pac19+(ageeffects[,"eff_25"]-ageeffects[,"eff_21"])*pac21)

cesseff = rep(0,100) # no cessation effect (scales all cessation by 0)

inidecay=0.0
cesdecay=0.0
iniagemod=1
cesagemod=1  

sexes = c('males','females')

for (y in 1:length(sexes)){

  # Policy scenario ---------------------------------------------------------
  initmod = formatC(initeff[1],format="f")
  cessmod = formatC(cesseff[1],format="f")
    
  inidecayrate=inidecay
  cessdecayrate=cesdecay
    
  initagemod=formatC(iniagemod[1],1,format="f")
  cessagemod=formatC(cesagemod[1],1,format="f")
  initagemod2 = initagemod
  cessagemod2 = cessagemod
    
  initagelower=0
  initageupper=1
    
  cessagelower=0
  cessageupper=1
    
  initdeploy=year
  cessdeploy=year
    
  for (i in 2:length(ageeffects[,1])) {
  
    initmod=paste(initmod,',',formatC(initeff[i],4,format="f"),sep="") 
    cessmod=paste(cessmod,',',formatC(cesseff[i],1,format="f"),sep="")
    
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
  
  write.table(filehead,paste0('inputsmla_',(sexes[y]),'_',format(args[1]),'_pac19_',format(pac19,nsmall=2),'_pac21_',format(pac21,nsmall=2),'_',year,'.csv'),col.names=FALSE,row.names=FALSE,quote=FALSE,eol='\n',)
  write.table(policyscenario,paste0('inputsmla_',(sexes[y]),'_',format(args[1]),'_pac19_',format(pac19,nsmall=2),'_pac21_',format(pac21,nsmall=2),'_',year,'.csv'),col.names=FALSE,row.names=FALSE,quote=FALSE,eol='',append='TRUE')
  
  print(paste0('inputsmla_',(sexes[y]),'_',format(args[1]),'_pac19_',format(pac19,nsmall=2),'_pac21_',format(pac21,nsmall=2),'_',year,'.csv',' has been created.')) 

}
