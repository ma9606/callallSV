#! /usr/bin/perl

if($#ARGV != 2){
    printf STDERR "usage: $0 [file] [sample] [type]\n";
    exit -1;
}
$filename0 = $ARGV[0];
$sam = $ARGV[1];
$typ = $ARGV[2];

open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    printf(STDOUT "%s\t%s\t%s\n", $sam, $typ, $line);
}
close(FILE);
