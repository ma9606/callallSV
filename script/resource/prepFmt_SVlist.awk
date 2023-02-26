#!/usr/bin/awk -f
BEGIN{
  FS="\t"
  print "Smpl\tType    \tCrd.SVj[Chr_1:BP_1|BP_2:Chr_2]\tGene_1\tGene_2\tSize\tMdf.SVj\tSupp.\tNo.Supp.Read[st(REF,VAL):p-value]\tDir_1\tAln_1\tMQmx_1\tAsmx_1\tDir_2\tAln_2\tMQmx_2\tASmx_2"

#SmplID	Type		Support	Coordinates of SV juncntion	gene at BP1(2)	Size		Junction modification	No.support read : p-value
#GC002	tandem_dup	m	chr17:5114862|28843209:chr17	SCIMP	GOSR1	23,728,347	i(GCGTGAGCGG)		t(46,4608),n(44,0):9.01e-82

#$4	$5	$3/$7,8,9/$12,13,14	$11	$16	$18	$19		$5	$22		$3	$10	$20	$21	$3	$15	$20	$21
#f1	f2	f3			f4	f5	f6	f7		f8	f9		f10	f11	f12	f13	f14	f15	f16	f17
#SID	Type	crd.SVj			Gene_1	Gene_2	Size	mdfseq.SVj	type	No.supR:p	Dir_1	Aln_1	MQmx_1	Asmx_1	Dir_2	Aln_2	MQmx_2	ASmx_2

}
{
  if($1~"^0")sup_type="pe"; else{if($1=="m")sup_type="pe/sc"; if($1=="n")sup_type="sc";}
  dir=$3
  smplID=$4
  event=$5

  chL=$7; chR=$12;
  if(dir=="FR"){edgeL=$8; bpL=$9; dirL="+"; 	bpR=$13; edgeR=$14; dirR="-"; }
  if(dir=="RF"){edgeL=$9; bpL=$8; dirL="-"; 	bpR=$14; edgeR=$13; dirR="+"; }
  if(dir=="FF"){edgeL=$8; bpL=$9; dirL="+"; 	bpR=$14; edgeR=$13; dirR="+"; }
  if(dir=="RR"){edgeL=$9; bpL=$8; dirL="-"; 	bpR=$13; edgeR=$14; dirR="-"; }

  alnL=$10
  alnR=$15

  gN=split($11,g,","); genL=g[1]; for(i=2;i<gN;i++)genL=genL","g[i];  if(length(genL)==0)genL="---";
  gN=split($16,g,","); genR=g[1]; for(i=2;i<gN;i++)genR=genR","g[i];  if(length(genR)==0)genR="---";

  size=$18;
 
  if(NF==22 && $1!~"^0"){
    if($19~"^overlap")jtype="m";
    else if($19~"^interruption")jtype="i";
    else junction="---";
    if(jtype=="m" || jtype=="i"){
      split($19,c," "); junction=jtype"("c[2]")"; jtype="";
    }
    split($20,mq,","); mqMX_L=mq[2]; mqMX_R=mq[3];
    split($21,as,","); asMX_L=as[2]; asMX_R=as[3];
    split($22,r, ","); split(r[6],p,":"); supR="t("r[1]","r[2]"),n("r[4]","r[5]"):"p[2]
  }
  else{
    junction="---";
    mqAS_L="."; mqAS_R=".";
    mqMX_L="."; mqMX_R=".";
    if(NF==22){
      split($22,r, ","); split(r[6],p,":"); supR="t("r[1]","r[2]"),n("r[4]","r[5]"):"p[2]
    }else supR="t(-,"$6")"
  }
  
  print smplID FS event FS chL":"bpL"|" bpR":"chR FS genL FS genR FS size FS junction FS sup_type FS supR FS dirL FS alnL FS mqMX_L FS asMX_L FS dirR FS alnR FS mqMX_R FS asMX_R;
# print smplID FS event FS sup_type FS chL":"bpL"|" bpR":"chR FS genL FS genR FS size FS junction FS supR FS svaf FS cnL FS cnR FS svid;
}
