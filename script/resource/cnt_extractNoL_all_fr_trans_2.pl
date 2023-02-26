#! /usr/bin/perl

if($#ARGV < 1){
    printf STDERR "usage: $0 [sam file] [cluster list] (No. allowed OverLap)\n";
    exit -1;
}
$filename0 = $ARGV[0];
$filename1 = $ARGV[1];
if($#ARGV==2){$AL = $ARGV[2] + 1;} else {$AL=1;}

$n = 0;
open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    @list = split(/\t/, $line);
    $fla1 = $list[1];
    $chr1 = $list[2];
    $pos1 = $list[3];
    $len1 = length($list[9]);
    $line = <FILE>;
    chomp $line;
    @list = split(/\t/, $line);
    $fla2 = $list[1];
    $chr2 = $list[2];
    $pos2 = $list[3];
    $len2 = length($list[9]);
    if(($fla1 == 97 && $fla2 == 145) ||
       ($fla1 == 99 && $fla2 == 147) ||
       ($fla1 == 161 && $fla2 == 81) ||
       ($fla1 == 163 && $fla2 == 83)){
#	$res[$n]->{str1} = "+";
	$res[$n]->{chr1} = $chr1;
	$res[$n]->{sta1} = $pos1;
	$res[$n]->{end1} = $pos1 + $len1 - 1;
#	$res[$n]->{str2} = "-";
	$res[$n]->{chr2} = $chr2;
	$res[$n]->{sta2} = $pos2;
	$res[$n]->{end2} = $pos2 + $len2 - 1;
    }
    elsif(($fla1 == 145 && $fla2 == 97) ||
	  ($fla1 == 147 && $fla2 == 99) ||
	  ($fla1 == 81 && $fla2 == 161) ||
	  ($fla1 == 83 && $fla2 == 163)){
#	$res[$n]->{str1} = "+";
	$res[$n]->{chr1} = $chr2;
	$res[$n]->{sta1} = $pos2;
	$res[$n]->{end1} = $pos2 + $len2 - 1;
#	$res[$n]->{str2} = "-";
	$res[$n]->{chr2} = $chr1;
	$res[$n]->{sta2} = $pos1;
	$res[$n]->{end2} = $pos1 + $len1 - 1;
    }
#    else{
#	printf(STDERR "error: %s\n", $line);
#    }
    $n++;
}
close(FILE);

open(FILE, $filename1) || die "Can not open file $filename1: $!\n";
$cnt =0;
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
	    $cnt++;
	}
    }
    if($cnt != 0){
	printf(STDOUT "%d\t%s\n", $cnt,$line);
       $cnt = 0;
    }
}
close(FILE);
