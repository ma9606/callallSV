#!/bin/sh
abs=`realpath $0 | rev | cut -f3- -d"/" | rev`
source ${abs}/callallsv.cfg

STAT=0

## step_3. Merge SVlists from both PE and SoftClip method
cd $HDR/Merge; CUR=`pwd`
flg=0

for sid in `ls -d [A-Z][A-Z][0-9][0-9][0-9]`
do
  cd $CUR/${sid}
  ls -ltra ./ > .log.intermediate_files;

  for stderr in `ls ./.*.err`
  do 
    if [ ! -s ${stderr} ]; then
      rm ${stderr}
    else
      echo "==< "`pwd`"/"${stderr}" >=="
      head -n5 ${stderr}
      flg=1; STAT=1
    fi
  done

  if [ ! -s "./mergePE-iBP_tested_0.err" ]; then 
    rm .*_??_cluster.txt .tmp.id_* ./mergePE-iBP_tested_0.err .rearrangement.conf 
    cd $HDR/SoftClip/${sid}/tumor/
    ls -ltra ./ > .log.intermediate_files;  ls -ltra ./tmpTout/*/ >> .log.intermediate_files
    rm -r ./[0-9][0-9][0-9][0-9][0-9][0-9]_*/  ./tmpTout/
    rm  .*list* intraBP.list* .chkStat_c3.out
  else 
    echo "==< "`pwd`"/mergePE-iBP_tested_0.err >=="
    head -n5 ./mergePE-iBP_tested_0.err
    flg=1; STAT=1
  fi

  if [ $flg -eq 0 ]; then 
    cd $HDR/PE/${sid}
    rm normal/.rearrangement.conf tumor/.rearrangement.conf

    cd ./tumor
    rm ./deletion2_sco37.full.r2.all.noL.insMax.read4up.cluster.txt
    rm ./deletion2new_sco37.r2.noL.insMax.read4up.e+3.rmMulti.cluster.txt
    rm ./tandem_duplication2_sco37.full.r2.all.noL.ins100up.read4up.cluster.txt
    rm ./tandem_duplication2new_sco37.r2.noL.ins100up.read4up.e+3.rmMulti.cluster.txt
    rm ./inversion2_??_sco37.full.r2.all.noL.read4up.cluster.txt
    rm ./inversion2new_??_sco37.r2.noL.read4up.e+3.rmMulti.cluster.txt
    rm ./translocation2_??_sco37.full.r2.all.noL.read4up.cluster.txt*
    rm ./deletion2new_sco37.r2.noL.insMax.read4up.e+3.rmMulti.rmNoPrefectMatch.cluster.txt.new
    rm ./inversion2new_ff_sco37.r2.noL.read4up.e+3.rmMulti.rmNoPrefectMatch.cluster.txt.new
    rm ./inversion2new_rr_sco37.r2.noL.read4up.e+3.rmMulti.rmNoPrefectMatch.cluster.txt.new
    rm ./tandem_duplication2new_sco37.r2.noL.ins100up.read4up.e+3.rmMulti.rmNoPrefectMatch.cluster.txt.new
    rm ./translocation2new_ff_sco37.r2.noL.read4up.e+3.rmMulti.rmNoPrefectMatch.cluster.txt.new
    rm ./translocation2new_fr_sco37.r2.noL.read4up.e+3.rmMulti.rmNoPrefectMatch.cluster.txt.new
    rm ./translocation2new_rr_sco37.r2.noL.read4up.e+3.rmMulti.rmNoPrefectMatch.cluster.txt.new
  fi

done 



## step_4. Filter out SVs suspected to false positive according to their support-reads type
cd $HDR/PE; CUR=`pwd`
flg=0

for sid in `ls -d [A-Z][A-Z][0-9][0-9][0-9]`
do
  cd $CUR/${sid}/tumor
  echo -e "\n./patch_rm-multiLnk/: "  >> .log.intermediate_files
  ls -ltra ./patch_rm-multiLnk/  >> .log.intermediate_files

  cd ./patch_rm-multiLnk/

  for stderr in deletion2_sco37.full.r2.all.noL.insMax inversion2_ff_sco37.full.r2.all.noL inversion2_rr_sco37.full.r2.all.noL tandem_duplication2_sco37.full.r2.all.noL.ins100up translocation2_fr_sco37.full.r2.all.noL translocation2_ff_sco37.full.r2.all.noL translocation2_rr_sco37.full.r2.all.noL
  do
    if [ ! -s .${stderr}.read4up.cluster.err ]; then
      if [ -e .${stderr}.read4up.cluster.err ]; then rm .${stderr}.read4up.cluster.err; fi
      if [ -e ${stderr}.read4up.cluster.txt ]; then rm ${stderr}.read4up.cluster.txt; fi
    else
      echo "==< "`pwd`"/"${stderr}".read4up.cluster.err >=="
      head -n5 ${stderr}.read4up.cluster.err
      flg=1; STAT=1
    fi
  done

  if [ $flg -eq 0 ]; then 
    rm .only_PE.list
    cd ../;  rm -r ./patch_rm-multiLnk  rearrangement10new.txt rearrangement10.txt.extractNoL_ud0.125.filtRep
    cd $HDR/SoftClip/Realign/${sid};  rm intraBP*.list .tar.jobids* .rearrangement.conf
  fi

done


## patch.2: Estimate number of reference-support reads for SVs which were detected from paired-end method 
cd $HDR/PE/patch-Realign; CUR=`pwd`
flg=0;

for sid in `ls -d [A-Z][A-Z][0-9][0-9][0-9]`
do

  ## [i] make SVseq
  cd $CUR/${sid}/SVseq
  ls -ltra ./ > .log.intermediate_files

  ls .mkSVdb.err  .list_chr*.err > .tmpfile;
  while read stderr
  do
    if [ ! -s ${stderr} ]; then
      rm ${stderr}
    else
      ls -l ${stderr}.err
      echo -e "\n==< "`pwd`"/"${stderr}.err" >=="
      head -n5 ${stderr}.err
      flg=1; STAT=1
      if [ $flg -eq 1 ]; then echo "Realign_[1] SVseq: Need to check "$CUR"/Realign/"${sid}"/SVseq/"${stderr}".err"; fi
    fi
  done < .tmpfile; rm .tmpfile

  flg=0
  awk '$0=="0"{cnt++;}END{if(cnt==NR)print "rm .tar.jobids.stat .tar.jobids"}' .tar.jobids.stat > .rmids.stat.sh
  if [ -s .rmids.stat.sh ]; then
    sh .rmids.stat.sh  &&  rm .rmids.stat.sh
  else
    paste .tar.jobids .tar.jobids.stat
    flg=1; STAT=1
  fi

  if [ $flg -eq 0 ]; then 
    for cid in `ls -d chr*`
    do
      echo ${cid}":"       >> .log.intermediate_files
      ls -l ${cid}/ | head >> .log.intermediate_files
      rm -r ${cid}  .list_${cid}
    done

    find .mkSVdb.out -type f -size 0 | xargs rm
    rm .invert_nucSq.pl
  fi

  if [ ! -e SVseq_multiFa.fa.err ]; then
    rm .Joint_AddIdx.stderr .Joint_AddIdx.out 
    if [ ! -s SVseq_multiFa.err ]; then
      rm SVseq_multiFa.fa SVseq_multiFa.fa.* SVseq_multiFa.err
    fi 
  else
    echo "==< .Joint_AddIdx.stderr >=="  >> realnSV.err.log
    cat .Joint_AddIdx.stderr >> realnSV.err.log
  fi
 

  ## [ii] extract REF-supported reads
  cd $CUR/${sid}/REF
  ls -ltra ./ ./*/*/ > .log.intermediate_files
  rm .list_chr[1-9]* .list_chr[X-Y]
  cd tumor/

  flg=0
  for sqid in `ls -d [0-9][0-9][0-9][0-9][0-9][0-9]_*`
  do
    awk '$0!~"[samopen]" && length($0)>0{print}' $sqid/.cntREFsup.stderr > $sqid/.cntREFsup.err
    if [ ! -s $sqid/.cntREFsup.err ]; then
      rm $sqid/.cntREFsup.stderr $sqid/.cntREFsup.err $sqid/.cntREFsup.out
    else
      echo -e "\n==< "`pwd`"/"$sqid/.cntREFsup.err" >=="
      head -n5 ${sqid}/.cntREFsup.err
      flg=1; STAT=1
    fi
  done
  
  if [ $flg -eq 0 ]; then
    rm -r [0-9][0-9][0-9][0-9][0-9][0-9]_*
    cd ../; rmdir ./tumor
  fi

  ## [iii] Arrange [seqIDs]/[split].files to chromatin order
  cd $CUR/${sid}/tumor
  ls -ltra ./ ./*/ > .log.intermediate_files
  flg=0
  if [ ! -s ".mklist.err" ]; then rm .mklist.err .mklist.out; fi
  for tarlist in `ls ./pChr_REFsupp/REFsupp_??.bplist`
  do
    if [ ! -s ${tarlist} -o ! -e ${tarlist} ]; then 
      echo "Not created target file: "`pwd`${tarlist}
      flg=1; STAT=1
    fi
  done
  
  if [ $flg -eq 0 ]; then 
    rm -r pChr_REFsupp/  .tar.jobids*
    cd $CUR/${sid}
    rm .mergePE-iBP_tested_onlyPE.* .patch_realnPE_${sid}.stdout .rearrangement.conf .tmp.mergePE-iBP.list.PEsupR.err intraBP.list mergePE-iBP_tested.list
    cd $HDR/Merge/${sid}
  fi

done


## remove temporary reference_chrXX.fa 
if [ ${STAT} -eq 0 ]; then
 cd $HDR/
 rm ${REF}_chr[1-9] ${REF}_chr[1-2][0-9] ${REF}_chr[X-Y]
fi
