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
    if($list[0] eq "FR"){
	$pos1 = $list[6];
	$pos2 = $list[9];
    }
    elsif($list[0] eq "FF"){
	$pos1 = $list[6];
	$pos2 = $list[10];
    }
    elsif($list[0] eq "RR"){
	$pos1 = $list[5];
	$pos2 = $list[9];
    }
    elsif($list[0] eq "RF"){
	$pos1 = $list[5];
	$pos2 = $list[10];
    }
    else{
	printf(STDERR "error: %s\n", $line);
    }
#    printf(STDOUT "%d\t%d\t%s\n", $pos1, $pos2, $line);
    printf(STDOUT "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", $list[1], $list[2], $list[3], $list[4], $pos1, $list[8], $pos2, $list[12]);
}
close(FILE);
