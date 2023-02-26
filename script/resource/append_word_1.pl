#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [file] [word]\n";
    exit -1;
}
$filename0 = $ARGV[0];
$word = $ARGV[1];

open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    printf(STDOUT "%s\t%s\n", $word, $line);
}
close(FILE);
