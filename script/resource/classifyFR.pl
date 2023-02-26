#! /usr/bin/perl

if($#ARGV != 0){
    printf STDERR "usage: $0 [sam file]\n";
    exit -1;
}
$filename = $ARGV[0];

open(FILE_f, "> $filename.+") || die "Can not open file $filename.cla.um: $!\n";
open(FILE_r, "> $filename.-") || die "Can not open file $filename.cla.se: $!\n";

open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
    @list = split(/\t/, $line);
    $flag = $list[1];
    $chr = $list[6];
    if(
       $flag == 97 ||
       $flag == 99 ||
       $flag == 161 ||
       $flag == 163 ||
       $flag == 65 ||
       $flag == 129
       ){
	printf(FILE_f "%s", $line);
    }
    elsif(
	  $flag == 145 ||
	  $flag == 147 ||
	  $flag == 81 ||
	  $flag == 83 ||
	  $flag == 113 ||
	  $flag == 177
	  ){
	printf(FILE_r "%s", $line);
    }
    else{
	printf(STDOUT "1\t%s", $line);
    }
}
close(FILE);

close(FILE_f);
close(FILE_r);
