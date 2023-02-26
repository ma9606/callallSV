#! /usr/bin/perl

if($#ARGV != 0){
    printf STDERR "usage: $0 [file]\n";
    exit -1;
}
$filename0 = $ARGV[0];

open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    @list = split(/\t/, $line);
    $line2 = <FILE>;
    @list2 = split(/\t/, $line2);
#    if($list[11] ne "XT:A:R" && $list2[11] ne "XT:A:R"){
    if($list[4] != 0 && $list2[4] != 0){
	printf(STDOUT "%s", $line);
	printf(STDOUT "%s", $line2);
    }
}
close(FILE);
