#! /usr/bin/perl -w
use strict;
use warnings;

# system("ls *.sam.gz > samfile.list");
# create_qArray_extract_chimericSam.pl sam_list.txt "extChm" > qArrayChimera

if($#ARGV != 0){

    printf STDERR "usage: $0 [qid]\n";
    exit -1;

}

my $filename = "";
my @array_filename;
my @array_outname;

my $filelist = "./.list.samGz";
my $qid = $ARGV[0];
open( FILE, $filelist ) || die "Can not open file $filelist : $!\n";

while( my $line = <FILE> ){
	chomp $line;
	my $filename = $line;

	$filename    =~ s/.sam.gz//;
	push(@array_filename, $filename);

	my @column = split(/\//, $filename);
	my $outname = $column[$#column];
	push(@array_outname, $outname);
}
close( FILE );

print "#!/bin/sh\n";
print "#\$ -N ".$qid."\n";
print "#\$ -l s_vmem=4G\n";
print "#\$ -l mem_req=4G\n";
print "#\$ -l mem_free=4G\n";
print "#\$ -r n\n";
print "#\$ -cwd\n";
print "#\$ -b y\n";
print "#\$ -t 1-" . ($#array_filename+1) . ":1\n";
print "\n";

print "source ../../../../callallsv.cfg\n";
print "\n";

print "samfile=(\n";
my $cnt=1;
foreach my $tmp (@array_filename) {
	print "[$cnt]=$tmp\n";
	$cnt++;
}
print ")\n";
print "\n";

print "outfile=(\n";
$cnt=1;
foreach my $tmp (@array_outname) {
	print "[$cnt]=$tmp\n";
	$cnt++;
}
print ")\n";
print "\n";

print "zcat \${samfile[\$SGE_TASK_ID]}.sam.gz | \$RSC/extract_chimericSam_v2.pl - \${outfile[\$SGE_TASK_ID]}  > \${outfile[\$SGE_TASK_ID]}.chim\n";
