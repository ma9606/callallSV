#!/bin/sh

source ../../callallsv.cfg

if [ $# -ne 2 ]; then
  echo "Usage:  ./realign_SVcontig.sh [sampleID] [directory.inFiles]"; exit 1;
fi
SID=$1
DAT=$2

RLN=$HDR/SoftClip/Realign/${SID}; mkdir -p ${RLN} && cd ${RLN}
sed -e "s/^MAPQ=/# MAPQ=/" $HDR/PE/${SID}/tumor/.rearrangement.conf > ./.rearrangement.conf;  echo "MAPQ=1" >> ./.rearrangement.conf
source .rearrangement.conf

ln -s ${HDR}/SoftClip/${SID}/tumor/intraBP.list_0_filtR_filt2_aNP.list  ./intraBP.list

# ===================
# [1] make SVseq
# ===================
  CUR=$RLN/SVseq
  mkdir -p $CUR && cd ${CUR}
  qsub -N j${SID}_SVdb  ${SCR}/softclip/qArray.mkSVdb
  qsub -N qIdx${SID} -hold_jid j${SID}_SVdb -o .Joint_AddIdx.out -e .Joint_AddIdx.stderr ${SCR}/softclip/q.Joint_AddIdx ../intraBP.list  SVseq_multiFa


$SCR/__waiting_qjob-complete__.sh  j${SID}_SVdb,qIdx${SID}
# =====================================
# [2] BWA mapping to reconstruct_SVseq
# =====================================
  CUR=$RLN/BWA
  mkdir -p $CUR

  tarjid="";
  for STAT in tumor normal
  do
     while read tardir
     do
        mkdir -p $CUR/${STAT}/${tardir}
        cd $CUR/${STAT}/${tardir}
        grep ${tardir} $HDR/SoftClip/${SID}/${STAT}/.chim?.list | sed  -e "s|^|${DAT}/${SID}/${STAT}/|"  -e "s/.chim/.sam.gz/" > .list.samGz
        $RSC/create_qArray_bwamem_T0_tarSV_gzSam.pl ${READ_LEN}  ${MXINS_T}  j${SID}_bwa_${tardir} > qArray.remap_onContig;  chmod 770 qArray.remap_onContig
        qsub -N j${SID}_bwa_${tardir} -o .remapCtg.out -e .remapCtg.err ./qArray.remap_onContig
        tarjid=${tarjid}","j${SID}_bwa_${tardir}

     done < $HDR/SoftClip/${SID}/${STAT}/.list.seqdir
  done

# ===============================
# [3] extract REF-supported reads
# ===============================
  CUR=$RLN/REF
  mkdir -p $CUR && cd $CUR

  for CHRID in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y
  do
     awk -v cid=${CHRID} '{print "chr" cid "\t" $0}' ../SVseq/.list_chr${CHRID} > ./.list_chr${CHRID}
  done

  for STAT in tumor normal
  do
     while read tardir
     do
        mkdir -p $CUR/${STAT}/${tardir}
        cd $CUR/${STAT}/${tardir}
        $RSC/create_qArray_extSupREF.pl ${DAT}/${SID}/${STAT}/${tardir}  ${MXINS_T} > qArray.cnt_referenceSupRead;  chmod 770 qArray.cnt_referenceSupRead
        qsub -N j${SID}_ref_${tardir} -o .cntREFsup.out -e .cntREFsup.stderr ./qArray.cnt_referenceSupRead
        tarjid=${tarjid}","j${SID}_ref_${tardir}

     done < $HDR/SoftClip/${SID}/${STAT}/.list.seqdir
  done


tarjid=`echo ${tarjid} | cut -c2-`;  $SCR/__waiting_qjob-complete__.sh  ${tarjid} 
# =========================================================
# [4.0] Arrange [seqIDs]/[split].files to chromatin order 
# =========================================================
  cd ${RLN}
  for STAT in tumor normal
  do 
     mkdir -p $RLN/${STAT};  cd $RLN/${STAT}/
     qsub -N j${SID}_ls_${STAT} $SCR/softclip/q.mklist_pChr ${STAT} ${MXINS_T}
  done


$SCR/__waiting_qjob-complete__.sh  j${SID}_ls_tumor,j${SID}_ls_normal
# ========================================================================
# [4] Count No.support-reads per four categories{T-REF, T-SV, N-REF, N-SV}
# ========================================================================
  cd ${RLN}
  split -l 100 ./intraBP.list -d -a 4 intraBP.list_p
  $RSC/create_qArray_addCnt_split-iBPlist.pl  intraBP.list_p  ${MXINS_T}  > qArray.split_addCnt;  chmod 770 qArray.split_addCnt;  
  qsub -N j${SID}_addCnt ./qArray.split_addCnt;
  qsub -N j${SID}_Ftest -hold_jid j${SID}_addCnt $SCR/softclip/q.testFisher

$SCR/__waiting_qjob-complete__.sh j${SID}_addCnt,j${SID}_Ftest
  cp -p ./intraBP_tested.list $HDR/SoftClip/${SID}/tumor/breakpoint_sc.filt.realn.txt
