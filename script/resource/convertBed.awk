{ 
   sL=$2;eL=$4;codeL="_#";  if($3~"<"){sL=$4;eL=$2;codeL="#_";} 
   sR=$6;eR=$8;codeR="#_";  if($7~"<"){sR=$8;eR=$6;codeR="_#";} 

   
   if(NF==14){ split($14,mq,","); note=$10", "$11", "$12$13", "; }
   else {      split($13,mq,","); note=$10", "$11", "; }

   print $1"\t"sL"\t"eL"\t"codeL"\t"note mq[2]"\t"eL-sL; 
   print $9"\t"sR"\t"eR"\t"codeR"\t"note mq[3]"\t"eR-sR;
}
