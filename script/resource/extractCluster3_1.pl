#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [file] [# reads]\n";
    exit -1;
}
$filename0 = $ARGV[0];
$reads = $ARGV[1];

open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    $line =~ s/^[ \t]+//;
    $line =~ s/[ \t]+$//;
    @list = split(/[ \t]+/, $line);
    if($list[0] eq "Cluster"){
	$n = $list[2];
	if($reads <= $n){
	    printf(STDOUT "%s\n", $line);
	    for($i = 0; $i < $n * 2 + 2; $i++){
		$line = <FILE>;
		printf(STDOUT "%s", $line);
	    }
	}
    }
}
close(FILE);
