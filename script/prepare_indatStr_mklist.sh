#!/bin/sh

if [ -e ./list ]; then rm -r ./list; fi

mkdir -p ./list
ls -d [A-Z][A-Z][0-9][0-9][0-9] > ./list/list.smplID 

if [ ! -s ./list/list.smplID ]; then
  echo "This directory structure does not meet our requirements; exit(1)."
  rmdir ./list
  exit 1;
fi 

for SID in `cat ./list/list.smplID`
do

  # For files of tumor sample
  for file in `ls ${SID}/tumor/*/.estimate.insertSize_MX`
  do 
    if [ ! -s ${file} ]; then 
      echo "Some process error in prepare_indatStr_mklist.sh; exit(1)."
      if [ -e .tmp.iSize_T ]; then rm .tmp.iSize_T; fi
      exit 1;
    else
      cat ${file} >> .tmp.iSize_T
    fi
  done
  if [ -e .tmp.iSize_T ]; then
    sort -n .tmp.iSize_T | awk -v smpl=${SID} '{c[NR]=$1}END{print smpl"\ttumor\t"c[int(NR/2+1)]}' >> ./list/list.insertSize_MX
    rm .tmp.iSize_T
  else
    echo "Some process error in prepare_indatStr_mklist.sh; exit(1)."
    rm .tmp.iSize_T; exit 1
  fi

  # For files of control sample
  for file in `ls ${SID}/normal/*/.estimate.insertSize_MX`
  do 
    if [ ! -s ${file} ]; then 
      echo "Some process error in prepare_indatStr_mklist.sh; exit(1)."
      if [ -e .tmp.iSize_N ]; then rm .tmp.iSize_N; fi
      exit 1;
    else
      cat ${file} >> .tmp.iSize_N
    fi
  done
  if [ -e .tmp.iSize_N ]; then
    sort -n .tmp.iSize_N | awk -v smpl=${SID} '{c[NR]=$1}END{print smpl"\tnormal\t"c[int(NR/2+1)]}' >> ./list/list.insertSize_MX
    rm .tmp.iSize_N
  else
    echo "Some process error in prepare_indatStr_mklist.sh; exit(1)."
    rm .tmp.iSize_N; exit 1
  fi

  # Common in tumor/control 
  for file in `ls ${SID}/*or*/*/.estimate.readLen`
  do 
    if [ ! -s ${file} ]; then 
      echo "Some process error in prepare_indatStr_mklist.sh; exit(1)."
      if [ -e .tmp.readLen ]; then rm .tmp.readLen; fi
      exit 1;
    else
      cat ${file} >> .tmp.readLen
    fi
  done

  cnt=`sort -u .tmp.readLen | wc -l`
  if [ $cnt -ne 1 ]; then 
    echo "Sorry, The system does not support input data composed multiple read-length; exit(1)."
    rm .tmp.readLen; exit 1
  else 
    readLen=`sort -u .tmp.readLen`;  echo -e ${SID}$'\t'${readLen} >> ./list/list.readLen
    rm .tmp.readLen
  fi

done
