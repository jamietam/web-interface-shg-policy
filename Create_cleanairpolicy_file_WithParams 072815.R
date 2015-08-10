## To run the script in linux "Rscript Create_cleanairpolicy_file_WithParams.R 1 1 1 .4 .4 .4 2015" 

# args <- commandArgs(trailingOnly = TRUE)

setwd("C:/Users/jamietam/Dropbox/CISNET/Policy_Module/")
args = c(1,1,1,0,0,0,2015)

Iwp=as.numeric(args[1]) # indicator of workplace policy to be implemented 1-yes, 0-no
Ir=as.numeric(args[2])  # indicator of restaurants policy to be implemented 1-yes, 0-no
Ib=as.numeric(args[3])  # indicator of bars policy to be implemented 1-yes, 0-no

pacwp=as.numeric(args[4])  # percentage already covered by workplace clean air laws
pacr=as.numeric(args[5])   # percentage already covered by restaurants clean air laws
pacb=as.numeric(args[6])   # percentage already covered by bars clean air laws

year = as.numeric(args[7]) # year of policy implementation

sexes = c('males','females')

cleanairiniteff <- function(initeff,pacwp,pacr,pacb,Iwp,Ir,Ib){
    wpre = 2/3 # workplace attributed effect of clean air laws 
    rre = 2/9 # restaurants attributed effect of clean air laws 
    bre = 1/9 # bars attributed effect of clean air laws 
    IECap=(1-pacwp)*wpre*inieff*Iwp+(1-pacr)*rre*inieff*Ir+(1-pacb)*bre*inieff*Ib # Initiation effect of policy
    return (IECap)  
}
  
cleanaircesseff <- function(cesseff,pacwp,pacr,pacb,Iwp,Ir,Ib){
    wpre = 2/3 # workplace attributed effect of clean air laws 
    rre = 2/9 # restaurants attributed effect of clean air laws 
    bre = 1/9 # bars attributed effect of clean air laws 
    CECap=(1-pacwp)*wpre*ceseff*Iwp+(1-pacr)*rre*ceseff*Ir+(1-pacb)*bre*ceseff*Ib # Cessation effect of policy
    return (CECap)
}
  

for (y in 1:length(sexes)){
  # Read in calibrated modifiers
  if (y==1){
    agemodifiers=read.csv("Age_effects_males_cleanair_021815.csv", header=FALSE)
  }
  if (y==2){
    agemodifiers=read.csv("Age_effects_females_cleanair_021815.csv", header=FALSE)    
  }
  # Policy inputs -----------------------------------------------------------
  inieff=0.1  ### Reduces initiation effect from 1 to 0.9 
  ceseff=0.5 ### Increases cessation effect from 1 to 1.5 
  inidecay=0
  cesdecay=0.2
  iniagemod=agemodifiers[,2]
  cesagemod=agemodifiers[,3]  
  
  # Policy scenario ---------------------------------------------------------
  
  initmod = cleanairiniteff(initeff,pacwp,pacr,pacb,Iwp,Ir,Ib)
  cessmod = cleanaircesseff(cesseff,pacwp,pacr,pacb,Iwp,Ir,Ib)
  
  initmod2 = initmod
  cessmod2 = cessmod
  
  inidecayrate=inidecay
  cessdecayrate=cesdecay
  
  initagemod=formatC(iniagemod[1],3,format="f")
  cessagemod=formatC(cesagemod[1],3,format="f")
  
  initagelower=0
  initageupper=1
  
  cessagelower=0
  cessageupper=1
  
  initdeploy=year
  cessdeploy=year
  
  for (i in 2:length(iniagemod)) {
    initmod=paste(initmod,',',initmod2,sep="")  
    cessmod=paste(cessmod,',',cessmod2,sep="")  
    
    inidecayrate=paste(inidecayrate,',',inidecay,sep="")
    cessdecayrate=paste(cessdecayrate,',',cesdecay,sep="")
    
    initagemod=paste(initagemod,',',formatC(iniagemod[i],3,format="f"),sep="")
    cessagemod=paste(cessagemod,',',formatC(cesagemod[i],3,format="f"),sep="")
    
    initagelower=paste(initagelower,',',i-1,sep="")
    initageupper=paste(initageupper,',',i,sep="")
    
    cessagelower=paste(cessagelower,',',i-1,sep="")
    cessageupper=paste(cessageupper,',',i,sep="")
    
    initdeploy=paste(initdeploy,',',year,sep="")
    cessdeploy=paste(cessdeploy,',',year,sep="")
  }
  
  filehead='init_modifier; cess_modifier; init_decay_rate; cess_decay_rate; init_age_modifier; cess_age_modifier; init_age_lower_limit; init_age_upper_limit; cess_age_lower_limit; cess_age_upper_limit; init_policy_deploy_year; cess_policy_deploy_year'
  policyscenario=paste(initmod,'; ',cessmod,'; ',inidecayrate,'; ',cessdecayrate,'; ',initagemod,'; ',cessagemod,'; ',initagelower,'; ',initageupper,'; ',cessagelower,'; ',cessageupper,'; ',initdeploy,'; ',cessdeploy,sep="")

  write.table(filehead,paste0('inputscleanair_',(sexes[y]),'_w',Iwp,'_r',Ir,'_b',Ib,'_w',pacwp,'_r',pacr, '_b',pacb,'_',year,'.csv'),col.names=FALSE,row.names=FALSE,quote=FALSE,eol='\n',)
  write.table(policyscenario,paste0('inputscleanair_',(sexes[y]),'_w',Iwp,'_r',Ir,'_b',Ib,'_w',pacwp,'_r',pacr, '_b',pacb,'_',year,'.csv'),col.names=FALSE,row.names=FALSE,quote=FALSE,eol='',append='TRUE')

  print(paste0('inputscleanair_',(sexes[y]),'_w',Iwp,'_r',Ir,'_b',Ib,'_w',pacwp,'_r',pacr, '_b',pacb,'_',year,'.csv',' has been created.')) 
}  

  
