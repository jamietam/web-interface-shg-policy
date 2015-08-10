# Create policy.csv input file for SHG policy module 
rm(list=ls())
setwd( "C:/Users/jamietam/Dropbox/CISNET/Policy_Module" )

# Read in calibrated modifiers
agemodifiers=read.csv("Age_effects_male_cleanair_021815.csv", header=FALSE)



# Policy inputs -----------------------------------------------------------
inieff=0.1  ### Reduces initiation effect from 1 to 0.9 
ceseff=0.5 ### Increases cessation effect from 1 to 1.5 
inidecay=0
cesdecay=0.2
iniagemod=agemodifiers[,2]
cesagemod=agemodifiers[,3]

# Baseline scenario -------------------------------------------------------
initmod=formatC(0.0,1,format="f")
cessmod=formatC(0.0,1,format="f")

inidecayrate=formatC(0,1,format="f")
cessdecayrate=formatC(0,1,format="f")

initagemod=formatC(1.0,1,format="f")
cessagemod=formatC(1.0,1,format="f")

initagelower=0
initageupper=1

cessagelower=0
cessageupper=1

initdeploy_b=2015
cessdeploy_b=2015

one = formatC(1.0,1,format="f")
zero = formatC(0,1,format="f")

for (i in 2:length(iniagemod))
{
  initmod=paste(initmod,',',zero,sep="")
  cessmod=paste(cessmod,',',zero,sep="")
  
  inidecayrate=paste(inidecayrate,',',zero,sep="")
  cessdecayrate=paste(cessdecayrate,',',zero,sep="")
  
  initagemod=paste(initagemod,',',one,sep="")
  cessagemod=paste(cessagemod,',',one,sep="")
  
  initagelower=paste(initagelower,',',i-1,sep="")
  initageupper=paste(initageupper,',',i,sep="")
  
  cessagelower=paste(cessagelower,',',i-1,sep="")
  cessageupper=paste(cessageupper,',',i,sep="")
  
  initdeploy_b=paste(initdeploy_b,',',2015,sep="")
  cessdeploy_b=paste(cessdeploy_b,',',2015,sep="")
}

baselinescenario=paste(initmod,'; ',cessmod,'; ',inidecayrate,'; ',cessdecayrate,'; ',initagemod,'; ',cessagemod,'; ',initagelower,'; ',initageupper,'; ',cessagelower,'; ',cessageupper,'; ',initdeploy_b,'; ',cessdeploy_b,sep="")


# Policy scenario ---------------------------------------------------------
initmod=inieff
cessmod=ceseff

inidecayrate=inidecay
cessdecayrate=cesdecay

initagemod=formatC(iniagemod[1],3,format="f")
cessagemod=formatC(cesagemod[1],3,format="f")

initagelower=0
initageupper=1

cessagelower=0
cessageupper=1

initdeploy=2015
cessdeploy=2015

for (i in 2:length(iniagemod))
{
  initmod=paste(initmod,',',inieff,sep="")
  cessmod=paste(cessmod,',',ceseff,sep="")
  
  inidecayrate=paste(inidecayrate,',',inidecay,sep="")
  cessdecayrate=paste(cessdecayrate,',',cesdecay,sep="")
  
  initagemod=paste(initagemod,',',formatC(iniagemod[i],3,format="f"),sep="")
  cessagemod=paste(cessagemod,',',formatC(cesagemod[i],3,format="f"),sep="")
  
  initagelower=paste(initagelower,',',i-1,sep="")
  initageupper=paste(initageupper,',',i,sep="")

  cessagelower=paste(cessagelower,',',i-1,sep="")
  cessageupper=paste(cessageupper,',',i,sep="")

  initdeploy=paste(initdeploy,',',2015,sep="")
  cessdeploy=paste(cessdeploy,',',2015,sep="")
}

filehead='init_modifier; cess_modifier; init_decay_rate; cess_decay_rate; init_age_modifier; cess_age_modifier; init_age_lower_limit; init_age_upper_limit; cess_age_lower_limit; cess_age_upper_limit; init_policy_deploy_year; cess_policy_deploy_year'
policyscenario=paste(initmod,'; ',cessmod,'; ',inidecayrate,'; ',cessdecayrate,'; ',initagemod,'; ',cessagemod,'; ',initagelower,'; ',initageupper,'; ',cessagelower,'; ',cessageupper,'; ',initdeploy,'; ',cessdeploy,sep="")
finalfile=rbind(filehead,baselinescenario)

write.table(finalfile,'policies.csv',col.names=FALSE,row.names=FALSE,quote=FALSE,eol='\n')
write.table(policyscenario,'policies.csv',col.names=FALSE,row.names=FALSE,quote=FALSE,eol='',append='TRUE')

