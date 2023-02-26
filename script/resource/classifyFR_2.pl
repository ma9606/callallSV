#! /usr/bin/perl

if($#ARGV != 0){
    printf STDERR "usage: $0 [sam file]\n";
    exit -1;
}
$filename = $ARGV[0];

open(FILE_f, "> $filename.ff") || die "Can not open file $filename.cla.um: $!\n";
open(FILE_r, "> $filename.rr") || die "Can not open file $filename.cla.se: $!\n";

open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
    @list = split(/\t/, $line);
    $flag = $list[1];
    $chr = $list[6];
    if(
       $flag == 65 ||
       $flag == 129
       ){
	printf(FILE_f "%s", $line);
    }
    elsif(
	  $flag == 113 ||
	  $flag == 177
	  ){
	printf(FILE_r "%s", $line);
    }
}
close(FILE);

close(FILE_f);
close(FILE_r);
