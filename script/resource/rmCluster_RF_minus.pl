#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [file1] [min. member]\n";
    exit -1;
}
$filename = $ARGV[0];
$min = $ARGV[1];

open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
    if($line =~ /^Cluster/){
	$res = "";
	$n = 0;
    }
    elsif($line =~ /^\#/){
	$res .= $line;
	if($min <= $n){
	    printf(STDOUT "Cluster Member: %d\n", $n);
	    printf(STDOUT "%s", $res);
	}
    }
    else{
	@list = split(/\t/, $line);
	$ins = $list[8];
	if($ins > -40){
	    $res .= $line;
	    $n++;
	}
    }
}
close(FILE);
