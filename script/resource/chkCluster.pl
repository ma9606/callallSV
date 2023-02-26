#! /usr/bin/perl

if($#ARGV != 2){
    printf STDERR "usage: $0 [file] [min. menber] [length]\n";
    exit -1;
}
$filename = $ARGV[0];
$min = $ARGV[1];
$maxLen = $ARGV[2];

$n = 0;
$num1 = 0;
$num2 = 0;
$n1 = 0;
$n2 = 0;
$pos = -1000000;
open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
    if($line =~ /^Cluster/){
	if($n == 1){
	    if($min <= $num1){
		$res1[$n1]->{num} = $num1;
		$n1++;
	    }
	}
	$n++;
	$pos = -1000000;
    }
    elsif($line =~ /^\#/){
	if($n == 2){
	    if($min <= $num2){
		$res2[$n2]->{num} = $num2;
		$n2++;
	    }
	}
	for($i1 = 0; $i1 < $n1; $i1++){
	    $num1 = $res1[$i1]->{num};
	    for($i2 = 0; $i2 < $n2; $i2++){
		$num2 = $res2[$i2]->{num};
		$num = 0;
		for($i = 0; $i < $num1; $i++){
		    $pair1[$i] = 0;
		}
		for($j = 0; $j < $num2; $j++){
		    $pair2[$j] = 0;
		}
		for($i = 0; $i <  $num1; $i++){
		    for($j = 0; $j < $num2; $j++){
			if($res1[$i1]->{read}[$i] eq $res2[$i2]->{read}[$j]){
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
			    printf(STDOUT "%s", $res1[$i1]->{line}[$i]);
			}
		    }
		    printf(STDOUT "Cluster Member: %d\n", $num);
		    for($j = 0; $j < $num2; $j++){
			if($pair2[$j] == 1){
			    printf(STDOUT "%s", $res2[$i2]->{line}[$j]);
			}
		    }
		    printf(STDOUT "#####\n");
		}
	    }
	}
	$n = 0;
	$num1 = 0;
	$num2 = 0;
	$n1 = 0;
	$n2 = 0;
	$pos = -1000000;
    }
    else{
	@list = split(/\t/, $line);
	$read = $list[0];
	$pos2 = $list[3];
	$len = $pos2 - $pos;
	if($n == 1){
	    if($maxLen < $len){
		if($min <= $num1){
		    $res1[$n1]->{num} = $num1;
		    $n1++;
		}
		$num1 = 0;
	    }
	    $res1[$n1]->{read}[$num1] = $read;
	    $res1[$n1]->{line}[$num1] = $line;
	    $num1++;
	}
	elsif($n == 2){
	    if($maxLen < $len){
		if($min <= $num2){
		    $res2[$n2]->{num} = $num2;
		    $n2++;
		}
		$num2 = 0;
	    }
	    $res2[$n2]->{read}[$num2] = $read;
	    $res2[$n2]->{line}[$num2] = $line;
	    $num2++;
	}
	$pos = $pos2;
    }
}
close(FILE);
