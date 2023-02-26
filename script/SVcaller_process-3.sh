#!/bin/sh

if [ $# -ne 1 ]; then
  echo "Usage:  ./SVcaller_package-{n}.sh  [directory.inFiles]"; exit 1;
fi

source ./callallsv.cfg
DAT=`realpath $1`

SVLIST_PE=rearrangement_pe.filt.txt
SVLIST_SC=breakpoint_sc.filt.realn.txt

CUR=${HDR}/Merge  
mkdir -p $CUR  &&  cd $CUR

while read SID
do
   ## step_3. Merge SVlists from both PE and SoftClip method
   mkdir -p $CUR/$SID  &&  cd $CUR/$SID
   ln -s $HDR/PE/$SID/tumor/.rearrangement.conf .
   $SCR/merge/mergePE-SoftClip_perSmpl.sh  $HDR/PE/${SID}/tumor/${SVLIST_PE}  $HDR/SoftClip/${SID}/tumor/${SVLIST_SC}  > mergePE-iBP_tested_0.list
   $RSC/prepFmt_SVlist.awk  mergePE-iBP_tested_0.list  > merged_SV.list

   ## step_4. Filter out SVs suspected to false positive according to their support-reads type
   awk -F"\t" '$1=="m"{print}'  mergePE-iBP_tested_0.list  > .tmp.mergePE-iBP_tested.list
   awk -F"\t" '$1~"^0"{print}'  mergePE-iBP_tested_0.list  | $SCR/merge/chk_rmMultiLink_only-PE.sh -             >> .tmp.mergePE-iBP_tested.list
   awk -F"\t" '$1=="n"{print}'  mergePE-iBP_tested_0.list  | awk -f $SCR/merge/chk_supReads_only-SoftClip.awk -  >> .tmp.mergePE-iBP_tested.list 
   sort -k6,6nr .tmp.mergePE-iBP_tested.list > mergePE-iBP_tested.list  &&  rm .tmp.mergePE-iBP_tested.list  mergePE-iBP_tested_0.list
  
   # awk -f $RSC/prepFmt_SVlist.awk  mergePE-iBP_tested.list  > merged_SV.validated_filt.list  &&  rm mergePE-iBP_tested.list

done < ${DAT}/list/list.smplID


## patch.2: Estimate number of reference-support reads for SVs which were detected from paired-end method 
CUR=${HDR}/PE/patch-Realign
mkdir -p $CUR  && cd $CUR

while read SID
do
   mkdir -p $CUR/${SID} &&  cd $CUR/${SID}
   ln -s $HDR/PE/$SID/tumor/.rearrangement.conf .
   cp -p $HDR/Merge/${SID}/mergePE-iBP_tested.list .

   ${SCR}/patch/_realign_SVcontig_forCount_RefSupportRead_PESV.sh ${SID} ${DAT}  &> .patch_realnPE_${SID}.stdout
   while : 
   do
     if [ ! -e ./tumor/pChr_REFsupp/REFsupp_PE.bplist ]; then 
       sleep 60
     else
       ${SCR}/patch/_add_PEsupR.sh  ${SID}  > mergePE-iBP_tested.list.PEsupR
       break
     fi
   done
   
   cd ${HDR}/Merge/${SID}
   cp -p  $CUR/${SID}/mergePE-iBP_tested.list.PEsupR ./.merged_SV.validated_filt.txt  &&  rm mergePE-iBP_tested.list
   awk -f $RSC/prepFmt_SVlist.awk  ./.merged_SV.validated_filt.txt  > merged_SV.validated_filt.list

done < ${DAT}/list/list.smplID
