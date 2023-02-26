BEGIN{
  FS="\t"
}
{
  dir=$3
  smplID=$4
  event=$5
  supR=$6
  chL=substr($7,4); chR=substr($12,4);
  if(dir=="FR"){edgeL=$8; bpL=$9;  bpR=$13; edgeR=$14; }
  if(dir=="RF"){edgeL=$9; bpL=$8;  bpR=$14; edgeR=$13; }
  if(dir=="FF"){edgeL=$8; bpL=$9;  bpR=$14; edgeR=$13; }
  if(dir=="RR"){edgeL=$9; bpL=$8;  bpR=$13; edgeR=$14; }
  print $0"\t-\t"$6",38,38\t"$6",38,38"
  print "awk -v supSV="supR" \047($2=="chL" && $3=="bpL")||($2=="chR" && $3=="bpR"){s+=$1}END{if(length(s)==0)s=0; print s\042,\042supSV\042,\042supSV\042,-,-,-:-\042}\047  ./tumor/pChr_REFsupp/REFsupp_PE.bplist"
}
