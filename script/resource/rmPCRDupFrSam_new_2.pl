#! /usr/bin/perl

if($#ARGV != 0){
    printf STDERR "usage: $0 [file]\n";
    exit -1;
}
$filename0 = $ARGV[0];

$n = 1;
open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line1 = <FILE>){
    @list1 = split(/\t/, $line1);
    $fla1 = $list1[1];
    $chr1 = $list1[2];
    $sta1 = $list1[3];
    $sco1 = $list1[4];
    $ins1 = $list1[8];
    $line2 = <FILE>;
    @list2 = split(/\t/, $line2);
    $fla2 = $list2[1];
    $chr2 = $list2[2];
    $sta2 = $list2[3];
    $sco2 = $list2[4];
    $ins2 = $list2[8];
    if(($fla1 == 65  && $fla2 == 129) ||
       ($fla1 == 67  && $fla2 == 131) ||
       ($fla1 == 113 && $fla2 == 177) ||
       ($fla1 == 115 && $fla2 == 179) ||
       ($fla1 == 97  && $fla2 == 145) ||
       ($fla1 == 99  && $fla2 == 147) ||
       ($fla1 == 81  && $fla2 == 161) ||
       ($fla1 == 83  && $fla2 == 163)){
	if(($fla1 == 65 && $fla2 == 129) ||
	   ($fla1 == 67 && $fla2 == 131)
	    ){
	    $str1 = "+";
	    $str2 = "+";
	    if($sta1 <= $sta2){
		$key = $sta1 . $str1 . $ins1 . $str2 . $chr1;
	    }
	    else{
		$key = $sta2 . $str2 . $ins2 . $str1 . $chr2;
	    }
	}
	elsif(($fla1 == 113 && $fla2 == 177) ||
	      ($fla1 == 115 && $fla2 == 179)
	    ){
	    $str1 = "-";
	    $str2 = "-";
	    if($sta1 <= $sta2){
		$key = $sta1 . $str1 . $ins1 . $str2 . $chr1;
	    }
	    else{
		$key = $sta2 . $str2 . $ins2 . $str1 . $chr2;
	    }
	}
	elsif(($fla1 == 97 && $fla2 == 145) ||
	      ($fla1 == 99 && $fla2 == 147)
	    ){
	    $str1 = "+";
	    $str2 = "-";
	    $key = $sta1 . $str1 . $ins1 . $str2 . $chr1;
	}
	elsif(($fla1 == 81 && $fla2 == 161) ||
	      ($fla1 == 83 && $fla2 == 163)
	    ){
	    $str1 = "-";
	    $str2 = "+";
	    $key = $sta2 . $str2 . $ins2 . $str1 . $chr2;
	}
	$sco = ($sco1 + $sco2) / 2;
	if($hash_key{$key} eq ""){
	    $res[$n]->{line1} = $line1;
	    $res[$n]->{line2} = $line2;
	    $res[$n]->{sco} = $sco;
	    $hash_key{$key} = $n;
	    $n++;
	}
	else{
	    $i = $hash_key{$key};
	    if($res[$i]->{sco} < $sco){
		$res[$i]->{line1} = $line1;
		$res[$i]->{line2} = $line2;
		$res[$i]->{sco} = $sco;
	    }
	}
    }
    else{
	printf(STDERR "%s", $line1);
	printf(STDERR "%s", $line2);
    }
}
close(FILE);

for($i = 1; $i < $n; $i++){
    printf(STDOUT "%s", $res[$i]->{line1});
    printf(STDOUT "%s", $res[$i]->{line2});
}
