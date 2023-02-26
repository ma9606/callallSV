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
	printf(STDOUT "%s\n", $line);
    }
}
close(FILE);
