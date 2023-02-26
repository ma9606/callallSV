#!/usr/bin/perl
if($#ARGV != 1){
    printf STDERR "usage: $0 [ID.tarSmpl] [t(tumor)/n(normal)]\n";
    exit -1;
}

open( LIST_ID,  $ARGV[0] ) || die "Can not open file $ARGV[0] : $!\n";
$type = $ARGV[1];
if(   $type =~ "^t"){ $jid = "qA.mkBP1t"; $mid = ".mkBP1t";}
elsif($type =~ "^n"){ $jid = "qA.mkBP1n"; $mid = ".mkBP1n";}

while( $id = <LIST_ID> ){
	chomp $id; 
	push(@array_id, $id);
}close( LIST_ID );

print "#!/bin/sh\n";
print "#\$ -o ".$mid.".out  -e ".$mid.".err\n";
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

if(   $type =~ "^t"){ 
print "cd \$CUR/\${tardir[\$SGE_TASK_ID]}/tumor\n";
print "ls [1-2][0-9][0-9][0-9][0-9][0-9]_*/*.chim > .chimT.list\n";
print "cut -f1 -d\042/\042 ./.chimT.list | uniq > .list.seqdir\n";
print "MIN_NREAD=2\t# BreakPoint_cluster must contain at least \$MIN_NREAD\n";
print "MIN_MQSCR=0\t# supported read must be mapped with MQ >= \$MIN_MQSCR\n";
print "sed -e \042s/#MN_CNT#/\${MIN_NREAD}/\042 -e \042s/#MN_SMQ#/\${MIN_MQSCR}/\042 \$RSC/judge_cluster.awk > ./.judge_cluster.awk\n";
print "ln -s \${RSC}/rm_minorAln.pl .\n";
print "\$RSC/classify_BPdir.pl .chimT.list tmpTout  &&  rm ./.judge_cluster.awk ./rm_minorAln.pl\n";
}
elsif($type =~ "^n"){ 
print "cd \$CUR/\${tardir[\$SGE_TASK_ID]}/normal\n";
print "ls [1-2][0-9][0-9][0-9][0-9][0-9]_*/*.chim > .chimN.list\n";
print "cut -f1 -d\042/\042 ./.chimN.list | uniq > .list.seqdir\n";
print "MIN_NREAD=1\t# BreakPoint_cluster must contain at least \$MIN_NREAD\n";
print "MIN_MQSCR=0\t# supported read must be mapped with MQ >= \$MIN_MQSCR\n";
print "sed -e \042s/#MN_CNT#/\${MIN_NREAD}/\042 -e \042s/#MN_SMQ#/\${MIN_MQSCR}/\042 \$RSC/judge_cluster.awk > ./.judge_cluster.awk\n";
print "\$RSC/classify_BPdir_N0.pl .chimN.list tmpNout  &&  rm ./.judge_cluster.awk\n";
}
