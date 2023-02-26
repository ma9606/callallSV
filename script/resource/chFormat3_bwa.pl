#! /usr/bin/perl

if($#ARGV != 0){
    printf STDERR "usage: $0 [file]\n";
    exit -1;
}
$filename = $ARGV[0];

$total = 0;
$ok = 0;
$n = 0;
open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
    chomp $line;
    $line =~ s/^[ \t]+//;
    $line =~ s/[ \t]+$//;
    @list = split(/[ \t]+/, $line);
    if($line =~ /^Cluster/){
	if($ok == 0){
	    printf(STDOUT "%d", $list[2]);
	    $ok = 1;
	    $n = 0;
	}
	else{
	    $ok = 2;
	    $n = 0;
	}
    }
    elsif($line =~ /^\#/){
	$av = $total / $n;
	printf(STDOUT "\t%d", $av);
	for($i = 0; $i < $n; $i++){
	    printf(STDOUT "\t%s", $res1[$i]->{nam});
	    printf(STDOUT "\t%s", $res1[$i]->{chr});
	    printf(STDOUT "\t%s", $res1[$i]->{pos});
	    printf(STDOUT "\t%s", $res1[$i]->{str});
	    printf(STDOUT "\t%s", $res1[$i]->{ins});
	}
	for($i = 0; $i < $n; $i++){
	    printf(STDOUT "\t%s", $res2[$i]->{nam});
	    printf(STDOUT "\t%s", $res2[$i]->{chr});
	    printf(STDOUT "\t%s", $res2[$i]->{pos});
	    printf(STDOUT "\t%s", $res2[$i]->{str});
	    printf(STDOUT "\t%s", $res2[$i]->{ins});
	}
	printf(STDOUT "\n");
	$total = 0;
	$ok = 0;
	$n = 0;
    }
    else{
	if($ok == 1){
	    $res1[$n]->{nam} = $list[0];
	    $res1[$n]->{chr} = $list[2];
	    $res1[$n]->{pos} = $list[3];
	    $res1[$n]->{ins} = $list[8];
	    if($list[1] == 97 ||
	       $list[1] == 99 ||
	       $list[1] == 161 ||
	       $list[1] == 163 ||
	       $list[1] == 65 ||
	       $list[1] == 129
	       ){
		$res1[$n]->{str} = "+";
	    }
	    elsif($list[1] == 145 ||
		  $list[1] == 147 ||
		  $list[1] == 81 ||
		  $list[1] == 83 ||
		  $list[1] == 113 ||
		  $list[1] == 177
		  ){
		$res1[$n]->{str} = "-";
	    }
	    else{
		printf(STDERR "error1: %s\n", $list[1]);
	    }
	    $total += $list[8];
	    $n++;
	}
	elsif($ok == 2){
	    $res2[$n]->{nam} = $list[0];
	    $res2[$n]->{chr} = $list[2];
	    $res2[$n]->{pos} = $list[3];
	    $res2[$n]->{ins} = $list[8];
	    if($list[1] == 97 ||
	       $list[1] == 99 ||
	       $list[1] == 161 ||
	       $list[1] == 163 ||
	       $list[1] == 65 ||
	       $list[1] == 129
	       ){
		$res2[$n]->{str} = "+";
	    }
	    elsif($list[1] == 145 ||
		  $list[1] == 147 ||
		  $list[1] == 81 ||
		  $list[1] == 83 ||
		  $list[1] == 113 ||
		  $list[1] == 177
		  ){
		$res2[$n]->{str} = "-";
	    }
	    else{
		printf(STDERR "error2: %s\n", $list[1]);
	    }
	    $n++;
	}
    }
}
close(FILE);
