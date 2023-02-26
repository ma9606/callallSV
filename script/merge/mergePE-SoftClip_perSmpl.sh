#!/bin/sh

if [ $# -ne 2 ]; then
  echo "Usage:  ./mergePE-SoftClip_perSmpl.sh [SVlist_fromPE] [SVlist_fromSoftClip]"; exit 1;
fi

CUR=`pwd`
source ${CUR}/.rearrangement.conf

SVLIST_PE=$1	# rearrangement10.txt.extractNoL_ud0.125.filtRep
SVLIST_SC=$2	# intraBP_tested.list

$RSC/prep_compGR_mkIDlist_PE.pl  ${SVLIST_PE}  $HDR/PE/${SID}/tumor/deletion2new_sco37.r2.noL.insMax.read4up.e+3.rmMulti.rmNoPrefectMatch.cluster.txt.new 2  > .deletion_fr_cluster.txt  2> .deletion_fr_cluster.err
$RSC/prep_compGR_mkIDlist_PE.pl  ${SVLIST_PE}  $HDR/PE/${SID}/tumor/inversion2new_ff_sco37.r2.noL.read4up.e+3.rmMulti.rmNoPrefectMatch.cluster.txt.new 2  > .inversion_ff_cluster.txt  2>.inversion_ff_cluster.err
$RSC/prep_compGR_mkIDlist_PE.pl  ${SVLIST_PE}  $HDR/PE/${SID}/tumor/inversion2new_rr_sco37.r2.noL.read4up.e+3.rmMulti.rmNoPrefectMatch.cluster.txt.new 2  > .inversion_rr_cluster.txt  2>.inversion_rr_cluster.err
$RSC/prep_compGR_mkIDlist_PE.pl  ${SVLIST_PE}  $HDR/PE/${SID}/tumor/tandem_duplication2new_sco37.r2.noL.ins100up.read4up.e+3.rmMulti.rmNoPrefectMatch.cluster.txt.new 2  > .tandem_dup_rf_cluster.txt  2>.tandem_dup_rf_cluster.err
$RSC/prep_compGR_mkIDlist_PE.pl  ${SVLIST_PE}  $HDR/PE/${SID}/tumor/translocation2new_ff_sco37.r2.noL.read4up.e+3.rmMulti.rmNoPrefectMatch.cluster.txt.new 2  > .translocation_ff_cluster.txt  2>.translocation_ff_cluster.err
$RSC/prep_compGR_mkIDlist_PE.pl  ${SVLIST_PE}  $HDR/PE/${SID}/tumor/translocation2new_fr_sco37.r2.noL.read4up.e+3.rmMulti.rmNoPrefectMatch.cluster.txt.new 2  > .translocation_fr_cluster.txt  2>.translocation_fr_cluster.err
$RSC/prep_compGR_mkIDlist_PE.pl  ${SVLIST_PE}  $HDR/PE/${SID}/tumor/translocation2new_rr_sco37.r2.noL.read4up.e+3.rmMulti.rmNoPrefectMatch.cluster.txt.new 2  > .translocation_rr_cluster.txt  2>.translocation_rr_cluster.err

$RSC/compGR_PE-intraBP.pl ${SVLIST_SC}  ${SVLIST_PE}  ${SID} ${READ_LEN} $HDR/SoftClip/$SID/tumor  2   > mergePE-iBP_tested_0.list  2>mergePE-iBP_tested_0.err
