#! /usr/bin/perl -w
use strict;
use warnings;

if($#ARGV != 1){
    printf STDERR "usage: $0 [dir.inFile] [maxInsertSize]\n";
    exit -1;
}

my $dat     = $ARGV[0];
my $mxis    = $ARGV[1];
my $name = "";
my @array_filename;
my @array_tarname;

system("ls ${dat}/*.sam.gz  > .list.samGz;\0");
my $listname = "./.list.samGz";

open( FILE, $listname ) || die "Can not open file $listname : $!\n";
while( my $line = <FILE> ){
	chomp $line;
	my $filename = $line;
	$filename =~ s/\.sam.gz//;
	push(@array_filename,  $filename);

        my @column = split(/\//, $filename);
        my $tarname = $column[$#column];
        push(@array_tarname, $tarname);
}
close( FILE );

print "#!/bin/sh\n";
print "#\$ -l s_vmem=2G -l mem_req=2G -l mem_free=2G\n";
print "#\$ -pe def_slot 2\n";
print "#\$ -r n\n";
print "#\$ -cwd\n";
print "#\$ -b y\n";
print "#\$ -t 1-" . ($#array_filename+1) . ":1\n";
print "\n";

print "fileName=(\n";
my $cnt=1;
foreach my $tmp (@array_filename) {
        print "[$cnt]=$tmp\n";
        $cnt++;
}
print ")\n";

print "tarfile=(\n";
$cnt=1;
foreach my $tmp (@array_tarname) {
        print "[$cnt]=$tmp\n";
        $cnt++;
}
print ")\n";
print "\n";

print "CONF=../../../.rearrangement.conf;  . \$CONF\n";
print "\n";

print "zcat \${fileName[\$SGE_TASK_ID]}.sam.gz | cat \${RSC}/.sam.header - > \${tarfile[\$SGE_TASK_ID]}.sam\n";
print "\${SAMTOOLS_DIR}/samtools view -bt \${REF_FAI} -o  \${tarfile[\$SGE_TASK_ID]}.bam  \${tarfile[\$SGE_TASK_ID]}.sam\n";
print "if [ \$? -eq 0 ]; then\n";
print "  rm  \${tarfile[\$SGE_TASK_ID]}.sam\n";
print "fi\n";
print "\${SAMTOOLS_DIR}/samtools sort  \${tarfile[\$SGE_TASK_ID]}.bam  -o \${tarfile[\$SGE_TASK_ID]}.srt  &&  mv \${tarfile[\$SGE_TASK_ID]}.srt \${tarfile[\$SGE_TASK_ID]}.bam\n";
print "\${SAMTOOLS_DIR}/samtools index \${tarfile[\$SGE_TASK_ID]}.bam\n";
print "\n";

print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  1 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr1  $mxis  > \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  2 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr2  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  3 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr3  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  4 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr4  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  5 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr5  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  6 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr6  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  7 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr7  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  8 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr8  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  9 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr9  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  10 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr10  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  11 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr11  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  12 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr12  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  13 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr13  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  14 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr14  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  15 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr15  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  16 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr16  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  17 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr17  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  18 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr18  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  19 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr19  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  20 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr20  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  21 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr21  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  22 | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chr22  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  X | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chrX  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";
print "\${SAMTOOLS_DIR}/samtools view  \${tarfile[\$SGE_TASK_ID]}.bam  Y | \$RSC/sortMatchPE.pl - | \$RSC/extMatchPE.pl - ../../.list_chrY  $mxis >> \${tarfile[\$SGE_TASK_ID]}.extlist\n";

print "rm \${tarfile[\$SGE_TASK_ID]}.bam \${tarfile[\$SGE_TASK_ID]}.bam.bai\n";
