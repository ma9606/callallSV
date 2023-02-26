#!/bin/sh

if [ $# -lt 3 ]; then
  echo "Usage:  ./prepare_indatStr.sh [sampleID([A-Z][A-Z][0-9][0-9][0-9])]  [target.sam.gz]  [status(normal/tumor)]  (opt.sequencer-ID(YYMMDD_))"; exit 1;
fi

HDR=`realpath $0 | rev | cut -f3- -d"/" | rev`
source ${HDR}/callallsv.cfg

SID=$1
IN=`realpath $2`
FILENAM=`echo ${IN} | rev | cut -f1 -d"/" | rev | sed -e "s/.gz$//"`

DIR_ST=$3
if [ $3 = "tumor" ]
  then STAT="T";
elif ["$3" = "normal" ]
  then STAT="N";
fi

if [ $# -eq 4 ]
  then DIR_SQ=$4"_seq_data"
else
  SQID=`date '+%Y%m%d_%s' | cut -c3-`
  DIR_SQ=${SQID}"_seq_data"
fi

mkdir -p $SID/${DIR_ST}/${DIR_SQ}; cd $SID/${DIR_ST}/${DIR_SQ}
zcat ${IN} | $RSC/separate_samGz_into2M.pl - ${FILENAM} 
awk -F"\t" '$5==60 && $7=="="{cN=split($6,c,"[A-Z]"); if(cN==2)print c[1] FS $0}' ${FILENAM}_001 > .forStat-properly_mapped.txt 
cut -f1 .forStat-properly_mapped.txt | uniq > .estimate.readLen
awk '$10>0{print $10}' .forStat-properly_mapped.txt | sort -n | awk '{c[NR]=$1}END{print c[(NR/2)]*3}' > .estimate.insertSize_MX

gzip ${FILENAM}_[0-9][0-9][0-9]
