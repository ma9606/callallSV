#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [file] [min. menber]\n";
    exit -1;
}
$filename = $ARGV[0];
$min = $ARGV[1];

$n = 0;
$num1 = 0;
$num2 = 0;
open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
    if($line =~ /^Cluster/){
	$n++;
    }
    elsif($line =~ /^\#/){
	$num = 0;
	for($i = 0; $i < $num1; $i++){
	    $pair1[$i] = 0;
	}
	for($j = 0; $j < $num2; $j++){
	    $pair2[$j] = 0;
	}
	for($i = 0; $i < $num1; $i++){
	    for($j = 0; $j < $num2; $j++){
		if($read1[$i] eq $read2[$j]){
		    $pair1[$i] = 1;
		    $pair2[$j] = 1;
		    $num++;
		}
	    }
	}
	if($min <= $num){
	    printf(STDOUT "Cluster Member: %d\n", $num);
	    for($i = 0; $i < $num1; $i++){
		if($pair1[$i] == 1){
		    printf(STDOUT "%s", $line1[$i]);
		}
	    }
	    printf(STDOUT "Cluster Member: %d\n", $num);
	    for($j = 0; $j < $num2; $j++){
		if($pair2[$j] == 1){
		    printf(STDOUT "%s", $line2[$j]);
		}
	    }
	    printf(STDOUT "#####\n");
	}
	$n = 0;
	$num1 = 0;
	$num2 = 0;
    }
    else{
	@list = split(/\t/, $line);
	$read = $list[0];
	if($n == 1){
	    $read1[$num1] = $read;
	    $line1[$num1] = $line;
	    $num1++;
	}
	elsif($n == 2){
	    $read2[$num2] = $read;
	    $line2[$num2] = $line;
	    $num2++;
	}
    }
}
close(FILE);
