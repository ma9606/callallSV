#!/usr/bin/perl
if($#ARGV != 1){
    printf STDERR "usage: $0 [ID.tarSmpl] [readLen.tarSmpl]\n";
    exit -1;
}

open( LIST_ID,  $ARGV[0] ) || die "Can not open file $ARGV[0] : $!\n";
open( LIST_LEN, $ARGV[1] ) || die "Can not open file $ARGV[1] : $!\n";

while( $id = <LIST_ID> ){
	chomp $id; 
	push(@array_id, $id);
}close( LIST_ID );

while( $len = <LIST_LEN> ){
	chomp $len; 
	@readLen = split(/\s+/, $len);
	push(@array_len, $readLen[1]);
}close( LIST_LEN );

print "#!/bin/sh\n";
print "#\$ -l s_vmem=8G  -l mem_req=8G  -l mem_free=8G\n";
print "#\$ -r n\n";
print "#\$ -cwd\n";
print "#\$ -b y\n";
print "#\$ -t 1-" . ($#array_id+1) . ":1\n";
print "\n";

print "source ../callallsv.cfg\n";
print "CUR=`pwd`\n";
print "\n";

print "tardir=(\n";
$cnt=1;
foreach $tmp (@array_id) {
	print "[$cnt]=$tmp\n";
	$cnt++;
}
print ")\n";
print "\n";

print "rlen=(\n";
$cnt=1;
foreach $tmp (@array_len) {
	print "[$cnt]=$tmp\n";
	$cnt++;
}
print ")\n";
print "\n";

print "cd \${CUR}/\${tardir[\$SGE_TASK_ID]}/tumor\n";
print "ls ../normal/tmpNout/*/*.BP_list_0 > .tmplist0\n";
print "ls tmpTout/*/*.BP_list_0 | paste .tmplist0 - > .BPlist_NP;  rm .tmplist0\n";
print "\${RSC}/chkOverlap_nBP.pl .BPlist_NP > .intraBP.list_0\n";
print "sort -k10,10nr .intraBP.list_0 > intraBP.list_0; rm .intraBP.list_0\n";
print "\n";

print "awk -f \${RSC}/convertBed.awk ./intraBP.list_0 | sort -k1,1 -k2,3n > intraBP.list_0.bed\n";
print "\${BEDTOOLS_DIR}/intersectBed -a intraBP.list_0.bed  -b \${RMSK} -wao  > intraBP.list_0.allRep.iBout\n";
print "\${RSC}/rmAln_lowComplexity.pl intraBP.list_0.allRep.iBout ./intraBP.list_0 \${rlen[\$SGE_TASK_ID]} >  ./intraBP.list_0_filtR\n";
print "\n";

print "sed -e \042s/.chim\$/.sam.cla.tr.bam/\042 .chimT.list > .list.bamfile\n";
print "grep translocation intraBP.list_0_filtR  | sed -e \042s/^chrX/chr23/\042 -e \042s/^chrY/chr24/\042 -e \042s/chr//\042 |  sort -k1,1n -k4,4n | sed -e \042s/^/chr/\042 -e \042s/chr23/chrX/\042 -e \042s/chr24/chrY/\042 > intraBP.list_0_filtR_tr.srt\n";
print "\${RSC}/create_qArray_extract_supportPE.pl .list.bamfile  \${tardir[\$SGE_TASK_ID]} > qArray.ext_supPE;  chmod 770 qArray.ext_supPE\n";
print "qsub -o .ext_supPE.out -e .ext_supPE.err ./qArray.ext_supPE\n";
print "qsub  -hold_jid ps\${tardir[\$SGE_TASK_ID]}  -N pa\${tardir[\$SGE_TASK_ID]} -o .aft_ext_supPE.out -e .aft_ext_supPE.err  \${RSC}/q.aft_ext_supPE\n";
