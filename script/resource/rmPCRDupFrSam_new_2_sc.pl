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
#   $ins1 = $list1[8];
    if($#list1==15 && $list1[15] =~ "^SA:Z:"){	# case1: softclip mapping
    	@saz1 = split(/;/, $list1[15]);
	$saz1[0] =~ s/(?:SA:Z:)//; 
	@scmate1 = split(/,/, $saz1[0]);
	if($sta1 < $scmate1[1]){
	    $sta1L =$sta1;         $str1L ="#";
	    $sta1R =$scmate1[1];   $str1R =$scmate1[2];
	}
	else{
	    $sta1L =$scmate1[1];   $str1L =$scmate1[2];
	    $sta1R= $sta1;	   $str1R ="#";
	}
    }
    else {  # case0: full-length match
	$sta1L = $sta1;		$str1L ="#";
	$sta1R = $sta1;		$str1R ="#";
    }    

    $line2 = <FILE>;
    @list2 = split(/\t/, $line2);
    $fla2 = $list2[1];
    $chr2 = $list2[2];
    $sta2 = $list2[3];
    $sco2 = $list2[4];
#   $ins2 = $list2[8];
    if($#list2==15 && $list2[15] =~ "^SA:Z:"){	# case1
	@saz2 = split(/;/, $list2[15]);
	$saz2[0] =~ s/(?:SA:Z:)//;
	@scmate2 = split(/,/, $saz2[0]);
	if($sta2 < $scmate2[1]){
	    $sta2L =$sta2;         $str2L ="#";
	    $sta2R =$scmate2[1];   $str2R =$scmate2[2];
	}
	else{
	    $sta2L =$scmate2[1];   $str2L =$scmate2[2];
	    $sta2R= $sta2;	   $str2R ="#";
	}
    }
    else{  #case0  
	$sta2L = $sta2;		$str2L ="#";
	$sta2R = $sta2;		$str2R ="#";
    }
    $fragEnd = $sta2L + length($line[9]);


    if(($fla1 == 65  && $fla2 == 129) ||
       ($fla1 == 67  && $fla2 == 131) ||
       ($fla1 == 113 && $fla2 == 177) ||
       ($fla1 == 115 && $fla2 == 179) ||
       ($fla1 == 97  && $fla2 == 145) ||
       ($fla1 == 99  && $fla2 == 147) ||
       ($fla1 == 81  && $fla2 == 161) ||
       ($fla1 == 83  && $fla2 == 163)){

	## case.1 :FF 
	if(($fla1 == 65 && $fla2 == 129) ||
	   ($fla1 == 67 && $fla2 == 131)
	    ){
	    if($str1L eq "#"){ $str1L = "+";} else{ $str1R ="+";}
	    if($str2L eq "#"){ $str2L = "+";} else{ $str2R ="+";}
	    if($sta1L <= $sta2L){
		$key = $chr1 . $sta1L.$str1L.$sta1R.$str1R . $sta2L.$str2L.$sta2R.$str2R . $fragEnd;
	    }
	    else{
		$key = $chr1 . $sta2L.$str2L.$sta2R.$str2R . $sta1L.$str1L.$sta1R.$str1R . $fragEnd;
	    }
	}
	## case.2 :RR
	elsif(($fla1 == 113 && $fla2 == 177) ||
	      ($fla1 == 115 && $fla2 == 179)
	    ){
	    if($str1L eq "#"){ $str1L = "-";} else{ $str1R ="-";}
	    if($str2L eq "#"){ $str2L = "-";} else{ $str2R ="-";}
	    if($sta1L <= $sta2L){
		$key = $chr1 . $sta1L.$str1L.$sta1R.$str1R . $sta2L.$str2L.$sta2R.$str2R . $fragEnd;
	    }
	    else{
		$key = $chr1 . $sta2L.$str2L.$sta2R.$str2R . $sta1L.$str1L.$sta1R.$str1R . $fragEnd;
	    }
	}
	## case.3 :FR
	elsif(($fla1 == 97 && $fla2 == 145) ||
	      ($fla1 == 99 && $fla2 == 147)
	    ){
	    if($str1L eq "#"){ $str1L = "+";} else{ $str1R ="+";}
	    if($str2L eq "#"){ $str2L = "-";} else{ $str2R ="-";}
	    $key = $chr1 . $sta1L.$str1L.$sta1R.$str1R . $sta2L.$str2L.$sta2R.$str2R . $fragEnd;
	}
	## case.4 :RF
	elsif(($fla1 == 81 && $fla2 == 161) ||
	      ($fla1 == 83 && $fla2 == 163)
	    ){
	    if($str1L eq "#"){ $str1L = "-";} else{ $str1R ="-";}
	    if($str2L eq "#"){ $str2L = "+";} else{ $str2R ="+";}
	    $key = $chr1 . $sta2L.$str2L.$sta2R.$str2R . $sta1L.$str1L.$sta1R.$str1R . $fragEnd;
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
