#! /usr/bin/perl

if($#ARGV != 3){
    printf STDERR "usage: $0 [file] [length] [num] [sco]\n";
    exit -1;
}
$filename = $ARGV[0];
$max = $ARGV[1];
$num = $ARGV[2];
$min_sco = $ARGV[3];

#$num = 4;

$pos = -1000000;
$res = "";
$n = 0;
open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
#    chomp $line;
#    $line =~ s/^[ \t]+//;
#    $line =~ s/[ \t]+$//;
#    @list = split(/[ \t]+/, $line);
    @list = split(/\t/, $line);
    $sco = $list[4];
    if($min_sco <= $sco){
	$chr2 = $list[2];
	$pos2 = $list[3];
	$seq2 = $list[9];
#	$len = $pos2 - $pos + length($seq2);
	$len = $pos2 - $pos;
	if($max < $len || $chr ne $chr2){
	    if($num <= $n){
		printf(STDOUT "Cluster Member: %d\n", $n);
		printf(STDOUT "%s", $res);
		printf(STDOUT "#####\n");
	    }
	    $res = "";
	    $n = 0;
	}
	$res .= $line;
	$pos = $pos2;
	$chr = $chr2;
	$n++;
    }
}
close(FILE);
if($num <= $n){
    printf(STDOUT "Cluster Member: %d\n", $n);
    printf(STDOUT "%s", $res);
    printf(STDOUT "#####\n");
}
