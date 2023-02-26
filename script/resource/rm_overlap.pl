#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [file] [file]\n";
    exit -1;
}
$filename0 = $ARGV[0];
$filename1 = $ARGV[1];

open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    $hash{$line} = 1;
}
close(FILE);

open(FILE, $filename1) || die "Can not open file $filename1: $!\n";
while($line = <FILE>){
    chomp $line;
    if($hash{$line} != 1){
	printf(STDOUT "%s\n", $line);
    }
}
close(FILE);
