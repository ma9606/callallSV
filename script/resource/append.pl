#! /usr/bin/perl

if($#ARGV != 2){
    printf STDERR "usage: $0 [sample name] [class] [file]\n";
    exit -1;
}
$sample = $ARGV[0];
$class = $ARGV[1];
$filename = $ARGV[2];

printf(STDOUT "sample\tclass\t#read\tchromosome1\tcluster1_start\tcluster1_end\tlength1\tchromosome2\tcluster2_start\tcluster2_end\tlength2\taverage_insert\tdistance\tgene\n", $sample, $class, $line);
open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
    printf(STDOUT "%s\t%s\t%s", $sample, $class, $line);
}
close(FILE);
