#! /usr/bin/perl

if($#ARGV != 2){
    printf STDERR "usage: $0 [sam file] [cluster list] [length]\n";
    exit -1;
}
$filename0 = $ARGV[0];
$filename1 = $ARGV[1];
$len = $ARGV[2];

$n = 0;
open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    @list = split(/\t/, $line);
    $fla1 = $list[1];
    $chr1 = $list[2];
    $pos1 = $list[3];
    $res1 = $line;
    $line = <FILE>;
    chomp $line;
    @list = split(/\t/, $line);
    $fla2 = $list[1];
    $chr2 = $list[2];
    $pos2 = $list[3];
    $res2 = $line;
    if($fla1 == 113 && $fla2 == 177){
	$res[$n]->{str1} = "-";
	$res[$n]->{chr1} = $chr1;
	$res[$n]->{sta1} = $pos1;
	$res[$n]->{end1} = $pos1 + $len - 1;
	$res[$n]->{str2} = "-";
	$res[$n]->{chr2} = $chr2;
	$res[$n]->{sta2} = $pos2;
	$res[$n]->{end2} = $pos2 + $len - 1;
    }
    elsif($fla1 == 177 && $fla2 == 113){
	$res[$n]->{str1} = "-";
	$res[$n]->{chr1} = $chr2;
	$res[$n]->{sta1} = $pos2;
	$res[$n]->{end1} = $pos2 + $len - 1;
	$res[$n]->{str2} = "-";
	$res[$n]->{chr2} = $chr1;
	$res[$n]->{sta2} = $pos1;
	$res[$n]->{end2} = $pos1 + $len - 1;
    }
#    else{
#	printf(STDERR "error: %s\n", $line);
#    }
    $n++;
}
close(FILE);

open(FILE, $filename1) || die "Can not open file $filename1: $!\n";
while($line = <FILE>){
    chomp $line;
    @list = split(/\t/, $line);
    $chr1 = $list[0];
    $str1 = $list[1];
    $sta1 = $list[2];
    $end1 = $list[3];
    $chr2 = $list[5];
    $str2 = $list[6];
    $sta2 = $list[7];
    $end2 = $list[8];
    $ok = 1;
    for($i = 0; $i < $n; $i++){
	if($chr1 eq $res[$i]->{chr1} && 
	   $chr2 eq $res[$i]->{chr2} && 
	   $str1 eq $res[$i]->{str1} &&
	   $str2 eq $res[$i]->{str2} &&
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
	elsif($chr1 eq $res[$i]->{chr2} && 
	      $chr2 eq $res[$i]->{chr1} && 
	      $str1 eq $res[$i]->{str2} &&
	      $str2 eq $res[$i]->{str1} &&
	      (($res[$i]->{sta2} <= $sta1 && $sta1 <= $res[$i]->{end2}) || 
	       ($res[$i]->{sta2} <= $end1 && $end1 <= $res[$i]->{end2}) || 
	       ($sta1 <= $res[$i]->{sta2} && $res[$i]->{sta2} <= $end1) || 
	       ($sta1 <= $res[$i]->{end2} && $res[$i]->{end2} <= $end1)) &&
	      (($res[$i]->{sta1} <= $sta2 && $sta2 <= $res[$i]->{end1}) || 
	       ($res[$i]->{sta1} <= $end2 && $end2 <= $res[$i]->{end1}) || 
	       ($sta2 <= $res[$i]->{sta1} && $res[$i]->{sta1} <= $end2) || 
	       ($sta2 <= $res[$i]->{end1} && $res[$i]->{end1} <= $end2))
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
