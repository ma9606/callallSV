#! /usr/bin/perl

if($#ARGV != 0){
    printf STDERR "usage: $0 [file]\n";
    exit -1;
}
$filename = $ARGV[0];

$n = 0;
$res = "";
$res1 = "";
$res2 = "";
open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
    $res .= $line;
    if($line =~ /^Cluster/){
	$n++;
    }
    elsif($line =~ /^\#/){
	$key1 = $res1 . $res2;
	$key2 = $res2 . $res1;
	if($hash{$key2} != 1){
	    printf(STDOUT "%s", $res);
	    $hash{$key1} = 1;
	}
	$n = 0;
	$res = "";
	$res1 = "";
	$res2 = "";
    }
    else{
	@list = split(/\t/, $line);
	$name = $list[0];
	if($n == 1){
	    $res1 .= $name;
	}
	elsif($n == 2){
	    $res2 .= $name;
	}
    }
}
close(FILE);
