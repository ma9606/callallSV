BEGIN{
  FS="\t"
}
{
  n_supR = split($NF,supR,","); 
  supR_PE = supR[3]; 
  supR_sc = supR[2] - supR[3];  
  supR_rf = $6
  mapT = supR[1] + supR[2];
  mapN = supR[4] + supR[5];

  split(supR[n_supR],val,":");	
  p = val[2];

  split($(NF-1),a,","); if(a[2]<a[3])minAX=a[2]; else minAX=a[3];
  split($(NF-2),m,","); if(m[2]<m[3])minMQ=m[2]; else minMQ=m[3];

  if($0~"translocation"){
    if(supR_PE != "-"){
      if( (supR_PE>=4 && ((supR_sc+supR_PE>=8)||(supR_rf+supR_PE>=8))) && (mapN>=20) && (minAX>=2 && minMQ >0) )print;
    }
  }
  else {
    if(supR_PE == "-"){
      if( (              ((supR_sc        >=4)||(supR_rf        >=4))) && (mapN>= 5) && (minAX>=2 && minMQ>=0) )print;
    }else{
      if( (supR_PE>=2 && ((supR_sc+supR_PE>=4)||(supR_rf+supR_PE>=4))) && (mapN>= 5) && (minAX>=2 && minMQ>=0) )print;
    }
  }
}
