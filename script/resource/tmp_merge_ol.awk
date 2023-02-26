BEGIN{
  tmp="##"
  FS="\t"
}
{
  if(tmp!~$3 || tmp!~$6 || tmp!~$7 || tmp!~$8 || tmp!~$10 || tmp!~$11 || tmp!~$12){
    if(cnt!=0)printf("%d\t%s\n",cnt,tmp_line); 
#    print tmp_line
    tmp=$3$6$7$8$10$11$12; 
    tmp_line=$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17; 
    cnt=$1
  } 
  else{cnt+=$1}
}
END{
  print cnt"\t"tmp_line
}
