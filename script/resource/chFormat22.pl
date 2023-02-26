#! /usr/bin/perl

if($#ARGV != 0){
    printf STDERR "usage: $0 [file]\n";
    exit -1;
}
$filename0 = $ARGV[0];

open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
$line = <FILE>;
printf(STDOUT "%s", $line);
while($line = <FILE>){
    chomp $line;
    @list = split(/\t/, $line);
    $dir = $list[0];
    if(14 <= $#list){
	$side5_p = 0;
	$side5_m = 0;
	$side3_p = 0;
	$side3_m = 0;
	for($i = 14; $i <= $#list; $i++){
	    @list2 = split(/:/, $list[$i]);
	    if($list2[0] eq "5'_side"){
		if($list2[1] eq "+"){
		    $side5_p = 1;
		}
		elsif($list2[1] eq "-"){
		    $side5_m = 1;
		}
	    }
	    if($list2[0] eq "3'_side"){
		if($list2[1] eq "+"){
		    $side3_p = 1;
		}
		elsif($list2[1] eq "-"){
		    $side3_m = 1;
		}
	    }
	}
	if($dir eq "FF" || $dir eq "RR"){
	    if(($side5_p == 1 && $side3_m == 1) ||
	       ($side5_m == 1 && $side3_p == 1)){
		printf(STDOUT "%s\n", $line);
	    }
	}
	else{
	    if(($side5_p == 1 && $side3_p == 1) ||
	       ($side5_m == 1 && $side3_m == 1)){
		printf(STDOUT "%s\n", $line);
	    }
	}
    }
}
close(FILE);
