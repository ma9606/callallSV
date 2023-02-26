#!/bin/sh

source ./.rearrangement.conf

if [ $# -ne 2 ]; then
  echo "Usage:  ./realign_SVcontig.sh [sampleID] [directory.inFiles]"; exit 1;
fi
SID=$1
DAT=$2
RLN=$HDR/PE/patch-Realign/${SID}; mkdir -p ${RLN} && cd ${RLN}

awk '$1~"^0."{print}' ./mergePE-iBP_tested.list > .mergePE-iBP_tested_onlyPE.list
awk -f $RSC/convFmt_PE-iBP.awk .mergePE-iBP_tested_onlyPE.list > .mergePE-iBP_tested_onlyPE.intraBP-fmt.list
ln -s .mergePE-iBP_tested_onlyPE.intraBP-fmt.list ./intraBP.list

# ===================
# [i] make SVseq
# ===================
  CUR=$RLN/SVseq
  mkdir -p $CUR && cd ${CUR}
  qsub -N j${SID}_SVdb  ${SCR}/softclip/qArray.mkSVdb
  qsub -N qIdx${SID} -hold_jid j${SID}_SVdb -o .Joint_AddIdx.out -e .Joint_AddIdx.stderr  ${SCR}/softclip/q.Joint_AddIdx ../intraBP.list  SVseq_multiFa


$SCR/__waiting_qjob-complete__.sh  j${SID}_SVdb,qIdx${SID}
# ===============================
# [ii] extract REF-supported reads
# ===============================
  CUR=$RLN/REF
  mkdir -p $CUR && cd $CUR

  for CHRID in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y
  do
     awk -v cid=${CHRID} '{print "chr" cid "\t" $0}' ../SVseq/.list_chr${CHRID} > ./.list_chr${CHRID}
  done

  for STAT in tumor
  do
     while read tardir
     do
        mkdir -p $CUR/${STAT}/${tardir}
        cd $CUR/${STAT}/${tardir}
        $RSC/create_qArray_extSupREF.pl ${DAT}/${SID}/${STAT}/${tardir}  ${MXINS_T} > qArray.cnt_referenceSupRead;  chmod 770 qArray.cnt_referenceSupRead
        qsub -N j${SID}_ref_${tardir}  -o .cntREFsup.out -e .cntREFsup.stderr  ./qArray.cnt_referenceSupRead
        tarjid=${tarjid}","j${SID}_ref_${tardir}

     done < $HDR/SoftClip/${SID}/${STAT}/.list.seqdir
  done


tarjid=`echo ${tarjid} | cut -c2-`;  $SCR/__waiting_qjob-complete__.sh  ${tarjid} 
# ========================================================
# [iii] Arrange [seqIDs]/[split].files to chromatin order
# ========================================================
  cd ${RLN}
  for STAT in tumor 
  do 
     mkdir -p $RLN/${STAT};  cd $RLN/${STAT}/
     qsub -N j${SID}_ls_${STAT} -o .mklist.out -e .mklist.err $SCR/patch/_q.mklist_supREF_PE ${STAT} ${MXINS_T}
  done

  $SCR/__waiting_qjob-complete__.sh  j${SID}_ls_${STAT}; echo -n ""
