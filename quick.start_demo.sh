#!/bin/sh

source ./callallsv.cfg

##_Step-0: PATH check_##
if [ ! -e $HDR ]; then  echo "Error: Can't find \$HDR: "$HDR; exit 1; fi
if [ ! -e $REF ]; then  echo "Error: Can't find \$REF: "$REF; exit 1; else  echo -e "As reference genome, the system used '$REF'"; fi
if [ ! -e $REF_FAI ]; then  echo "Error: Can't find \$REF_FAI: "$REF_FAI; exit 1; else  echo -e "As reference genome index, the system used '$REF_FAI'"; fi

echo "The following items are used in the system, please check their version:"
if [ ! -e $BWA_DIR/bwa ]; then  echo "Error: Can't find \$BWA_DIR: "$BWA_DIR/bwa; exit 1; else abs=`which $BWA_DIR/bwa`; echo "  "$abs; fi
if [ ! -e $SAMTOOLS_DIR/samtools ]; then  echo "Error: Can't find \$SAMTOOLS_DIR/samtools: "$SAMTOOLS_DIR/samtools; exit 1; else abs=`which $SAMTOOLS_DIR/samtools`; echo "  "$abs; fi
if [ ! -e $BEDTOOLS_DIR/intersectBed ]; then  echo "Error: Can't find \$BEDTOOLS_DIR/bedtools: "$BEDTOOLS_DIR/bedtools; exit 1; else abs=`which $BEDTOOLS_DIR/intersectBed`; echo "  "$abs; fi
if [ ! -e $R_DIR/R ]; then  echo "Error: Can't find \$R_DIR/R: "$R_DIR/R; exit 1; else  abs=`which $R_DIR/R`; echo "  "$abs; fi



##_Step1_##
$SCR/SVcaller_process-1.sh demo_inFiles &> .SVcaller_process-1.stdout 

 echo -e "\n__Filesize check : __"  >> .SVcaller_process-1.stdout
 ls -l PE/AN???/tumor/rearrangement10new.txt  >> .SVcaller_process-1.stdout

$SCR/chk_process-aft1.sh &> .chk_process-aft1.stdout


##_Step2_##
$SCR/SVcaller_process-2.sh demo_inFiles &> .SVcaller_process-2.stdout 

 echo -e "\n__Filesize check : __"  >> .SVcaller_process-2.stdout 
 ls -l PE/Filtered/rearrangement10.txt.extractNoL_all1_merge_all_ud0.125.filtRep  >> .SVcaller_process-2.stdout
 ls -l PE/AN???/tumor/rearrangement10.txt.extractNoL_ud0.125.filtRep 		  >> .SVcaller_process-2.stdout
 ls -l SoftClip/AN???/tumor/intraBP.list_0_filtR_filt2_aNP.list 		  >> .SVcaller_process-2.stdout
 ls -l SoftClip/Realign/AN???/intraBP_tested.list				  >> .SVcaller_process-2.stdout
$SCR/chk_process-aft2pe.sh &> .chk_process-aft2pe.stdout 
$SCR/chk_process-aft2sc.sh &> .chk_process-aft2sc.stdout 


##_Step3_##
$SCR/SVcaller_process-3.sh demo_inFiles &>.SVcaller_process-3.stdout

 echo -e "\n__Filesize check : __"  >> .SVcaller_process-3.stdout
 ls -l Merge/AN???/merged_SV.list  　　　>> .SVcaller_process-3.stdout
 ls -l Merge/AN???/merged_SV.validated_filt.list　　　>> .SVcaller_process-3.stdout
$SCR/chk_process-aft3.sh &> .chk_process-aft3.stdout 

##_for_Error-Report_##
# tar cvf result.tar .SVcaller_process-?.stdout .chk_process-aft*.stdout PE SoftClip Merge 
