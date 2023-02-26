#! /usr/bin/perl

if($#ARGV != 0){
    printf STDERR "usage: $0 [sam file]\n";
    exit -1;
}
$filename = $ARGV[0];

open(FILE_f, "> $filename.+") || die "Can not open file $filename.cla.um: $!\n";
open(FILE_r, "> $filename.-") || die "Can not open file $filename.cla.se: $!\n";

open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line1 = <FILE>){
    @list = split(/\t/, $line1);
    $rea1 = $list[0];
    $pos1 = $list[3];
    $line2 = <FILE>;
    @list = split(/\t/, $line2);
    $rea2 = $list[0];
    $pos2 = $list[3];
    while($rea1 ne $rea2){
	$rea1 = $rea2;
	$pos1 = $pos2;
	$line1 = $line2;
	$line2 = <FILE>;
	@list = split(/\t/, $line2);
	$rea2 = $list[0];
	$pos2 = $list[3];
    }
    if($pos1 <= $pos2){
	printf(FILE_f "%s", $line1);
	printf(FILE_r "%s", $line2);
    }
    else{
	printf(FILE_f "%s", $line2);
	printf(FILE_r "%s", $line1);
    }
}
close(FILE);

close(FILE_f);
close(FILE_r);
