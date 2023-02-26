#! /usr/bin/perl

if($#ARGV != 2){
    printf STDERR "usage: $0 [List file] [Cluter file] [length]\n";
    exit -1;
}
$filename0 = $ARGV[0];
$filename1 = $ARGV[1];
$len = $ARGV[2];

open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    @list = split(/\t/, $line);
    $hash{$list[0]}{$list[1]}{$list[2]}{$list[3]}{$list[5]}{$list[6]}{$list[7]}{$list[8]} = 1;
}
close(FILE);

$i = 0;
$n = 0;
$res = "";
open(FILE, $filename1) || die "Can not open file $filename1: $!\n";
while($line = <FILE>){
    $res .= $line;
    if($line =~ /^Cluster/){
	$n++;
	$i = 0;
    }
    elsif($line =~ /^\#/){
#	printf(STDERR "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", $chr1, $str1, $sta1, $end1, $chr2, $str2, $sta2, $end2);
	if($hash{$chr1}{$str1}{$sta1}{$end1}{$chr2}{$str2}{$sta2}{$end2} == 1){
	    printf(STDOUT "%s", $res);
	}
	$n = 0;
	$i = 0;
	$res = "";
    }
    else{
	@list = split(/\t/, $line);
	if($i == 0){
	    $dir = $list[1];
	    if($dir == 97  ||
	       $dir == 99  ||
	       $dir == 161 ||
	       $dir == 163 ||
	       $dir == 65  ||
	       $dir == 129
		){
		$str = "+";
	    }
	    elsif($dir == 145 ||
		  $dir == 147 ||
		  $dir == 81  ||
		  $dir == 83  ||
		  $dir == 113  ||
		  $dir == 177
		){
		$str = "-";
	    }
	    else{
		printf(STDERR "error: %s", $line);
	    }
	    if($n == 1){
		$chr1 = $list[2];
		$sta1 = $list[3];
		$str1 = $str;
	    }
	    elsif($n == 2){
		$chr2 = $list[2];
		$sta2 = $list[3];
		$str2 = $str;
	    }
	}
	else{
	    if($n == 1){
		$end1 = $list[3] + $len - 1;
	    }
	    elsif($n == 2){
		$end2 = $list[3] + $len - 1;
	    }
	}
	$i++;
    }
}
close(FILE);
