#!/bin/sh

if [ $# -ne 1 ]; then
  echo "Usage:  ./SVcaller_package-{n}.sh  [directory.inFiles]"; exit 1;
fi

source ./callallsv.cfg
DAT=`realpath $1`

mkdir -p ${HDR}/PE
mkdir -p ${HDR}/SoftClip

N=1;
while read SID
do
   ## step_1. Detect SV-breakpoint from paired-end reads
   CUR=${HDR}/PE/${SID}; mkdir -p $CUR
   cd $CUR
   ls ${DAT}/${SID}/tumor/*/*.sam.gz > .list.sam.tumor; 	MXINS_T=`awk -v id=${SID} '$1==id && $2=="tumor"{print $3}' $DAT/list/list.insertSize_MX`
   ls ${DAT}/${SID}/normal/*/*.sam.gz > .list.sam.normal;	MXINS_N=`awk -v id=${SID} '$1==id && $2=="normal"{print $3}' $DAT/list/list.insertSize_MX`

   ### step_1-1: detect SVs from one pair of tumor-normal samples
   ${SCR}/pe/detectGR  -i .list.sam.tumor -l ${MXINS_T}  -ni .list.sam.normal -nl ${MXINS_N} ${MEMRQ_PE}

  
   ## step_2. Detect SV-breakpoint from soft-clipped alignment
   cd ${HDR}/SoftClip/;
   for STAT in tumor normal
   do

      ### step_2-1: extract reads with soft-clipped alignment
      CUR=${HDR}/SoftClip/${SID}/${STAT}; mkdir -p $CUR
      cd ${CUR}; 
      awk -v stat=${STAT} -F"/" '{print $(NF-1)}' ${HDR}/PE/${SID}/.list.sam.${STAT} | uniq | xargs mkdir -p;

      tarjid="";
      for tardir in `ls -d */`
      do
         cd ${CUR}/${tardir}
	 awk -v dnam="/"${tardir} '$0~dnam{print}' ${HDR}/PE/${SID}/.list.sam.${STAT}  >  ./.list.samGz
	 ${RSC}/create_qArray_extract_chimericSam_v2.pl j${N} > qArray.ext-chimSam;  chmod 770 qArray.ext-chimSam
         qsub -N j${SID}_${N} -o .ext-chimSam.out -e .ext-chimSam.err ./qArray.ext-chimSam
         tarjid=${tarjid}","j${SID}_${N}
         N=`expr ${N} + 1`
      done

      tarjid=`echo ${tarjid} | cut -c2-`
      $SCR/__waiting_qjob-complete__.sh  ${tarjid}

      ### step_2-2: remove duplicated reads
      cd ${CUR}
      RLEN=`awk -v id=${SID}  '$1==id{print $2}' $DAT/list/list.readLen`
      if [ ${STAT} == "tumor" ];  then MXINS=${MXINS_T}; fi
      if [ ${STAT} == "normal" ]; then MXINS=${MXINS_N}; fi
      qsub -N j${SID}_extRd_${STAT}  $SCR/softclip/qcom.extPCRDup  ${RLEN}  ${MXINS}
      
      $SCR/__waiting_qjob-complete__.sh  j${SID}_extRd_${STAT},j${SID}_${STAT}_rmPCRDup_${RLEN}bp  ${RLEN}
      $RSC/create_qArray_rmDupSE.pl ${RLEN}  > ./qArray.RmPCRDup;   chmod 770 ./qArray.RmPCRDup
      qsub -N j${SID}_rmRd_${STAT}  -hold_jid j${SID}_extRd_${STAT}  ./qArray.RmPCRDup 

      $SCR/__waiting_qjob-complete__.sh  j${SID}_extRd_${STAT},j${SID}_rmRd_${STAT}; echo -e ""
   done

done < ${DAT}/list/list.smplID
