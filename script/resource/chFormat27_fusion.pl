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
	    if($hash5{$list3[0]} != 1){
		$hash5{$list3[0]} = 1;
		$gene5[$n5] = $list3[0];
		$str5[$n5] = $list2[1];
		$n5++;
	    }
	}
	elsif($list2[0] eq "3'_side"){
	    if($hash3{$list3[0]} != 1){
		$hash3{$list3[0]} = 1;
		$gene3[$n3] = $list3[0];
		$str3[$n3] = $list2[1];
		$n3++;
	    }
	}
	else{
	    printf(STDERR "error1: %s\n", $line);
	}
    }
    printf(STDOUT "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t", $list[0], $list[1], $list[2], $list[3], $list[4], $list[5], $list[6], $list[7]);
    for($i = 0; $i < $n5; $i++){
	printf(STDOUT "%s, ", $gene5[$i]);
    }
    printf(STDOUT "\t%s\t%s\t%s\t%s\t", $list[8], $list[9], $list[10], $list[11]);
    for($i = 0; $i < $n3; $i++){
	printf(STDOUT "%s, ", $gene3[$i]);
    }
    printf(STDOUT "\t%s\t%s", $list[12], $list[13]);
    for($i = 0; $i < $n5; $i++){
	for($j = 0; $j < $n3; $j++){
	    if($dir eq "FR"){
		if($str5[$i] eq "+" && $str3[$j] eq "+"){
		    printf(STDOUT "\t%s-%s", $gene5[$i], $gene3[$j]);
		}
		elsif($str5[$i] eq "-" && $str3[$j] eq "-"){
		    printf(STDOUT "\t%s-%s", $gene3[$j], $gene5[$i]);
		}
	    }
	    elsif($dir eq "RF"){
		if($str5[$i] eq "+" && $str3[$j] eq "+"){
		    printf(STDOUT "\t%s-%s", $gene3[$j], $gene5[$i]);
		}
		elsif($str5[$i] eq "-" && $str3[$j] eq "-"){
		    printf(STDOUT "\t%s-%s", $gene5[$i], $gene3[$j]);
		}
	    }
	    elsif($dir eq "FF"){
		if($str5[$i] eq "+" && $str3[$j] eq "-"){
		    printf(STDOUT "\t%s-%s", $gene5[$i], $gene3[$j]);
		}
		elsif($str5[$i] eq "-" && $str3[$j] eq "+"){
		    printf(STDOUT "\t%s-%s", $gene3[$j], $gene5[$i]);
		}
	    }
	    elsif($dir eq "RR"){
		if($str5[$i] eq "+" && $str3[$j] eq "-"){
		    printf(STDOUT "\t%s-%s", $gene3[$j], $gene5[$i]);
		}
		elsif($str5[$i] eq "-" && $str3[$j] eq "+"){
		    printf(STDOUT "\t%s-%s", $gene5[$i], $gene3[$j]);
		}
	    }
	    else{
		printf(STDERR "error2: %s\n", $line);
	    }
	}
    }
    printf(STDOUT "\n");
}
close(FILE);
