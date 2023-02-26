BEGIN{
  FS="\t"
}
{
  dir=$3;
  smplID=$4;
  event=$5;
  if(event=="inversion" || event=="translocation"){event=event"_"tolower(dir);}
  supR=$6;
  chL=$7; chR=$12;

  if(dir=="FR"){edgeL=$8; bpL=$9; arrL=" ==>";  bpR=$13; edgeR=$14;  arrR="==> ";}
  if(dir=="RF"){edgeL=$13; bpL=$14; arrL=" ==>";  bpR=$8; edgeR=$9;  arrR="==> ";}
  if(dir=="FF"){edgeL=$8; bpL=$9; arrL=" ==>";  bpR=$14; edgeR=$13;  arrR="<== ";}
  if(dir=="RR"){edgeL=$9; bpL=$8; arrL=" <==";  bpR=$13; edgeR=$14;  arrR="==> ";}

  if(NF==18){	# in: PE-detected format
     microhom="-";
     printf "%s\t%9d%s\t%9d\t|\t%9d\t%s%9d\t %s\t%d\t%s\t%s\t%d,38,38\t%d,38,38\n", chL,edgeL,arrL,bpL,bpR,arrR,edgeR,chR,supR,event, microhom, supR,supR;
  }else{	# in: mergePE-iBP format
     microhom=$19;
     infoMS=$20;
     infoAS=$21;
     printf "%s\t%9d%s\t%9d\t|\t%9d\t%s%9d\t %s\t%d\t%s\t%s\t%s\t%s\n", chL,edgeL,arrL,bpL,bpR,arrR,edgeR,chR,supR,event, microhom, infoMS,infoAS;
  }
}
