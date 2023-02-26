#!/bin/sh

ADIR0=$1; SUFFIX_0=$2
ADIR1=$3; SUFFIX_1=$4

cd ${ADIR1}
TDIR1=`echo ${ADIR1} | rev | cut -f1 -d"/" | rev`
awk -F"/" -v tardir=${TDIR1} '$1==tardir{print $2}' ../.chimT.list | sed -e "s/.chim/.${SUFFIX_0}/" > .tmp.ln.tar

while read fnam
do
  lnam=`echo ${fnam} | sed -e "s/${SUFFIX_0}/${SUFFIX_1}/"`
  ln -s ${ADIR0}/${fnam} ./${lnam}
done < ./.tmp.ln.tar
