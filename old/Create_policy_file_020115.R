# Create policy.csv input file for SHG policy module 

setwd( "C:/Users/Jamie/Dropbox/CISNET/Policy_Module" )

# Read in calibrated modifiers
agemodifiers=read.csv("Age_effecs_Females_cleanair_01292015.csv", header=FALSE)

# inieff=0.1
inieff=0.9
# ceseff=0.5
ceseff=1.5

inidecay=0
cesdecay=0.15

iniagemod=agemodifiers[,2]
cesagemod=agemodifiers[,3]

initmod=1
cessmod=1
decayrate=0
agemod=1
agelower=0
ageupper=1
initdeploy=2015
cessdeploy=2015

for (i in 2:length(iniagemod))
{
  initmod=paste(initmod,',',1)
  cessmod=paste(cessmod,',',1)
  decayrate=paste(decayrate,',',0)
  agemod=paste(agemod,',',1)
  agelower=paste(agelower,',',i-1)
  ageupper=paste(ageupper,',',i)
  initdeploy=paste(initdeploy,',',2015)
  cessdeploy=paste(cessdeploy,',',2015)
}
baselinescenario=paste(initmod,';',cessmod,';',decayrate,';',agemod,';',agelower,';',ageupper,';',initdeploy,';',cessdeploy)


initmod=inieff
cessmod=ceseff
decayrate=cesdecay
agemod=cesagemod[1]
agelower=0
ageupper=1
for (i in 2:length(iniagemod))
{
  initmod=paste(initmod,',',inieff)
  cessmod=paste(cessmod,',',ceseff)
  decayrate=paste(decayrate,',',cesdecay)
  agemod=paste(agemod,',',cesagemod[i])
  agelower=paste(agelower,',',i-1)
  ageupper=paste(ageupper,',',i)
  initdeploy=paste(initdeploy,',',2015)
  cessdeploy=paste(cessdeploy,',',2015)
}

filehead='init_modifier; cess_modifier; decay_rate ; age_modifier; age_lower_limit; age_upper_limit; init_policy_deploy_year; cess_policy_deploy_year'
finalscenario=paste(initmod,';',cessmod,';',decayrate,';',agemod,';',agelower,';',ageupper,';',initdeploy,';',cessdeploy)
finalfile=rbind(filehead,baselinescenario,finalscenario)

write.table(finalfile,'policies_test_020115.csv',col.names=FALSE,row.names=FALSE,quote=FALSE)
