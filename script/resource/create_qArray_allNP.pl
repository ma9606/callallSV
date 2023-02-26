#! /usr/bin/perl -w
use strict;
use warnings;

if($#ARGV != 0){
    printf STDERR "usage: $0 [qID]\n";
    exit -1;
}
system("ls */chr*.BP_list_0_* | grep -v _np > .tar.list");

my @array_filename;
my $qid      = $ARGV[0];

open( FILE, "./.tar.list" ) || die "Can not open file ./.tar.list : $!\n";
while( my $line = <FILE> ){
	chomp $line;
	my $filename = $line;
	push(@array_filename, $filename);
}
close( FILE );

print "#!/bin/sh\n";
print "#\$ -N " . $qid . "\n";
# print "#\$ -o .".$qid.".out  -e .".$qid.".err\n";
print "#\$ -l s_vmem=1G  -l mem_req=1G  -l mem_free=1G\n";
print "#\$ -r n\n";
print "#\$ -cwd\n";
print "#\$ -b y\n";
print "#\$ -t 1-" . ($#array_filename+1) . ":1\n";
print "\n";

print "source ../../../callallsv.cfg\n";
print "\n";

print "file=(\n";
my $cnt=1;
foreach my $tmp (@array_filename) {
	print "[$cnt]=$tmp\n";
	$cnt++;
}
print ")\n";
print "\n";
print "\n";
print "\$RSC/chkOverlap_nBP_forArray.pl  ../allNout/\${file[\$SGE_TASK_ID]}  \${file[\$SGE_TASK_ID]}   >  \${file[\$SGE_TASK_ID]}_np\n";
