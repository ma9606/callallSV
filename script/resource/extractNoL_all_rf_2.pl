#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [sam file] [cluster list]\n";
    exit -1;
}
$filename0 = $ARGV[0];
$filename1 = $ARGV[1];

$n = 0;
open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    @list = split(/\t/, $line);
    $chr1 = $list[2];
    $pos1 = $list[3];
    $len1 = length($list[9]);
    $line = <FILE>;
    chomp $line;
    @list = split(/\t/, $line);
    $chr2 = $list[2];
    $pos2 = $list[3];
    $len2 = length($list[9]);
    if($pos1 < $pos2){
	$len3 = $pos2 - $pos1;
    }
    else{
	$len3 = $pos1 - $pos2;
    }
    if(10 < $len3){
	if($pos1 < $pos2){
#	    $res[$n]->{str1} = "-";
	    $res[$n]->{chr1} = $chr1;
	    $res[$n]->{sta1} = $pos1;
	    $res[$n]->{end1} = $pos1 + $len1 - 1;
#	    $res[$n]->{str2} = "+";
	    $res[$n]->{chr2} = $chr2;
	    $res[$n]->{sta2} = $pos2;
	    $res[$n]->{end2} = $pos2 + $len2 - 1;
	}
	else{
#	    $res[$n]->{str1} = "-";
	    $res[$n]->{chr1} = $chr2;
	    $res[$n]->{sta1} = $pos2;
	    $res[$n]->{end1} = $pos2 + $len2 - 1;
#	    $res[$n]->{str2} = "+";
	    $res[$n]->{chr2} = $chr1;
	    $res[$n]->{sta2} = $pos1;
	    $res[$n]->{end2} = $pos1 + $len1 - 1;
	}
	$n++;
    }
}
close(FILE);

open(FILE, $filename1) || die "Can not open file $filename1: $!\n";
while($line = <FILE>){
    chomp $line;
    @list = split(/\t/, $line);
    $chr1 = $list[4];
    $sta1 = $list[5];
    $end1 = $list[6];
    $chr2 = $list[9];
    $sta2 = $list[10];
    $end2 = $list[11];
    $ok = 1;
    for($i = 0; $i < $n; $i++){
	if($chr1 eq $res[$i]->{chr1} && 
	   $chr2 eq $res[$i]->{chr2} && 
#	   $str1 eq $res[$i]->{str1} &&
#	   $str2 eq $res[$i]->{str2} &&
	   (($res[$i]->{sta1} <= $sta1 && $sta1 <= $res[$i]->{end1}) || 
	    ($res[$i]->{sta1} <= $end1 && $end1 <= $res[$i]->{end1}) || 
	    ($sta1 <= $res[$i]->{sta1} && $res[$i]->{sta1} <= $end1) || 
	    ($sta1 <= $res[$i]->{end1} && $res[$i]->{end1} <= $end1)) &&
	   (($res[$i]->{sta2} <= $sta2 && $sta2 <= $res[$i]->{end2}) || 
	    ($res[$i]->{sta2} <= $end2 && $end2 <= $res[$i]->{end2}) || 
	    ($sta2 <= $res[$i]->{sta2} && $res[$i]->{sta2} <= $end2) || 
	    ($sta2 <= $res[$i]->{end2} && $res[$i]->{end2} <= $end2))
	   ){
	    $ok = 0;
	    last;
	}
    }
    if($ok == 1){
	printf(STDOUT "%s\n", $line);
    }
}
close(FILE);
