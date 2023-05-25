#!/bin/sh

LOOP_MAX=10080
SLEEP_SEC=30

STR_JOBID=$1
echo ${STR_JOBID} | awk -F"," 'NF>1{for(i=1;i<=NF;i++)print $i}' > .tar.jobids

sleep ${SLEEP_SEC}

CNT=0
while [ $CNT -lt $LOOP_MAX ];do

  echo -n "" > .tar.jobids.stat
  while read JID
  do
    qstat -j ${JID} |& awk 'NR==1{if($0~"not exist"){print 0; flg++;}}END{if(flg==0){if(NR<=2)print 0; else print 1}}' >> .tar.jobids.stat
  done < .tar.jobids  
  REMAIN=`grep ^1 .tar.jobids.stat | wc -l`

  if [ ${REMAIN} -eq 0 ]; then
    break
  else
#   echo "Not finished target jobs, wait till all ${JOBID} completed"
    sleep ${SLEEP_SEC}
    CNT=`expr ${CNT} + 1`
  fi

done

# if [ $# -eq 2 ]; then
#   RLEN=$2
#   grep -v "^[" rmPCRDup_${RLEN}bp/.rmDup_fr.err > .rmDup_fr.err
#   if [ ! -s .extPCRDup.err -a ! -s .rmDup_fr.err ]; then
#     rm rmPCRDup_${RLEN}bp/all.SA.sam.cla.*
#   fi
# fi
