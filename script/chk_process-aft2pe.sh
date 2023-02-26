#!/bin/sh
abs=`realpath $0 | rev | cut -f3- -d"/" | rev`
source ${abs}/callallsv.cfg

cd $HDR/PE/
CUR=`pwd`
flg=0

# Check logs of filterGR-process [filterGR_YYYYMMDD_hh-mm-ss.log], that correspond to normal panel.
LOG=`ls ./* | grep -E filterGR_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9]-[0-9][0-9]-[0-9][0-9].log$`
if [ -z $LOG ]; then
  echo "Error occurs in filterGR process, its log file (filterGR_YYYYMMDD_hh-mm-ss.log) was not created."
  flg=1
else
  CNT_SUCCESS=`awk '$0~"successfully finished!$"{cnt++;}END{print cnt}' ${LOG}`
  CNT_ERROR=`grep -E "file size: 0$" ${LOG} | wc -l`
  if [ ${CNT_SUCCESS} -eq 4 -a ${CNT_ERROR} -ne 0 ]; then 
    echo " successfully finished\!" > .tar.txt
    echo "file size: 0$" >> .tar.txt
    egrep -f .tar.txt ${LOG}
    flg=1
  fi
fi

cd $CUR/Filtered
for svtype in deletion tandem_dup inversion_ff inversion_rr translocation_fr translocation_ff translocation_rr
do
  lc_bfr=`cat rearrangement10.txt.${svtype} | wc -l`
  lc_aft=`cat rearrangement10.txt.${svtype}.extractNoL_all1 | wc -l`
  if [ ${lc_bfr} -lt ${lc_aft} ]; then
    echo ${svtype}": Not filtered with NormalPanel (file size "${lc_bfr}" -> "${lc_aft}")"
    flg=1
  fi 
done

if [ ! -s "./simRep.intersectBed.err" ]; then
  rm ./simRep.intersectBed.err
else
  echo -e "\n==< PE/Filtered/simRep.intersectBed.err >=="
  head -n5 ./simRep.intersectBed.err 
  flg=1
fi

if [ ${flg} -eq 0 ]; then
  ls -ltra ./ > .log.intermediate_files
  rm -r 01_trans/
  rm rearrangement10.txt* 01_all.sam.cla.* .??* 

  rm ../[A-Z][A-Z][0-9][0-9][0-9]/normal/all.sam.cla.*.rmDup.rmMulti2.sco37.mis2*
fi
