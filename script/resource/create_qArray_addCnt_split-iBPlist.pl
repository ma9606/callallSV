#!/usr/bin/perl -w

if($#ARGV != 1){
    printf STDERR "usage: $0 [file.prefix(intraBP.list_p)] [max-insertSize]\n";
    exit -1;
}
$com="split -l 100 intraBP.list -d -a4 intraBP.list_p"; 		system($com);
$com="ls ./intraBP.list_p[0-9][0-9][0-9][0-9] > .split_iBP.list"; 	system($com);
# $com="ls ./" . $ARGV[0] . "???? > .split_iBP.list"; system($com);

my $filename = "./.split_iBP.list";
my @array_filename;

my $mxis     = $ARGV[1];

open( FILE, $filename ) || die "Can not open file $filename : $!\n";
while( my $line = <FILE> ){
    chomp $line;
    push(@array_filename, $line);
}
close( FILE );
$com="rm ./.split_iBP.list";       system($com);

print "#!/bin/sh\n";
print "#\$ -o .addCnt.out  -e .addCnt.err\n";
print "#\$ -l s_vmem=1G  -l mem_req=1G  -l mem_free=1G\n";
print "#\$ -r n\n";
print "#\$ -cwd\n";
print "#\$ -b y\n";
print "#\$ -t 1-" . ($#array_filename+1) . ":1\n";
print "\n";

print "tar=(\n";
my $cnt=1;
foreach my $tmp (@array_filename) {
	print "[$cnt]=$tmp\n";
	$cnt++;
}
print ")\n";
print "\n";

print "source ./.rearrangement.conf\n";
print "\$RSC/add4Fld_cntSupR.pl \${tar[\$SGE_TASK_ID]}  ./tumor ./normal $mxis > \${tar[\$SGE_TASK_ID]}_0\n"
