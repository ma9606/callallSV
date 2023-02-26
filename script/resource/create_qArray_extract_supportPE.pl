#! /usr/bin/perl -w
use strict;
use warnings;

if($#ARGV != 1){
    printf STDERR "usage: $0 [.list.bamfile] [smplID]\n";
    exit -1;
}

my $filename = "";
my @array_filename;

my $filelist = $ARGV[0];
my $sid      = $ARGV[1];  my $qid = "ps".$sid;
open( FILE, $filelist ) || die "Can not open file $filelist : $!\n";

while( my $line = <FILE> ){
    chomp $line;
    push(@array_filename, $line);
}
close( FILE );

print "#!/bin/sh\n";
print "#\$ -N " . $qid . "\n";
print "#\$ -l s_vmem=2G\n";
print "#\$ -l mem_req=2G\n";
print "#\$ -l mem_free=2G\n";
print "#\$ -r n\n";
print "#\$ -cwd\n";
print "#\$ -b y\n";
print "#\$ -t 1-" . ($#array_filename+1) . ":1\n";
print "\n";

print "srtbam=(\n";
my $cnt=1;
foreach my $tmp (@array_filename) {
	print "[$cnt]=$tmp\n";
	$cnt++;
}
print ")\n";
print "\n";

print "source ../../../PE/$sid/tumor/.rearrangement.conf\n";
print "MXRATE_QS35=0.50\n";
print "EXCEPT_SEQ=`echo \042#\042 | awk -v rate=\$MXRATE_QS35 -v len=\$READ_LEN \047{N=rate*len; for(i=0;i<N;i++)printf \042#\042}END{print \042\042}\047`\n";
print "\n";

print "\${RSC}/ext_supportPE_srtBam_batch.pl  \${srtbam[\$SGE_TASK_ID]}  intraBP.list_0_filtR_tr.srt \$MXINS_T \${SAMTOOLS_DIR} > ./\${srtbam[\$SGE_TASK_ID]}.supPE.out\n";
print "grep  -v ^chr ./\${srtbam[\$SGE_TASK_ID]}.supPE.out | cut -f1 | sed -e \042s/\$/\\t/\042 | sort -u > ./\${srtbam[\$SGE_TASK_ID]}.idlist\n";
print "fgrep  -f ./\${srtbam[\$SGE_TASK_ID]}.idlist  ./\${srtbam[\$SGE_TASK_ID]}.tmpsam | awk -v tar=\$EXCEPT_SEQ 'length(\$6)>10 || \$11~tar{print}' | cut -f1 | sed -e \042s/\$/\\t/\042 | sort -u > ./\${srtbam[\$SGE_TASK_ID]}.discard.idlist\n";
print "\n";

print "fgrep -f ./\${srtbam[\$SGE_TASK_ID]}.discard.idlist -v ./\${srtbam[\$SGE_TASK_ID]}.supPE.out > ./\${srtbam[\$SGE_TASK_ID]}.supPE.out_tmp;  mv ./\${srtbam[\$SGE_TASK_ID]}.supPE.out_tmp ./\${srtbam[\$SGE_TASK_ID]}.supPE.out\n";
print "awk \047{if(\$1~\042^chr\042){if(cnt!=0)for(i=0;i<cnt;i++)print iB; iB=\$0; cnt=0;} else cnt++;}\047 ./\${srtbam[\$SGE_TASK_ID]}.supPE.out > ./\${srtbam[\$SGE_TASK_ID]}.supPE.list_0\n";
print "\n";

print "rm ./\${srtbam[\$SGE_TASK_ID]}.tmpsam\n";
