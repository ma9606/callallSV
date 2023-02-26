#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [file] [min. insert]\n";
    exit -1;
}
$filename = $ARGV[0];
$min = $ARGV[1];

open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
    @list = split(/\t/, $line);
    $ins = $list[8];
    if($ins < 0){
	$ins *= -1;
    }
    $line2 = <FILE>;
    @list2 = split(/\t/, $line2);
    $ins2 = $list2[8];
    if($ins2 < 0){
	$ins2 *= -1;
    }
    if($ins ne $ins2){
	printf(STDERR "%s", $line);
	printf(STDERR "%s", $line2);
    }
    else{
	if($min <= $ins){
	    printf(STDOUT "%s", $line);
	    printf(STDOUT "%s", $line2);
	}
    }
}
close(FILE);
