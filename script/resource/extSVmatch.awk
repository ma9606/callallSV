{ 
   MN_MATCH  = readLen*0.60 
   MX_MISMA  = readLen*0.10  
   MN_ASSCR  = readLen*0.60
#---
   MN_INSERT = 0 
   MN_ASUNQ  = readLen*0.00
#---
   lN =1 # lineNumber
   FS="\t"
}
$1!~"^@" && $2<2048{

  if( $0 ~ tmpHead ){

    NF1 = split(tmpLine, line1, FS);
    NF2 = split($0, line2, FS);

    NCG1 = split(line1[6], CG1cd, "[0-9]+");# CIGAR-code(M/D/S/H/...)
    NCG1 = split(line1[6], CG1sc, "[A-Z]"); # CIGAR-score
    CG1_MAX=0; for(i=1;i<=NCG1;i++)if(CG1cd[i+1]!="S")CG1_MAX+=CG1sc[i];
    NCG2 = split(line2[6], CG2cd, "[0-9]+");
    NCG2 = split(line2[6], CG2sc, "[A-Z]"); 
    CG2_MAX=0; for(i=1;i<=NCG2;i++)if(CG2cd[i+1]!="S")CG2_MAX+=CG2sc[i];

    split(line1[12], NM1, ":");  split(line1[14], AS1, ":");  split(line1[15], XS1, ":");
    split(line2[12], NM2, ":");  split(line2[14], AS2, ":");  split(line2[15], XS2, ":");

    if(tmpLine ~ "AS:i:0"){ NM1[3]=0; AS1[3]=0; XS1[3]=0; }
    if(     $0 ~ "AS:i:0"){ NM2[3]=0; AS2[3]=0; XS2[3]=0; }


    if((line1[3] == line2[3])	&& 				# Ref_ContigID
       ((AS1[3]-XS1[3]>=MN_ASUNQ && AS1[3]>=MN_ASSCR) || (AS2[3]-XS2[3]>=MN_ASUNQ) && AS2[3]>=MN_ASSCR) ){	# AS-XS > MN_ASUNQ

	## judgement target : softclipped-read on Fw_strand
	if(     mxis-readLen<line1[4] && line1[4]<=mxis && line1[6]!="*"){if( AS1[3]-XS1[3]>=MN_ASUNQ && AS1[3]>=MN_ASSCR  && NM1[3] <= MX_MISMA){
	    tmpCrd = line1[4]; flg=0; for(i=1;i<=NCG1;i++){
		if(CG1cd[i+1]=="S" || CG2cd[i+1]=="I"){tmpCrd = tmpCrd+CG1sc[i];}
	    	else {if(tmpCrd <= mxis+1 && mxis+1 <tmpCrd+CG1sc[i])flg=1;  tmpCrd = tmpCrd+CG1sc[i]; }
	    }
	    if(flg==1 && CG1_MAX >=MN_MATCH){
		for(i=1;i<NF1;i++)printf("%s\t",line1[i]); print line1[NF1]"\t_A";
		for(i=1;i<NF2;i++)printf("%s\t",line2[i]); print line2[NF2]"\t_b";
	    }
	}} 

	## judgement target : softclipped-read on Rv_strand
	else if( mxis-readLen<line2[4] && line2[4]<=mxis && line2[6]!="*"){if( AS2[3]-XS2[3]>=MN_ASUNQ && AS2[3]>=MN_ASSCR && NM2[3] <= MX_MISMA){
	    tmpCrd = line2[4]; flg=0; for(i=1;i<=NCG2;i++){
		if(CG2cd[i+1]=="S" || CG2cd[i+1]=="I"){tmpCrd = tmpCrd+CG2sc[i];}
	    	else {if(tmpCrd <= mxis+1 && mxis+1 <tmpCrd+CG2sc[i])flg=1;  tmpCrd = tmpCrd+CG2sc[i]; }
	    }
	    if(flg==1 && CG2_MAX >=MN_MATCH){
		for(i=1;i<NF1;i++)printf("%s\t",line1[i]); print line1[NF1]"\t_a";
		for(i=1;i<NF2;i++)printf("%s\t",line2[i]); print line2[NF2]"\t_B";
	    }
	}}

	## judgement target : PE-reads
	else if( ((line1[4]< mxis && mxis < line2[4]) || (line2[4]< mxis && mxis < line1[4])) &&
   	   ((MN_INSERT<=line1[9] && line1[9]<= mxis) || (MN_INSERT<=line2[9] && line2[9]<= mxis)) &&
	   ( CG1_MAX + CG2_MAX >=MN_MATCH) && 
	   ( NM1[3] <= MX_MISMA && NM2[3] <= MX_MISMA) && 		# No.mismatch
	   ( AS1[3]+AS2[3] >= MN_ASSCR*2) &&
	   ( CG1cd[NCG1]=="M" && CG2cd[2]=="M") &&
	   ((tFlg==81 && $2==161) || (tFlg==83 && $2==163) || (tFlg==97 && $2==145) || (tFlg==99 && $2==147)) )
	{
		for(i=1;i<NF1;i++)printf("%s\t",line1[i]); print line1[NF1]"\t_R1";
		for(i=1;i<NF2;i++)printf("%s\t",line2[i]); print line2[NF2]"\t_R2";
	}

     }
   }
   if(lN%2==0){tFlg =  0; tmpLine = "";}
   else       {
       tFlg = $2; tmpLine = $0; tmpHead =$1;
   }
   lN++;
}
