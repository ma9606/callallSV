#! /usr/bin/perl

if($#ARGV != 2){
    printf STDERR "usage: $0 [file1] [file2] [min. member]\n";
    exit -1;
}
$filename1 = $ARGV[0];
$filename2 = $ARGV[1];
$min = $ARGV[2];

$ok = 1;
$n = 0;
$i = 0;
open(FILE, $filename1) || die "Can not open file $filename1: $!\n";
while($line = <FILE>){
    if($line =~ /^Cluster/){
	chomp $line;
	@list = split(/ /, $line);
	if($min <= $list[2]){
	    $ok = 1;
	}
	else{
	    $ok = 0;
	}
    }
    elsif($line =~ /^\#/){
	if($ok == 1){
	    $res1[$n]->{num} = $i;
	    $i = 0;
	    $n++;
	}
    }
    else{
	if($ok == 1){
	    @list = split(/\t/, $line);
	    $read1 = $list[0];
	    $res1[$n]->{read}[$i] = $read1;
	    $res1[$n]->{line}[$i] = $line;
	    $i++;
	}
    }
}
close(FILE);
$num1 = $n;

$ok = 1;
$n = 0;
$i = 0;
open(FILE, $filename2) || die "Can not open file $filename2: $!\n";
while($line = <FILE>){
    if($line =~ /^Cluster/){
	chomp $line;
	@list = split(/ /, $line);
	if($min <= $list[2]){
	    $ok = 1;
	}
	else{
	    $ok = 0;
	}
    }
    elsif($line =~ /^\#/){
	if($ok == 1){
	    $res2[$n]->{num} = $i;
	    $i = 0;
	    $n++;
	}
    }
    else{
	if($ok == 1){
	    @list = split(/\t/, $line);
	    $read2 = $list[0];
	    $res2[$n]->{read}[$i] = $read2;
	    $res2[$n]->{line}[$i] = $line;
	    $hash{$n}{$read2} = 1;
	    $i++;
	}
    }
}
close(FILE);
$num2 = $n;

for($i = 0; $i < $num1; $i++){
    if($min <= $res1[$i]->{num}){
	for($j = 0; $j < $num2; $j++){
	    if($min <= $res2[$j]->{num}){
		$n = 0;
		for($k = 0; $k < $res1[$i]->{num}; $k++){
		    $read1 = $res1[$i]->{read}[$k];
		    if($hash{$j}{$read1} == 1){
			$n++;
		    }
		}
		if($min <= $n){
		    printf(STDOUT "Cluster Member: %d\n", $res1[$i]->{num});
		    for($k = 0; $k < $res1[$i]->{num}; $k++){
			printf(STDOUT "%s", $res1[$i]->{line}[$k]);
		    }
		    printf(STDOUT "Cluster Member: %d\n", $res2[$j]->{num});
		    for($k = 0; $k < $res2[$j]->{num}; $k++){
			printf(STDOUT "%s", $res2[$j]->{line}[$k]);
		    }
		    printf(STDOUT "#####\n");
		}
	    }
	}
    }
}
