#!/bin/sh

source ./.rearrangement.conf
SID=$1

grep $'\t'${SID}$'\t' ./mergePE-iBP_tested.list | grep ^0. | awk -f $RSC/add_count-PEsupR.awk - | grep ^0. > _L
grep $'\t'${SID}$'\t' ./mergePE-iBP_tested.list | grep ^0. | awk -f $RSC/add_count-PEsupR.awk - | grep -v ^0. > _R.sh
sh _R.sh | paste _L - > .tmp.mergePE-iBP.list.PEsupR  2> .tmp.mergePE-iBP.list.PEsupR.err
cat ./mergePE-iBP_tested.list .tmp.mergePE-iBP.list.PEsupR | sort | awk '$1~"^0.0"{if(NR!=1 && $0~tmp)print $0; tmp=$0}$1!~"^0.0"{print}' | sort -k6,6nr  &&  rm _R.sh _L .tmp.mergePE-iBP.list.PEsupR
