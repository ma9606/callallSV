#! /usr/bin/perl

if($#ARGV != 0){
    printf STDERR "usage: $0 [file]\n";
    exit -1;
}
$filename0 = $ARGV[0];

open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
$line = <FILE>;
printf(STDOUT "%s", $line);
while($line = <FILE>){
    chomp $line;
    @list = split(/\t/, $line);
    if(14 <= $#list){
	printf(STDOUT "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s", 
	       $list[0], $list[1], $list[2], $list[3], $list[4], $list[5], $list[6], $list[7], $list[8], $list[9], $list[10], $list[11], $list[12], $list[13]);
	$n_5 = 0;
	$n_3 = 0;
	$n_b = 0;
	for($i = 14; $i <= $#list; $i++){
	    @list2 = split(/:/, $list[$i]);
	    if($list2[0] eq "5'_side"){
		$res_5[$n_5] = $list[$i];
		$n_5++;
	    }
	    elsif($list2[0] eq "3'_side"){
		$res_3[$n_3] = $list[$i];
		$n_3++;
	    }
	    elsif($list2[0] eq "Both_side"){
		$res_b[$n_b] = $list[$i];
		$n_b++;
	    }
	    else{
		printf(STDERR "error: %s\n", $list[$i]);
	    }
	}
	for($i = 0; $i < $n_5; $i++){
	    printf(STDOUT "\t%s", $res_5[$i]);
	}
	for($i = 0; $i < $n_3; $i++){
	    printf(STDOUT "\t%s", $res_3[$i]);
	}
	for($i = 0; $i < $n_b; $i++){
	    printf(STDOUT "\t%s", $res_b[$i]);
	}
	printf(STDOUT "\n");
    }
    else{
	printf(STDOUT "%s\n", $line);
    }
}
close(FILE);
