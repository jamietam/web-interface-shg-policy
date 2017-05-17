## To run the script in linux "Rscript Create_tcexppolicy_file_WithParams.R 0.00 1.00 2016" 

args <- commandArgs(trailingOnly = TRUE)
# setwd("C:/Users/jamietam/Dropbox/GitHub/web-interface-shg-policy/mla")
# args = c(0.00,1.00,2016)

initexp = as.numeric(args[1])
finalexp = as.numeric(args[2])
year = as.numeric(args[3]) # year of policy implementation

name = paste0('initexp',format(initexp,nsmall=2),'_policyexp',format(finalexp,nsmall=2),'_',year)

geteffects <- function(x){ #x = funding level
  ycess = 0.3940805133*x^4 - 0.9200149349*x^3 + 0.6071506451*x^2 + 0.0190352116*x - 0.0002057556
  yinit = 0.3932628863*x^4 - 0.9641575962*x^3 + 0.6483267630*x^2 + 0.0473525464*x + 0.0002134081
  return(c(max(yinit,0),max(ycess,0))) # effects cannot be negative.
}

# Policy inputs -----------------------------------------------------------
cesseff = 1 + (geteffects(finalexp)[2] - geteffects(initexp)[2]) # Increases cessation probabilities by 10% when going from 0% to 100% CDC recs
cesseff = rep(cesseff,100) # assume same effect for all ages

initeff = 1 - (geteffects(finalexp)[1] - geteffects(initexp)[1]) # Decreases initiation probabilities by 12.5% when going from 0% to 100% CDC recs
initeff = rep(initeff,100) # assume same effect for all ages

inidecay=0.0
cesdecay=0.2
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
    
  for (i in 2:100) {
  
    initmod=paste(initmod,',',formatC(initeff[i],4,format="f"),sep="") 
    cessmod=paste(cessmod,',',formatC(cesseff[i],4,format="f"),sep="")
    
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
  
  write.table(filehead,paste0('inputstcexp_',(sexes[y]),'_',name,'.csv'),col.names=FALSE,row.names=FALSE,quote=FALSE,eol='\n',)
  write.table(policyscenario,paste0('inputstcexp_',(sexes[y]),'_',name,'.csv'),col.names=FALSE,row.names=FALSE,quote=FALSE,eol='',append='TRUE')
  
  print(paste0('inputstcexp_',(sexes[y]),'_',name,'.csv',' has been created.')) 

}
