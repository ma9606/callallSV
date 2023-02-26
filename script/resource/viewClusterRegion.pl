#! /usr/bin/perl

if($#ARGV != 0){
    printf STDERR "usage: $0 [file]\n";
    exit -1;
}
$filename0 = $ARGV[0];

open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    $line =~ s/^[ \t]+//;
    $line =~ s/[ \t]+$//;
    @list = split(/[ \t]+/, $line);
    $num = $list[6];

    $chr_sta1 = $list[9];
    $chr_end1 = $list[9 + 5 * ($num - 1)];
    if($chr_sta1 ne $chr_end1){
	printf(STDERR "error1: %s\n", $line);
    }
    $pos_sta1 = $list[10];
    $pos_end1 = $list[10 + 5 * ($num - 1)];
    $str_sta1 = $list[11];
    $str_end1 = $list[11 + 5 * ($num - 1)];
    if($str_sta1 ne $str_end1){
	printf(STDERR "error2: %s\n", $line);
    }

    $chr_sta2 = $list[9 + 5 * $num];
    $chr_end2 = $list[9 + 5 * $num + 5 * ($num - 1)];
    if($chr_sta2 ne $chr_end2){
	printf(STDERR "error3: %s\n", $line);
    }
    $pos_sta2 = $list[10 + 5 * $num];
    $pos_end2 = $list[10 + 5 * $num + 5 * ($num - 1)];
    $str_sta2 = $list[11 + 5 * $num];
    $str_end2 = $list[11 + 5 * $num + 5 * ($num - 1)];
    if($str_sta2 ne $str_end2){
	printf(STDERR "error4: %s\n", $line);
    }

    printf(STDOUT "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
	   $chr_sta1, $str_sta1, $pos_sta1, $pos_end1,
	   $chr_sta2, $str_sta2, $pos_sta2, $pos_end2);
}
close(FILE);
