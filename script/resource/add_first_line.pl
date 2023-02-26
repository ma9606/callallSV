#! /usr/bin/perl

if($#ARGV != 0){
    printf STDERR "usage: $0 [file]\n";
    exit -1;
}
$filename0 = $ARGV[0];

$line = "direction	sample	class	#read	chromosome1	cluster1_start	cluster1_end	length1	chromosome2	cluster2_start	cluster2_end	length2	average_insert	distance	gene";
printf(STDOUT "%s\n", $line);
open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    printf(STDOUT "%s\n", $line);
}
close(FILE);
