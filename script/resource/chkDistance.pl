#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [file] [length]\n";
    exit -1;
}
$filename0 = $ARGV[0];
$len = $ARGV[1];

open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    @list = split(/\t/, $line);
    if($len <= $list[11]){
	printf(STDOUT "%s\n", $line);
    }
}
close(FILE);
