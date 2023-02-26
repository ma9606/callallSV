#!/bin/sh

if [ $# -ne 1 ]
then
   echo "Usage: ./chk_rmMultiLink_only-PE.sh  [mergePE-iBP.list]"; exit
fi

source ./.rearrangement.conf

LIST=$1
RQ_CLSIZE=1.6

mkdir -p ${HDR}/PE/${SID}/tumor/patch_rm-multiLnk  &&  cd ${HDR}/PE/${SID}/tumor/patch_rm-multiLnk
cat ${LIST} > ./.only_PE.list
awk -F"\t"  -v len=$READ_LEN -v rq=$RQ_CLSIZE  '$5=="deletion"   && $3=="FR"{if($10>=len*rq && $15>=len*rq)print}' ./.only_PE.list | $RSC/patchBLAST_get_tarClust.pl -  2> .deletion2_sco37.full.r2.all.noL.insMax.read4up.cluster.err
awk -F"\t"  -v len=$READ_LEN -v rq=$RQ_CLSIZE  '$5=="tandem_dup" && $3=="RF"{if($10>=len*rq && $15>=len*rq)print}' ./.only_PE.list | $RSC/patchBLAST_get_tarClust.pl -  2> .tandem_duplication2_sco37.full.r2.all.noL.ins100up.read4up.cluster.err
awk -F"\t"  -v len=$READ_LEN -v rq=$RQ_CLSIZE  '$5=="inversion"  && $3=="FF"{if($10>=len*rq && $15>=len*rq)print}' ./.only_PE.list | $RSC/patchBLAST_get_tarClust.pl -  2> .inversion2_ff_sco37.full.r2.all.noL.read4up.cluster.err
awk -F"\t"  -v len=$READ_LEN -v rq=$RQ_CLSIZE  '$5=="inversion"  && $3=="RR"{if($10>=len*rq && $15>=len*rq)print}' ./.only_PE.list | $RSC/patchBLAST_get_tarClust.pl -  2> .inversion2_rr_sco37.full.r2.all.noL.read4up.cluster.err
awk -F"\t"  -v len=$READ_LEN -v rq=$RQ_CLSIZE  '$5=="translocation" && $3=="FF"{if($10>=len*rq && $15>=len*rq)print}' ./.only_PE.list | $RSC/patchBLAST_get_tarClust.pl -  2> .translocation2_ff_sco37.full.r2.all.noL.read4up.cluster.err
awk -F"\t"  -v len=$READ_LEN -v rq=$RQ_CLSIZE  '$5=="translocation" && $3=="RR"{if($10>=len*rq && $15>=len*rq)print}' ./.only_PE.list | $RSC/patchBLAST_get_tarClust.pl -  2> .translocation2_rr_sco37.full.r2.all.noL.read4up.cluster.err
awk -F"\t"  -v len=$READ_LEN -v rq=$RQ_CLSIZE  '$5=="translocation" && $3=="FR"{if($10>=len*rq && $15>=len*rq)print}' ./.only_PE.list | $RSC/patchBLAST_get_tarClust.pl -  2> .translocation2_fr_sco37.full.r2.all.noL.read4up.cluster.err

TAR=deletion2_sco37.full.r2.all.noL.insMax.read4up.cluster.txt
if [ -e $TAR ]; then $RSC/compClu_tar-rmMultiLnk.pl ${TAR} ../deletion2new_sco37.r2.noL.insMax.read4up.e+3.rmMulti.cluster.txt | grep ^0.; fi

TAR=tandem_duplication2_sco37.full.r2.all.noL.ins100up.read4up.cluster.txt
if [ -e $TAR ]; then $RSC/compClu_tar-rmMultiLnk.pl ${TAR} ../tandem_duplication2new_sco37.r2.noL.ins100up.read4up.e+3.rmMulti.cluster.txt | grep ^0.; fi

TAR=inversion2_ff_sco37.full.r2.all.noL.read4up.cluster.txt
if [ -e $TAR ]; then $RSC/compClu_tar-rmMultiLnk.pl ${TAR} ../inversion2new_ff_sco37.r2.noL.read4up.e+3.rmMulti.cluster.txt | grep ^0.; fi 

TAR=inversion2_rr_sco37.full.r2.all.noL.read4up.cluster.txt
if [ -e $TAR ]; then $RSC/compClu_tar-rmMultiLnk.pl ${TAR} ../inversion2new_rr_sco37.r2.noL.read4up.e+3.rmMulti.cluster.txt | grep ^0.; fi

TAR=translocation2_fr_sco37.full.r2.all.noL.read4up.cluster.txt
if [ -e $TAR ]; then $RSC/compClu_tar-rmMultiLnk.pl ${TAR} ../translocation2_fr_sco37.full.r2.all.noL.read4up.cluster.txt.read4.rm_pair-end.fr.e-1 | grep ^0.; fi

TAR=translocation2_ff_sco37.full.r2.all.noL.read4up.cluster.txt
if [ -e $TAR ]; then $RSC/compClu_tar-rmMultiLnk.pl ${TAR} ../translocation2_ff_sco37.full.r2.all.noL.read4up.cluster.txt.read4.rm_pair-end.ff.e-1 | grep ^0.; fi

TAR=translocation2_rr_sco37.full.r2.all.noL.read4up.cluster.txt
if [ -e $TAR ]; then $RSC/compClu_tar-rmMultiLnk.pl ${TAR} ../translocation2_rr_sco37.full.r2.all.noL.read4up.cluster.txt.read4.rm_pair-end.rr.e-1 | grep ^0.; fi
