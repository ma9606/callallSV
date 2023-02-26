#! /usr/bin/perl

if($#ARGV != 2){
    printf STDERR "usage: $0 [file] [num] [length]\n";
    exit -1;
}
$filename0 = $ARGV[0];
$num = $ARGV[1];
$len = $ARGV[2];

open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    @list = split(/\t/, $line);
    if($len <= $list[$num]){
	printf(STDOUT "%s\n", $line);
    }
}
close(FILE);
