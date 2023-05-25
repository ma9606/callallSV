#!/bin/sh
abs=`realpath $0 | rev | cut -f3- -d"/" | rev`
source ${abs}/callallsv.cfg

cd $HDR/SoftClip/
CUR=`pwd`

flg=0

## mklist.2t: count SV support PEread 
for sid in `ls -d [A-Z][A-Z][0-9][0-9][0-9]`
do
  cd $CUR/${sid}/tumor
  for stderr in .ext_supPE .aft_ext_supPE
  do
    if [ ! -s ${stderr}.err ]; then
      rm ${stderr}.out ${stderr}.err; if [ -e qArray${stderr} ];then rm qArray${stderr}; fi
    else
      echo -e "\n==< "`pwd`"/"${stderr}.err" >=="
      head -n5 ${stderr}.err
      flg=1
      if [ $flg -eq 1 ]; then echo -e "\nmklist.2t: Need to check "$CUR"/"${sid}"/tumor/"${stderr}".err"; fi
    fi
  done
  
  if [ $flg -eq 0 ]; then
    for sqdir in `ls -d ./[0-9][0-9][0-9][0-9][0-9][0-9]_*`
    do
      rm  ${sqdir}/*.supPE.out  ${sqdir}/*.supPE.list_0  ${sqdir}/*.idlist 
    done
  fi
done


## make SVlists and filter them with NormalPanel
cd $CUR/
for stderr in .mkBP1t .mkBP1n .mkNP .mkBP2t .mkBT .redist_aftNP
do
  if [ ! -s ${stderr}.err ]; then
    rm ${stderr}.out ${stderr}.err
  else
    ls -l ${stderr}.err
    echo -e "\n==< "`pwd`"/"${stderr}.err" >=="
    head -n5 ${stderr}.err
    flg=1
    if [ $flg -eq 1 ]; then echo -e "\nmkSVlist ~ NormalPanel: Need to check "$CUR"/"${stderr}".err"; fi
  fi
done

awk '$0=="0"{cnt++;}END{if(cnt==NR)print "rm .tar.jobids.stat .tar.jobids"}' .tar.jobids.stat > .rmids.stat.sh
if [ -s .rmids.stat.sh ]; then
  sh .rmids.stat.sh  &&  rm .rmids.stat.sh
else
  paste .tar.jobids .tar.jobids.stat
  flg=1
  if [ $flg -eq 1 ]; then echo "mkSVlist ~ NormalPanel: Need to check .tar.jobids.stat"; fi
fi

if [ $flg -eq 0 ]; then 
  cd $CUR/Filtered/
  ls ./*/*/ -la > .log.intermediate_files
  rm -r ./allNout ./allTiB
  
  cd $CUR/
  rm qArray_mkBPlist_1n  qArray_mkBPlist_1t  qArray_mkBPlist_2t_NP
fi


## Realign sample-reads on variant contig # 

cd $CUR/Realign/

for sid in `ls -d [A-Z][A-Z][0-9][0-9][0-9]`
do
  TARDIR=$CUR/Realign/${sid}
  # [1] make SVseq
  cd $TARDIR/SVseq
  ls -ltra ./ > .log.intermediate_files

  for stderr in .mkSVdb .list_chr? .list_chr?? SVseq_multiFa
  do
    if [ ! -s ${stderr}.err ]; then
      if [ -e ${stderr}.err ]; then rm ${stderr}.err; fi
      if [ -e ${stderr}.out ]; then rm ${stderr}.out; fi
    else
      ls -l ${stderr}.err
      echo -e "\n==< "`pwd`"/"${stderr}.err" >=="
      head -n5 ${stderr}.err
      flg=1
      if [ $flg -eq 1 ]; then echo -e "\nRealign_[1] SVseq: Need to check "$CUR"/Realign/"${sid}"/SVseq/"${stderr}".err"; fi
    fi
  done

  if [ $flg -eq 0 ]; then
    for cid in `ls -d chr*`
    do
      echo ${cid}":" 	   >> .log.intermediate_files
      ls -l ${cid}/ | head >> .log.intermediate_files
      rm -r ${cid} .list_${cid} 
    done
    rm .invert_nucSq.pl
  fi  

  if [ ! -e SVseq_multiFa.fa.err ]; then
    rm .Joint_AddIdx.stderr .Joint_AddIdx.out
    rm SVseq_multiFa.fa SVseq_multiFa.fa.*
  else 
    echo "==< .Joint_AddIdx.stderr >=="  >> realnSV.err.log
    cat .Joint_AddIdx.stderr >> realnSV.err.log
  fi

  # [2] BWA mapping to reconstruct_SVseq
  cd $TARDIR/BWA
  ls -ltra ./*/*/ > .log.intermediate_files

  for stat in tumor normal
  do
    cd $TARDIR/BWA/${stat}
    flg=0;
    for sqid in `ls -d [0-9][0-9][0-9][0-9][0-9][0-9]_*`
    do
      if [ -s ${sqid}/.remapCtg.err ]; then
        echo -e "\n==< "`pwd`"/"${sqid}/.remapCtg.err" >=="
        head -n5 ${sqid}/.remapCtg.err
        flg=1
        if [ $flg -eq 1 ]; then echo -e "\nRealign_[2] BWA: Need to check "$CUR"/Realign/"${sid}"/BWA/"${sqid}"/.remapCtg.err"; fi
      fi
    done
    
    if [ $flg -eq 0 ]; then
      rm -r [0-9][0-9][0-9][0-9][0-9][0-9]_*
    fi
    cd $TARDIR/BWA;  rmdir ${stat}
  done

  # [3] extract REF-supported reads
  cd $TARDIR/REF
  ls -ltra ./ ./*/*/ > .log.intermediate_files
  rm .list_chr[1-9]* .list_chr[X-Y]

  for stat in tumor normal
  do
    cd $TARDIR/REF/${stat}
    flg=0;
    for sqid in `ls -d [0-9][0-9][0-9][0-9][0-9][0-9]_*`
    do
      awk '$0!~"[samopen]" && length($0)>0{print}' $sqid/.cntREFsup.stderr > $sqid/.cntREFsup.err
      if [ ! -s $sqid/.cntREFsup.err ]; then
        rm $sqid/.cntREFsup.stderr $sqid/.cntREFsup.err $sqid/.cntREFsup.out
      else
        echo -e "\n==< "`pwd`"/"$sqid/.cntREFsup.err" >=="
        head -n5 ${sqid}/.cntREFsup.err
        flg=1
        if [ $flg -eq 1 ]; then echo -e "\nRealign_[3] REF: Need to check "$CUR"/Realign/"${sid}"/REF/"${sqid}"/.cntREFsup.stderr"; fi
      fi
    done

    if [ $flg -eq 0 ]; then
      rm -r [0-9][0-9][0-9][0-9][0-9][0-9]_*
    fi
    cd $TARDIR/REF; rmdir ${stat} 
  done

  # [4] count No.support-reads per four categories{T-REF, T-SV, N-REF, N-SV}
  cd $TARDIR
  for stat in tumor normal
  do  
    cd $TARDIR/${stat}
    ls -ltra ./ ./*/ > .log.intermediate_files

    if [ ! -s .mklist.err ]; then
      rm .mklist.out .mklist.err
      ls -ltra ./ > .log.intermediate_files
      rm -r pChr_SVmatch/ pChr_REFsupp/ pChr_SVmatch_tr/
    else
      echo -e "\n==< "`pwd`"/"${stat}/.mklist.err" >=="
      head -n5 .mklist.err 
      flg=1;
      if [ $flg -eq 1 ]; then echo -e "\nRealign_[4] Count No.support reads: Need to check "$CUR"/"${sid}"/"${stat}"/.mklist.err"; fi
    fi
  done  
  
  cd $TARDIR
  ls -ltra ./ > .log.intermediate_files
  if [ ! -s .addCnt.err ]; then
    rm intraBP_addCnt.list_0 qArray.split_addCnt .addCnt.out .addCnt.err
  else
    echo -e "\n==< "`pwd`"/.addCnt.err >=="
    head -n5 .addCnt.err
    flg=1
    if [ $flg -eq 1 ]; then echo -e "\nRealign_[4] Add column for No.support reads: Need to check "$CUR"/"${sid}"/.addCnt.err"; fi
  fi

  if [ ! -s .Ftest.err ]; then
    rm intraBP_tested_0.list .Ftest.out .Ftest.err
  else
    echo -e "\n==< "`pwd`"/.Ftest.err >=="
    head -n5 .Ftest.err
    flg=1
    if [ $flg -eq 1 ]; then echo -e "\nRealign_[4] Calculate P-value of Fisher test : Need to check "$CUR"/"${sid}"/.addCnt.err"; fi
  fi

done


if [ $flg -eq 0 ]; then
  cd $CUR
  for sid in `ls -d [A-Z][A-Z][0-9][0-9][0-9]`
  do 
    TARDIR=$CUR/${sid}
#   cd $TARDIR/tumor
#   ls -ltra ./ > .log.intermediate_files;  ls -ltra ./tmpTout/* >> .log.intermediate_files
#   rm -r ./[0-9][0-9][0-9][0-9][0-9][0-9]_*/  ./tmpTout/
#   rm  .*list* intraBP.list_0?* .chkStat_c3.out

    cd $TARDIR/normal
    ls -ltra ./ > .log.intermediate_files;  ls -ltra ./tmpNout/* >> .log.intermediate_files
    rm -r ./[0-9][0-9][0-9][0-9][0-9][0-9]_*/  ./tmpNout/
    rm .*list*
  done

  cd $HDR/PE
  for sid in `ls -d [A-Z][A-Z][0-9][0-9][0-9]`
  do
    rm ${sid}/tumor/*.sam.cla.tr.bam
  done

fi
