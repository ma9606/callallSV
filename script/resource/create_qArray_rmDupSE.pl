#! /usr/bin/perl -w
use strict;
use warnings;


if($#ARGV != 0){
    printf STDERR "usage: $0 [listdir/]\n";
    exit -1;
}

my $listdir  = $ARGV[0];
my $filename = "";
my @array_filename;

system("ls ./*/*.chim > .all_chim.list");
my $filelist = "./.all_chim.list";
open( FILE, $filelist ) || die "Can not open file $filelist : $!\n";

while( my $line = <FILE> ){
	chomp $line;
	my $filename = $line;
	push(@array_filename, $filename);
}
close( FILE );

print "#!/bin/sh\n";
print "#\$ -l s_vmem=8G\n";
print "#\$ -l mem_req=8G\n";
print "#\$ -l mem_free=8G\n";
print "#\$ -r n\n";
print "#\$ -cwd\n";
print "#\$ -b y\n";
print "#\$ -t 1-" . ($#array_filename+1) . ":1\n";
print "#\$ -o .rmDup.out -e .rmDup.err\n";
print "\n";

print "source ../../../callallsv.cfg\n";
print "\n";

print "chimfile=(\n";
my $cnt=1;
foreach my $tmp (@array_filename) {
	print "[$cnt]=$tmp\n";
	$cnt++;
}
print ")\n";
print "\n";

print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id.list      -v \${chimfile[\$SGE_TASK_ID]}   > \${chimfile[\$SGE_TASK_ID]}_1\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr1.list -v \${chimfile[\$SGE_TASK_ID]}_1 > \${chimfile[\$SGE_TASK_ID]}_2\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr2.list -v \${chimfile[\$SGE_TASK_ID]}_2 > \${chimfile[\$SGE_TASK_ID]}_3\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr3.list -v \${chimfile[\$SGE_TASK_ID]}_3 > \${chimfile[\$SGE_TASK_ID]}_4\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr4.list -v \${chimfile[\$SGE_TASK_ID]}_4 > \${chimfile[\$SGE_TASK_ID]}_5\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr5.list -v \${chimfile[\$SGE_TASK_ID]}_5 > \${chimfile[\$SGE_TASK_ID]}_6\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr6.list -v \${chimfile[\$SGE_TASK_ID]}_6 > \${chimfile[\$SGE_TASK_ID]}_7\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr7.list -v \${chimfile[\$SGE_TASK_ID]}_7 > \${chimfile[\$SGE_TASK_ID]}_8\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr8.list -v \${chimfile[\$SGE_TASK_ID]}_8 > \${chimfile[\$SGE_TASK_ID]}_9\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr9.list -v \${chimfile[\$SGE_TASK_ID]}_9 > \${chimfile[\$SGE_TASK_ID]}_10\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr10.list -v \${chimfile[\$SGE_TASK_ID]}_10 > \${chimfile[\$SGE_TASK_ID]}_11\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr11.list -v \${chimfile[\$SGE_TASK_ID]}_11 > \${chimfile[\$SGE_TASK_ID]}_12\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr12.list -v \${chimfile[\$SGE_TASK_ID]}_12 > \${chimfile[\$SGE_TASK_ID]}_13\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr13.list -v \${chimfile[\$SGE_TASK_ID]}_13 > \${chimfile[\$SGE_TASK_ID]}_14\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr14.list -v \${chimfile[\$SGE_TASK_ID]}_14 > \${chimfile[\$SGE_TASK_ID]}_15\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr15.list -v \${chimfile[\$SGE_TASK_ID]}_15 > \${chimfile[\$SGE_TASK_ID]}_16\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr16.list -v \${chimfile[\$SGE_TASK_ID]}_16 > \${chimfile[\$SGE_TASK_ID]}_17\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr17.list -v \${chimfile[\$SGE_TASK_ID]}_17 > \${chimfile[\$SGE_TASK_ID]}_18\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr18.list -v \${chimfile[\$SGE_TASK_ID]}_18 > \${chimfile[\$SGE_TASK_ID]}_19\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr19.list -v \${chimfile[\$SGE_TASK_ID]}_19 > \${chimfile[\$SGE_TASK_ID]}_20\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr20.list -v \${chimfile[\$SGE_TASK_ID]}_20 > \${chimfile[\$SGE_TASK_ID]}_21\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr21.list -v \${chimfile[\$SGE_TASK_ID]}_21 > \${chimfile[\$SGE_TASK_ID]}_22\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chr22.list -v \${chimfile[\$SGE_TASK_ID]}_22 > \${chimfile[\$SGE_TASK_ID]}_23\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chrX.list  -v \${chimfile[\$SGE_TASK_ID]}_23 > \${chimfile[\$SGE_TASK_ID]}_24\n";
print "fgrep -f ./rmPCRDup_${listdir}bp/rmDup_id_chrY.list  -v \${chimfile[\$SGE_TASK_ID]}_24 > \${chimfile[\$SGE_TASK_ID]}_fin\n";

print "mv \${chimfile[\$SGE_TASK_ID]}_fin \${chimfile[\$SGE_TASK_ID]}\n";
print "rm \${chimfile[\$SGE_TASK_ID]}_*\n";
