#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [file] [min. score]\n";
    exit -1;
}
$filename = $ARGV[0];
$min = $ARGV[1];

open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
    @list = split(/\t/, $line);
    $sco = $list[4];
    $line2 = <FILE>;
    @list2 = split(/\t/, $line2);
    $sco2 = $list2[4];
    if($min <= $sco && $min <= $sco2){
	printf(STDOUT "%s", $line);
	printf(STDOUT "%s", $line2);
    }
}
close(FILE);
