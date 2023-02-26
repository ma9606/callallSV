#! /usr/bin/perl -w
use strict;
use warnings;

# ls -1 [BWA mapped].sam > samfile.list
# create_qArray_cr1_categorize.pl [samfile.txt] [Max-insert length] [rearrangement.conf] > com.rearrangement.1.categorize.pbs

if($#ARGV != 2){
    printf STDERR "usage: $0 [filename(output of \"ls dir/[*BWA mapped].sam\")] [Max-insert length] [rearrangement.conf]\n";
    exit -1;

}

my @array_filename_SAM;
my @array_fileid;
my @fid;

my $input = $ARGV[0];
my $MAX_INSERT = $ARGV[1];
my $CONF = $ARGV[2];

open( FILE, $input ) || die "Can not open file $input : $!\n";
while( my $line = <FILE> ){
	chomp $line;
	my $filename = $line;
	push(@array_filename_SAM, $filename);
	@fid = split(/\//, $filename); my $fid_wo_suffix = substr($fid[$#fid],0,length($fid[$#fid])-3); # assuming ".gz"-type compression
	push(@array_fileid, $fid_wo_suffix);
}
close( FILE );


print "#!/bin/sh\n";
print "#\$ -r n\n";
print "#\$ -cwd\n";
print "#\$ -t 1-" . ($#array_filename_SAM+1) . ":1\n";
print "\n";
print "CONF=".$CONF."\n";
print ". \$CONF\n";
print "\n";

print "file=(\n";
my $cnt=1;
foreach my $tmp (@array_filename_SAM) {
	print "[$cnt]=$tmp\n";
	$cnt++;
}
print ")\n";
print "\n";

print "fileid=(\n";
$cnt=1;
foreach my $tmp (@array_fileid) {
        print "[$cnt]=$tmp\n";
        $cnt++;
}
print ")\n";
print "\n";

print "source ./.rearrangement.conf\n";
print "\n";
 
print "zcat \${file[\$SGE_TASK_ID]}  | \$RSC/classifyFlag4_new3_mem.pl - $MAX_INSERT \${fileid[\$SGE_TASK_ID]}_\$SGE_TASK_ID $CONF\n";
print "if [ \042\140echo \${file[\$SGE_TASK_ID]} | grep tumor\140\042 -o \042\140echo \${CONF} | grep tumor\140\042 ]\n";
print "then\n";
print "   cat \${RSC}/sam_chr.header \${fileid[\$SGE_TASK_ID]}_\${SGE_TASK_ID}.cla.tr > \${fileid[\$SGE_TASK_ID]}.cla.tr.sam\n";
print "   \${SAMTOOLS_DIR}/samtools view -bt  \$REF  -o \${fileid[\$SGE_TASK_ID]}.cla.tr.bam  \${fileid[\$SGE_TASK_ID]}.cla.tr.sam  &&  rm \${fileid[\$SGE_TASK_ID]}.cla.tr.sam\n"; 
print "   \${SAMTOOLS_DIR}/samtools sort  \${fileid[\$SGE_TASK_ID]}.cla.tr.bam  -o \${fileid[\$SGE_TASK_ID]}.cla.tr.srt  &&  mv \${fileid[\$SGE_TASK_ID]}.cla.tr.srt \${fileid[\$SGE_TASK_ID]}.cla.tr.bam\n";
print "fi\n";
