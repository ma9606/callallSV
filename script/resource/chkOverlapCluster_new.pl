#! /usr/bin/perl

if($#ARGV != 3){
    printf STDERR "usage: $0 [Nomal file] [Tumor file] [Normal read length] [Tumor read length]\n";
    exit -1;
}
$filename0 = $ARGV[0];
$filename1 = $ARGV[1];
$len_n = $ARGV[2];
$len_t = $ARGV[3];

$n = 0;
open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    $line =~ s/^[ \t]+//;
    $line =~ s/[ \t]+$//;
    @list = split(/[ \t]+/, $line);
    $num = $list[6];

    $res[$n]->{chr_sta1} = $list[9];
    $res[$n]->{chr_end1} = $list[9 + 5 * ($num - 1)];
    if($res[$n]->{chr_sta1} ne $res[$n]->{chr_end1}){
	printf(STDERR "error1: %s\n", $line);
    }
    $res[$n]->{pos_sta1} = $list[10];
    $res[$n]->{pos_end1} = $list[10 + 5 * ($num - 1)] + $len_n - 1;
    $res[$n]->{str_sta1} = $list[11];
    $res[$n]->{str_end1} = $list[11 + 5 * ($num - 1)];
    if($res[$n]->{str_sta1} ne $res[$n]->{str_end1}){
	printf(STDERR "error2: %s\n", $line);
    }

    $res[$n]->{chr_sta2} = $list[9 + 5 * $num];
    $res[$n]->{chr_end2} = $list[9 + 5 * $num + 5 * ($num - 1)];
    if($res[$n]->{chr_sta2} ne $res[$n]->{chr_end2}){
	printf(STDERR "error3: %s\n", $line);
    }
    $res[$n]->{pos_sta2} = $list[10 + 5 * $num];
    $res[$n]->{pos_end2} = $list[10 + 5 * $num + 5 * ($num - 1)] + $len_n - 1;
    $res[$n]->{str_sta2} = $list[11 + 5 * $num];
    $res[$n]->{str_end2} = $list[11 + 5 * $num + 5 * ($num - 1)];
    if($res[$n]->{str_sta2} ne $res[$n]->{str_end2}){
	printf(STDERR "error4: %s\n", $line);
    }

    $n++;
}
close(FILE);

open(FILE, $filename1) || die "Can not open file $filename1: $!\n";
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
    $pos_end1 = $list[10 + 5 * ($num - 1)] + $len_t - 1;
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
    $pos_end2 = $list[10 + 5 * $num + 5 * ($num - 1)] + $len_t - 1;
    $str_sta2 = $list[11 + 5 * $num];
    $str_end2 = $list[11 + 5 * $num + 5 * ($num - 1)];
    if($str_sta2 ne $str_end2){
	printf(STDERR "error4: %s\n", $line);
    }

    $overlap2 = 0;
    for($i = 0; $i < $n; $i++){
	$overlap1 = 0;
	if($chr_sta1 eq $res[$i]->{chr_sta1} && $str_sta1 eq $res[$i]->{str_sta1}){
	    if(($res[$i]->{pos_sta1} <= $pos_sta1 && $pos_sta1 <= $res[$i]->{pos_end1}) ||
	       ($res[$i]->{pos_sta1} <= $pos_end1 && $pos_end1 <= $res[$i]->{pos_end1}) ||
	       ($pos_sta1 <= $res[$i]->{pos_sta1} && $res[$i]->{pos_sta1} <= $pos_end1) ||
	       ($pos_sta1 <= $res[$i]->{pos_end1} && $res[$i]->{pos_end1} <= $pos_end1)){
		$overlap1 = 1;
	    }
	}
	if($chr_sta2 eq $res[$i]->{chr_sta2} && $str_sta2 eq $res[$i]->{str_sta2}){
	    if(($res[$i]->{pos_sta2} <= $pos_sta2 && $pos_sta2 <= $res[$i]->{pos_end2}) ||
	       ($res[$i]->{pos_sta2} <= $pos_end2 && $pos_end2 <= $res[$i]->{pos_end2}) ||
	       ($pos_sta2 <= $res[$i]->{pos_sta2} && $res[$i]->{pos_sta2} <= $pos_end2) ||
	       ($pos_sta2 <= $res[$i]->{pos_end2} && $res[$i]->{pos_end2} <= $pos_end2)){
		if($overlap1 == 1){
		    $overlap2 = 1;
		    last;
		}
	    }
	}
    }

    if($overlap2 == 0){
	printf(STDOUT "%s\n", $line);
    }
}
close(FILE);
