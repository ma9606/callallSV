#! /usr/bin/perl

if($#ARGV != 0){
    printf STDERR "usage: $0 [file]\n";
    exit -1;
}
$filename0 = $ARGV[0];

open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
$line = <FILE>;
while($line = <FILE>){
    chomp $line;
    @list = split(/\t/, $line);
    $dir = $list[0];
    $n5 = 0;
    $n3 = 0;
    undef %hash5;
    undef %hash3;
    for($i = 14; $i <= $#list; $i++){
	@list2 = split(/:/, $list[$i]);
	@list3 = split(/,/, $list2[$#list2]);
	if($list2[0] eq "5'_side"){
	    if($hash5{$list3[1]} != 1){
		$hash5{$list3[1]} = 1;
		$gene5[$n5] = $list3[0];
		$str5[$n5] = $list2[1];
		$frame5[$n5] = $list2[2];
		$ok5[$n5] = 0;
		$n5++;
	    }
	}
	elsif($list2[0] eq "3'_side"){
	    if($hash3{$list3[1]} != 1){
		$hash3{$list3[1]} = 1;
		$gene3[$n3] = $list3[0];
		$str3[$n3] = $list2[1];
		$frame3[$n3] = $list2[2];
		$ok3[$n3] = 0;
		$n3++;
	    }
	}
	else{
	    printf(STDERR "error1: %s\n", $line);
	}
    }
    $k = 0;
    for($i = 0; $i < $n5; $i++){
	if($frame5[$i] eq "0" || $frame5[$i] eq "1" || $frame5[$i] eq "2"){
	    for($j = 0; $j < $n3; $j++){
		if($frame5[$i] eq $frame3[$j]){
		    if($dir eq "FR"){
			if($str5[$i] eq "+" && $str3[$j] eq "+"){
			    $ok5[$i] = 1;
			    $ok3[$j] = 1;
			    $fusion[$k] = "$gene5[$i]-$gene3[$j]";
			    $k++;
			}
			elsif($str5[$i] eq "-" && $str3[$j] eq "-"){
			    $ok5[$i] = 1;
			    $ok3[$j] = 1;
			    $fusion[$k] = "$gene3[$j]-$gene5[$i]";
			    $k++;
			}
		    }
		    elsif($dir eq "RF"){
			if($str5[$i] eq "+" && $str3[$j] eq "+"){
			    $ok5[$i] = 1;
			    $ok3[$j] = 1;
			    $fusion[$k] = "$gene3[$j]-$gene5[$i]";
			    $k++;
			}
			elsif($str5[$i] eq "-" && $str3[$j] eq "-"){
			    $ok5[$i] = 1;
			    $ok3[$j] = 1;
			    $fusion[$k] = "$gene5[$i]-$gene3[$j]";
			    $k++;
			}
		    }
		    elsif($dir eq "FF"){
			if($str5[$i] eq "+" && $str3[$j] eq "-"){
			    $ok5[$i] = 1;
			    $ok3[$j] = 1;
			    $fusion[$k] = "$gene5[$i]-$gene3[$j]";
			    $k++;
			}
			elsif($str5[$i] eq "-" && $str3[$j] eq "+"){
			    $ok5[$i] = 1;
			    $ok3[$j] = 1;
			    $fusion[$k] = "$gene3[$j]-$gene5[$i]";
			    $k++;
			}
		    }
		    elsif($dir eq "RR"){
			if($str5[$i] eq "+" && $str3[$j] eq "-"){
			    $ok5[$i] = 1;
			    $ok3[$j] = 1;
			    $fusion[$k] = "$gene3[$j]-$gene5[$i]";
			    $k++;
			}
			elsif($str5[$i] eq "-" && $str3[$j] eq "+"){
			    $ok5[$i] = 1;
			    $ok3[$j] = 1;
			    $fusion[$k] = "$gene5[$i]-$gene3[$j]";
			    $k++;
			}
		    }
		    else{
			printf(STDERR "error2: %s\n", $line);
		    }
		}
	    }
	}
    }
    if($k > 0){
	printf(STDOUT "%s\n", $line);
    }
}
close(FILE);
