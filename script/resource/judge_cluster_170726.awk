BEGIN{
  MIN_CLMEMBER = #MN_CNT# 
  MAX_SLIPPAGE = 5 
  SUM_MQ_all     = 0   	      # all reads must be SMQ >= SUM_MQ_all[0]
  SUM_MQ_contain = #MN_SMQ#   # cluster must contain one or more read whose SMQ >= SUM_MQ_contain [#MN_SMQ#]
  MIN_CLSIZE  = 20;	MIN_CLSIZE_TR  = 25;
  MIN_CLSCOR  = 30
  cnt = 0;
}
{
# print $0
  if((($1==ch1 && ($4-crdL)<=0 && ($4-crdL)<=MAX_SLIPPAGE && $9==ch2 && ($6-crdR)<=0 && ($6-crdR)<=MAX_SLIPPAGE) && ($12" "$13==tmpjc)) || NR==0){
     if($10==rID){ next }
     crdL=$4; crdR=$6;
     if(dir1~">"){if(left_edge  > $2)left_edge = $2;}  else{if(left_edge  < $2)left_edge = $2; }
     if(dir2~">"){if(right_edge < $8)right_edge = $8;} else{if(right_edge > $8)right_edge = $8;}
      
     split($(NF-1),MQ,"-"); mqL[cnt] =MQ[1]; mqR[cnt]=MQ[2];
     if(mqL[cnt]>max_mqL)max_mqL=mqL[cnt];
     if(mqR[cnt]>max_mqR)max_mqR=mqR[cnt];
     cnt++;
  }

  else {
     cnt_ovSMQ = cnt_ovSMQ_contain =0;
     for(i=0;i<cnt;i++){
        if(mqL[i]+mqR[i]>=SUM_MQ_all)cnt_ovSMQ++;
        if(mqL[i]+mqR[i]>=SUM_MQ_contain)cnt_ovSMQ_contain++;
     }
     clSizeL=crdL-left_edge;  if(dir1~"<")clSizeL=-1*(clSizeL);  clSizeL++;
     clSizeR=right_edge-crdR; if(dir2~"<")clSizeR=-1*(clSizeR);  clSizeR++;

     flg=0; 
     if(ch1!=ch2){ if((clSizeL<MIN_CLSIZE_TR && max_mqL<MIN_CLSCOR) || (clSizeR<MIN_CLSIZE_TR && max_mqR<MIN_CLSCOR)){ flg=1; }}
     else          if((clSizeL<MIN_CLSIZE    && max_mqL<MIN_CLSCOR) || (clSizeR<MIN_CLSIZE    && max_mqR<MIN_CLSCOR)){ flg=1; }

     if(cnt>=MIN_CLMEMBER && NR!=1 && flg==0){
        if(ch1 == ch2){
           if(dir1~">" && dir2~">"){
	    if(crd1<crd2){ type = "deletion";   }
	    else {         type = "tandem_dup"; }
	    arrL = "==>"; arrR = "==>"; 
           }
           if(dir1~">" && dir2~"<"){ type = "inversion_ff"; arrL = "==>"; arrR = "<==";}
           if(dir1~"<" && dir2~">"){ type = "inversion_rr"; arrL = "<=="; arrR = "==>";}
        }
        else {
	   if(dir1~">" && dir2~">"){ type = "translocation_fr"; arrL = "==>"; arrR = "==>";}
	   if(dir1~">" && dir2~"<"){ type = "translocation_ff"; arrL = "==>"; arrR = "<==";}
           if(dir1~"<" && dir2~">"){ type = "translocation_rr"; arrL = "<=="; arrR = "==>";}
        }
	printf("%s\t%9d %s\t%9d\t|\t%9d\t%s %9d\t %s\t%s\t%s\t%s\t%d,%d,%d\n", ch1,left_edge,arrL,crdL, crdR,arrR,right_edge,ch2, cnt,type,tmpjc, cnt_ovSMQ,max_mqL,max_mqR);
     }
     cnt = 0;
  }

  crdL=$4; crdR=$6; 
  ch1  = $1;  crd1L= $2; crd1 = $4;  dir1 = $3 
  ch2  = $9;  crd2 = $6; crd2R= $8;  dir2 = $7
  rID  = $10; if((NF-1)==14)mihml = $13; else mihml = "-";
  split($(NF-1),MQ,"-"); mqL[cnt] =MQ[1]; mqR[cnt]=MQ[2];
  tmpjc = $12" "$13;
  if(cnt==0){left_edge = $2; right_edge = $8; max_mqL=mqL[cnt];  max_mqR=mqR[cnt]; cnt++;}
}
END{
     cnt_ovSMQ = cnt_ovSMQ_contain =0;
     for(i=0;i<cnt;i++){
        if(mqL[i]+mqR[i]>=SUM_MQ_all)cnt_ovSMQ++;
        if(mqL[i]+mqR[i]>=SUM_MQ_contain)cnt_ovSMQ_contain++;
     }
     clSizeL=crdL-left_edge;  if(dir1~"<")clSizeL=-1*(clSizeL);  clSizeL++;
     clSizeR=right_edge-crdR; if(dir2~"<")clSizeR=-1*(clSizeR);  clSizeR++;

     flg=0; 
     if(ch1!=ch2){ if((clSizeL<MIN_CLSIZE_TR && max_mqL<MIN_CLSCOR) || (clSizeR<MIN_CLSIZE_TR && max_mqR<MIN_CLSCOR)){ flg=1; }}
     else          if((clSizeL<MIN_CLSIZE    && max_mqL<MIN_CLSCOR) || (clSizeR<MIN_CLSIZE    && max_mqR<MIN_CLSCOR)){ flg=1; }

     if(cnt>=MIN_CLMEMBER && NR!=1 && flg==0){
        if(ch1 == ch2){
           if(dir1~">" && dir2~">"){
	    if(crd1<crd2){ type = "deletion";   }
	    else {         type = "tandem_dup"; }
	    arrL = "==>"; arrR = "==>"; 
           }
           if(dir1~">" && dir2~"<"){ type = "inversion_ff"; arrL = "==>"; arrR = "<==";}
           if(dir1~"<" && dir2~">"){ type = "inversion_rr"; arrL = "<=="; arrR = "==>";}
        }
        else {
	   if(dir1~">" && dir2~">"){ type = "translocation_fr"; arrL = "==>"; arrR = "==>";}
	   if(dir1~">" && dir2~"<"){ type = "translocation_ff"; arrL = "==>"; arrR = "<==";}
           if(dir1~"<" && dir2~">"){ type = "translocation_rr"; arrL = "<=="; arrR = "==>";}
        }
	printf("%s\t%9d %s\t%9d\t|\t%9d\t%s %9d\t %s\t%s\t%s\t%s\t%d,%d,%d\n", ch1,left_edge,arrL,crdL, crdR,arrR,right_edge,ch2, cnt,type,tmpjc, cnt_ovSMQ,max_mqL,max_mqR);
     }
}
