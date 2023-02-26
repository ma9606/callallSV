#! /usr/bin/perl

if($#ARGV != 0){
    printf STDERR "usage: $0 [file]\n";
    exit -1;
}
$filename0 = $ARGV[0];

open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    @list = split(/\t/, $line);
    $dir = $list[0];
    $sample = $list[1];
    $class = $list[2];
    $read = $list[3];
    $chr1 = $list[4];
    $pos1_5 = $list[5];
    $pos1_3 = $list[6];
    $chr2 = $list[9];
    $pos2_5 = $list[10];
    $pos2_3 = $list[11];
    $dis = $list[15];
    $fusion = $list[16];
    if($dir eq "FR"){
	$pos1 = $pos1_3;
	$pos2 = $pos2_5;
    }
    elsif($dir eq "FF"){
	$pos1 = $pos1_3;
	$pos2 = $pos2_3;
    }
    elsif($dir eq "RR"){
	$pos1 = $pos1_5;
	$pos2 = $pos2_5;
    }
    elsif($dir eq "RF"){
	$pos1 = $pos1_5;
	$pos2 = $pos2_3;
    }
    else{
	printf(STDERR "error: %s\n", $line);
    }
    printf(STDOUT "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", 
	   $fusion, $sample, $class, $read, $chr1, $pos1, $chr2, $pos2, $dis);
}
close(FILE);
