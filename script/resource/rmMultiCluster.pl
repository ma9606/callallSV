#! /usr/bin/perl

if($#ARGV != 0){
    printf STDERR "usage: $0 [file]\n";
    exit -1;
}
$filename = $ARGV[0];

$i = 0;
$n = 0;
open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
    if($line =~ /^Cluster/){
	if($i != 0){
	    $res[$n]->{chr} = $chr;
	    $res[$n]->{sta} = $sta;
	    $res[$n]->{end} = $end;
	    $n++;
	    $i = 0;
	}
    }
    elsif($line =~ /^\#/){
	if($i != 0){
	    $res[$n]->{chr} = $chr;
	    $res[$n]->{sta} = $sta;
	    $res[$n]->{end} = $end;
	    $n++;
	    $i = 0;
	}
    }
    else{
	@list = split(/\t/, $line);
	if($i == 0){
	    $chr = $list[2];
	    $sta = $list[3];
	}
	else{
	    $end = $list[3];
	}
	$i++;
    }
}
close(FILE);
$num = $n;

$i = 0;
$n = 0;
$ok = 1;
$res = "";
open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
    $res .= $line;
    if($line =~ /^Cluster/){
	if($i != 0){
	    for($j = 0; $j < $num; $j++){
		if($j != $n){
		    if($chr eq $res[$j]->{chr}){
			if(($sta <= $res[$j]->{sta} && $res[$j]->{sta} <= $end) ||
			   ($sta <= $res[$j]->{end} && $res[$j]->{end} <= $end) ||
			   ($res[$j]->{sta} <= $sta && $sta <= $res[$j]->{end}) ||
			   ($res[$j]->{sta} <= $end && $end <= $res[$j]->{end})
			   ){
			    $ok = 0;
			    break;
			}
		    }
		}
	    }
	    $n++;
	    $i = 0;
	}
    }
    elsif($line =~ /^\#/){
	if($ok == 1){
	    for($j = 0; $j < $num; $j++){
		if($j != $n){
		    if($chr eq $res[$j]->{chr}){
			if(($sta <= $res[$j]->{sta} && $res[$j]->{sta} <= $end) ||
			   ($sta <= $res[$j]->{end} && $res[$j]->{end} <= $end) ||
			   ($res[$j]->{sta} <= $sta && $sta <= $res[$j]->{end}) ||
			   ($res[$j]->{sta} <= $end && $end <= $res[$j]->{end})
			   ){
			    $ok = 0;
			    break;
			}
		    }
		}
	    }
	}
	if($ok == 1){
	    printf(STDOUT "%s", $res);
	}
	$n++;
	$i = 0;
	$res = "";
	$ok = 1;
    }
    else{
	@list = split(/\t/, $line);
	if($i == 0){
	    $chr = $list[2];
	    $sta = $list[3];
	}
	else{
	    $end = $list[3];
	}
	$i++;
    }
}
close(FILE);
