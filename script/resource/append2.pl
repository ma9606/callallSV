#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [direction] [file]\n";
    exit -1;
}
$dir = $ARGV[0];
$filename = $ARGV[1];

#printf(STDOUT "direction\tsample\tclass\t#read\tchromosome1\tcluster1_start\tcluster1_end\tlength1\tchromosome2\tcluster2_start\tcluster2_end\tlength2\taverage_insert\tdistance\tgene\n");
open(FILE, $filename) || die "Can not open file $filename: $!\n";
$line = <FILE>;
while($line = <FILE>){
    printf(STDOUT "%s\t%s", $dir, $line);
}
close(FILE);
