#!/bin/sh

if [ $# -ne 1 ]; then
  echo "Usage:  ./SVcaller_package-{n}.sh  [directory.inFiles]"; exit 1;
fi

source ./callallsv.cfg
DAT=`realpath $1`

### step_1-2: NormalPanel using with all normal samples for all SVs detected by paired-end method
cd ${HDR}/PE;
CUR=`pwd`

${SCR}/pe/filterGR ${DAT}/list/list.smplID


### step_2-3: make a list of somatic SV-breakpoint
cd ${HDR}/SoftClip; 
CUR=`pwd`

$RSC/create_qArray_mkBPlist_1x.pl $DAT/list/list.smplID n  > qArray_mkBPlist_1n;  chmod 770 qArray_mkBPlist_1n;  qsub -N qA.mkBP1n ./qArray_mkBPlist_1n
$RSC/create_qArray_mkBPlist_1x.pl $DAT/list/list.smplID t  > qArray_mkBPlist_1t;  chmod 770 qArray_mkBPlist_1t;  qsub -N qA.mkBP1t ./qArray_mkBPlist_1t

$SCR/__waiting_qjob-complete__.sh  qA.mkBP1n,qA.mkBP1t

N_SMPL=0;
while read SID
do
   cd $HDR/SoftClip/$SID/tumor;
   while read tardir
   do
      $SCR/softclip/mklnk-chimTlist.sh  $HDR/PE/$SID/tumor sam.cla.tr.bam  `pwd`/${tardir} sam.cla.tr.bam
   done < ./.list.seqdir

   N_SMPL=`expr ${N_SMPL} + 1`

done < ${DAT}/list/list.smplID

cd $CUR;
$RSC/create_qArray_mkBPlist_2t_NP.pl $DAT/list/list.smplID $DAT/list/list.readLen  > qArray_mkBPlist_2t_NP; chmod 770 qArray_mkBPlist_2t_NP;  
qsub  -N qA.mkBP2t -o .mkBP2t.out  -e .mkBP2t.err ./qArray_mkBPlist_2t_NP
qsub  -N q.mkNP -hold_jid qA.mkBP1n  -o .mkNP.out -e .mkNP.err $SCR/softclip/qMake-aNPfilter		# prepare directory for normal-panel [$HDR/SoftClip/Filtered/allNout]


while :
do
  date > .cur.date
  CNT=0
  while read SID
  do
    if [ -e ${SID}/tumor/intraBP.list_0_filtR_filtPEtr_wo_SVsize_ov1M  -a  .cur.date -nt ${SID}/tumor/intraBP.list_0_filtR_filtPEtr_wo_SVsize_ov1M ]; then
      CNT=`expr ${CNT} + 1`
    fi
  done < ${DAT}/list/list.smplID

  if [ ${CNT} -eq ${N_SMPL} ]; then break; fi
  sleep 60
done
qsub  -N q.mkBT -hold_jid qA.mkBP2t,q.mkNP  -o .mkBT.out -e .mkBT.err  $SCR/softclip/qMake-iBPtarget 3000000	# prepare directory for somatic SVs  [$HDR/SoftClip/Filtered/allTiB]

$SCR/__waiting_qjob-complete__.sh  qA.mkBP2t,q.mkNP,q.mkBT

cd $CUR/Filtered/allTiB;  $RSC/create_qArray_allNP.pl allNP > ./qArray.allNP.tmp; chmod 770 ./qArray.allNP.tmp		# filter-out variant detected from both tumor and normal
qsub  -N allNP -o .allNP.out -e .allNP.err ./qArray.allNP.tmp			

cd $CUR;
qsub  -N redist_aftNP -hold_jid allNP $SCR/softclip/q.redist_aft_NormalPanel $DAT/list/list.smplID	# output: $HDR/SoftClip/$SID/tumor/intraBP.list_0_filtR_filt2_aNP.list

$SCR/__waiting_qjob-complete__.sh  allNP,redist_aftNP
while read SID
do
  cp -p  $SID/tumor/intraBP.list_0_filtR_filtPEtr_wo_SVsize_ov1M  $SID/tumor/breakpoint_sc.txt
  cp -p  $SID/tumor/intraBP.list_0_filtR_filt2_aNP.list  $SID/tumor/breakpoint_sc.filt.txt
done < ${DAT}/list/list.smplID

### step_2-4: realign all reads to reconstruct contigs connected with SV breakpoints
CUR=${HDR}/SoftClip/Realign; mkdir $CUR
cd $CUR

$RSC/splitChr_wgFASTA.pl $REF

while read SID
do
  $SCR/softclip/realign_SVcontig.sh  ${SID} ${DAT}  &> .realn_SVctg_${SID}.stdout 		# $HDR/SoftClip/Realign/$SID/intraBP_tested_0.list
done < ${DAT}/list/list.smplID
