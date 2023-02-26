#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [file] [length]\n";
    exit -1;
}
$filename = $ARGV[0];
$len = $ARGV[1];

$i = 0;
$total = 0;
open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
    if($line =~ /^Cluster/){
	if($i != 0){
	    $ins = $total / $i;
	    printf(STDOUT "%d\t", $i);
	    printf(STDOUT "%s\t%d\t%d\t%d\t", $chr, $sta, $end, $end - $sta + 1);
	    $i = 0;
	    $total = 0;
	}
    }
    elsif($line =~ /^\#/){
	if($i != 0){
	    printf(STDOUT "%s\t%d\t%d\t%d\t", $chr, $sta, $end, $end - $sta + 1);
	    printf(STDOUT "%d\n", $ins);
	    $i = 0;
	    $total = 0;
	}
    }
    else{
	@list = split(/\t/, $line);
	if($i == 0){
	    $chr = $list[2];
	    $sta = $list[3];
	}
	else{
	    $end = $list[3] + $len - 1;
	}
	$total += $list[8];
	$i++;
    }
}
close(FILE);
