#!/bin/sh
abs=`realpath $0 | rev | cut -f3- -d"/" | rev`
source ${abs}/callallsv.cfg

flg=0

cd $HDR/PE
for sid in `ls -d [A-Z][A-Z][0-9][0-9][0-9]`
do
  TARDIR=$HDR/PE/${sid}
  # Check also detectGR_YYYYMMDD_TT-MM-SS.log

  for stat in tumor normal
  do
    cd $TARDIR/${stat}
    ls -ltra ./ > .log.intermediate_files

    awk '$0!~"[samopen]"{print}' .cr1_categorize.stderr > .cr1_categorize.err  &&  rm .cr1_categorize.stderr
    ls -a .cr[1-5]_*.err | sed -e "s/.err$//" > .tmplist
    while read stderr
    do
      if [ ! -s ${stderr} ]; then
        rm ${stderr}.out ${stderr}.err
      else
        echo -e "\n==< "`pwd`"/"${stderr}.err" >=="
        head -n5 ${stderr}.err
        flg=1
      fi
    done < .tmplist; rm .tmplist

    if [ $flg -eq 0 ]; then 
      rm ./.com.rearrangement.[1-5].*.pbs
      $SCR/pe/_cleanUP_${stat}_after-stp1.sh
      rm ../.list.sam.${stat}
    fi

  done

done


cd $HDR/SoftClip
CUR=`pwd`
flg=0
for sid in `ls -d [A-Z][A-Z][0-9][0-9][0-9]`
do
  TARDIR=$HDR/SoftClip/${sid}
  for stat in tumor normal 
  do
    cd $TARDIR/${stat}
    READ_LEN=`ls -d rmPCRDup_*bp | cut -f2 -d"_" | sed -e "s/bp$//"`

    # check_step_2-1: extract reads with soft-clipped alignment
    for tardir in `ls -d [0-9][0-9][0-9][0-9][0-9][0-9]_*`
    do
      if [ ! -s ${tardir}/.ext-chimSam.err ]; then
        rm ${tardir}/*.SA.sam ${tardir}/.ext-chimSam.err ${tardir}/.ext-chimSam.out
      else
        echo "==< "${tardir}/.ext-chimSam.err" >=="
        head -n5 ${tardir}/.ext-chimSam.err
      fi
    done
    
    # check_step_2-2: remove duplicated reads
    grep -v "^\[" ./rmPCRDup_${READ_LEN}bp/.rmDup_fr.err  > .rmDup_fr.err;  echo -n > .rmDup_fr.out
    for stderr in .extPCRDup .rmDup_fr .rmDup 
    do
      if [ ! -s $stderr ]; then
        rm ${stderr}.out ${stderr}.err
      else 
        ls -l ${stderr}.err
        echo "==< "${stderr}.err" >=="
        head -n5 ${stderr}.err
        flg=1
      fi
    done    

    ls -l ./rmPCRDup_${READ_LEN}bp/rmDup_id.list ./rmPCRDup_${READ_LEN}bp/rmDup_id_chr[1-9].list |\
     awk -v rlen=${READ_LEN} -v dir=$TARDIR/${stat} '$5==0{print dir"/"$9" file size ZERO, might not processed!"; cnt++;}END{if(cnt==0)print "rm -r ./rmPCRDup_"rlen"bp"}' > .rmdir.rmPCRDup.sh
    wcl=`grep "ZERO" .rmdir.rmPCRDup.sh | wc -l`
    if [ $wcl -eq 0 ]; then 
      sh .rmdir.rmPCRDup.sh  && rm .rmdir.rmPCRDup.sh
    else
      cat .rmdir.rmPCRDup.sh
      mv .rmdir.rmPCRDup.sh rmPCRDup.err.log 
      flg=1
    fi
    
    if [ ${flg} -eq 0 ]; then
      rm qArray.RmPCRDup
    fi
    
    awk '$0=="0"{cnt++;}END{if(cnt==NR)print "rm .tar.jobids.stat .tar.jobids"}' .tar.jobids.stat > .rmids.stat.sh
    if [ -s .rmids.stat.sh ]; then
      sh .rmids.stat.sh  &&  rm .rmids.stat.sh
    else
      paste .tar.jobids .tar.jobids.stat 
    fi
    
  done
done

