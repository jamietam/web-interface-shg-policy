Iwp=1 ### indicator of workplace policy to be implemented 1-yes, 0-no
Ir=1  ### indicator of restaurants policy to be implemented 1-yes, 0-no
Ib=1  ### indicator of bars policy to be implemented 1-yes, 0-no

pacwp=0.0  ### percentage already covered by workplace clean air laws
pacr=0.0   ### percentage already covered by restaurants clean air laws
pacb=0.0   ### percentage already covered by bars clean air laws

inieff=0.1
ceseff=0.5

cleanaireff <- function(initeff,cesseff,pacwp,pacr,pacb,Iwp,Ir,Ib)
{
  wpre = 2/3 ## workplace attributed effect of clean air laws 
  rre = 2/9 ## restaurants attributed effect of clean air laws 
  bre = 1/9 ## bars attributed effect of clean air laws 
  
  IECap=(1-pacwp)*wpre*inieff*Iwp+(1-pacr)*rre*inieff*Ir+(1-pacb)*bre*inieff*Ib ### Initiation effect of policy
  
  CECap=(1-pacwp)*wpre*ceseff*Iwp+(1-pacr)*rre*ceseff*Ir+(1-pacb)*bre*ceseff*Ib ### Cessation effect of policy
  
  return(list=c('IECap'=IECap,'CECap'=CECap))
}

cleanaireff(initeff,cesseff,pacwp,pacr,pacb,Iwp,Ir,Ib)

