#! /usr/bin/perl -w
use strict;
use warnings;

if($#ARGV != 2){
    printf STDERR "usage: $0 [readLen] [maxInsertSize] [query_id]\n";
    exit -1;
}

my $filename = "";
my @array_filename; my @array_tarfile;

# system("ls *_[0-9][0-9][0-9]*.sam.gz | grep -v SA.sam > .list.samGz\0");

my $listname = "./.list.samGz";
my $readLen = $ARGV[0];
my $mxis    = $ARGV[1];
my $qid     = $ARGV[2];
open( FILE, $listname ) || die "Can not open file $listname : $!\n";

while( my $line = <FILE> ){
	chomp $line;
	my $filename = $line;
	$filename =~ s/\.sam.gz//;
	push(@array_filename,  $filename);

	my @column = split(/\//, $filename);
	my $tarfile = $column[$#column];
	push(@array_tarfile, $tarfile);
}
close( FILE );

print "#!/bin/sh\n";
print "#\$ -N " . $qid . "\n";
print "#\$ -l s_vmem=4G  -l mem_req=4G  -l mem_free=4G\n";
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
print ")\n\n";

print "tarfile=(\n";
$cnt=1;
foreach my $tmp (@array_tarfile) {
        print "[$cnt]=$tmp\n";
        $cnt++;
}
print ")\n";
print "\n";

print "CONF=../../../.rearrangement.conf;  . \$CONF\n";
print "REF=../../../SVseq/SVseq_multiFa.fa\n";
print "\n";
print "zcat \${fileName[\$SGE_TASK_ID]}.sam.gz | \$RSC/classifyFlag4_n3m_extUnPM.pl  -  $mxis  \${tarfile[\$SGE_TASK_ID]}  \$CONF\n";
print "\${BWA_DIR}/bwa mem -t 4 -T 0 \$REF \${tarfile[\$SGE_TASK_ID]}_SV1.fq \${tarfile[\$SGE_TASK_ID]}_SV2.fq 1>\${tarfile[\$SGE_TASK_ID]}_SV.sam 2>\${tarfile[\$SGE_TASK_ID]}_SV.sam.err\n";
print "awk -v readLen=$readLen -v mxis=$mxis -f \$RSC/extSVmatch.awk \${tarfile[\$SGE_TASK_ID]}_SV.sam > \${tarfile[\$SGE_TASK_ID]}_SVmatch_0.sam\n";
print "rm \${tarfile[\$SGE_TASK_ID]}_SV1.fq \${tarfile[\$SGE_TASK_ID]}_SV2.fq\n";
print "\n";

print "awk \'\$NF ~\"_R\"{print}\' \${tarfile[\$SGE_TASK_ID]}_SVmatch_0.sam > \${tarfile[\$SGE_TASK_ID]}_SVmatch_0PE.sam\n";
print "awk -F\"\\t\" \'{split(\$14,as,\":\"); if(\$0~\"AS:i:0\")as[3]=0; if(\$1==tmpid){ print \$1FS tmpas, as[3];} tmpid=\$1; tmpas=as[3];}\' \${tarfile[\$SGE_TASK_ID]}_SVmatch_0PE.sam > \${tarfile[\$SGE_TASK_ID]}_SVmatch_0PE.as_list\n";
print "cut -f1 \${tarfile[\$SGE_TASK_ID]}_SVmatch_0PE.sam  | uniq > \${tarfile[\$SGE_TASK_ID]}_SVmatch_0PE.id\n";
print "fgrep -f \${tarfile[\$SGE_TASK_ID]}_SVmatch_0PE.id  \${tarfile[\$SGE_TASK_ID]}_org.sam | awk -F\"\\t\" \'{split(\$14,as,\":\"); if(\$0~\"AS:i:0\")as[3]=0; if(\$1==tmpid){ print \$1FS tmpas, as[3];} tmpid=\$1; tmpas=as[3];}\' > \${tarfile[\$SGE_TASK_ID]}_orgPE.as_list\n";
print "paste \${tarfile[\$SGE_TASK_ID]}_SVmatch_0PE.as_list \${tarfile[\$SGE_TASK_ID]}_orgPE.as_list > \${tarfile[\$SGE_TASK_ID]}_PE.as_list\n"; 
print "awk \'\$2>=\$5 && \$3>=\$6{print \$1}\' \${tarfile[\$SGE_TASK_ID]}_PE.as_list  > \${tarfile[\$SGE_TASK_ID]}_SVmatch_0.id\n";
print "\n";

print "awk \'\$NF!~\"_R\"{print}\' \${tarfile[\$SGE_TASK_ID]}_SVmatch_0.sam > \${tarfile[\$SGE_TASK_ID]}_SVmatch_0SE.sam\n";
print "awk -F\"\\t\" \'{split(\$14,as,\":\"); if(\$0~\"AS:i:0\")as[3]=0; print \$1FS\$2FS as[3] FS \$NF}\' \${tarfile[\$SGE_TASK_ID]}_SVmatch_0SE.sam > \${tarfile[\$SGE_TASK_ID]}_SVmatch_0SE.as_list\n";
print "cut -f1 \${tarfile[\$SGE_TASK_ID]}_SVmatch_0SE.sam  | uniq > \${tarfile[\$SGE_TASK_ID]}_SVmatch_0SE.id\n";
print "fgrep -f \${tarfile[\$SGE_TASK_ID]}_SVmatch_0SE.id  \${tarfile[\$SGE_TASK_ID]}_org.sam | awk -F\"\\t\" \'{split(\$14,as,\":\"); if(\$0~\"AS:i:0\")as[3]=0; print \$1FS\$2FS as[3]}\' > \${tarfile[\$SGE_TASK_ID]}_org_SE.as_list\n";
print "paste \${tarfile[\$SGE_TASK_ID]}_SVmatch_0SE.as_list \${tarfile[\$SGE_TASK_ID]}_org_SE.as_list > \${tarfile[\$SGE_TASK_ID]}_SE.as_list\n"; 
print "awk \'(\$4==\"_A\"||\$4==\"_B\")&&\$3>\$7{print \$1}\' \${tarfile[\$SGE_TASK_ID]}_SE.as_list  >> \${tarfile[\$SGE_TASK_ID]}_SVmatch_0.id\n";
print "\n";

print "fgrep -f \${tarfile[\$SGE_TASK_ID]}_SVmatch_0.id \${tarfile[\$SGE_TASK_ID]}_SVmatch_0.sam > \${tarfile[\$SGE_TASK_ID]}_SVmatch.sam\n";
print "rm \${tarfile[\$SGE_TASK_ID]}_SVmatch_0*  \${tarfile[\$SGE_TASK_ID]}_org*  \${tarfile[\$SGE_TASK_ID]}_SV.sam  \${tarfile[\$SGE_TASK_ID]}_SV.sam.err\n";
