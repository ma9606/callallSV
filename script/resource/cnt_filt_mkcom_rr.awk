BEGIN{
  ID="XX"
  SMPL="##"
  MXOL="NN"
}
{
  printf("$RSC/cnt_extractNoL_all_rr_trans_2.pl %s_all.sam.cla.tr.rmDup.rmMulti2.sco37.mis2.%s ../rearrangement10.txt.translocation_rr %d > rearrangement10.txt.translocation_rr.extractNoL_all%s.%s\n",SMPL,$1,MXOL,ID,$1);
}
