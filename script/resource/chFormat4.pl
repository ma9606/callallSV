#! /usr/bin/perl

if($#ARGV != 0){
    printf STDERR "usage: $0 [file]\n";
    exit -1;
}
$filename1 = $ARGV[0];

open(FILE, $filename1) || die "Can not open file $filename1: $!\n";
while($line = <FILE>){
    $line = <FILE>;
    $line = <FILE>;
    $line = <FILE>;
    chomp $line;
    $line =~ s/^[ \t]+//;
    $line =~ s/[ \t]+$//;
#    @list = split(/[ \t]+/, $line);
    @list = split(/\t/, $line);
    printf(STDOUT "%s %s %s\n", $list[0], $list[2], $list[2]);
    $line = <FILE>;
    chomp $line;
    $line =~ s/^[ \t]+//;
    $line =~ s/[ \t]+$//;
#    @list = split(/[ \t]+/, $line);
    @list = split(/\t/, $line);
    printf(STDOUT "%s %s %s\n", $list[0], $list[2], $list[2]);
    $line = <FILE>;
    printf(STDOUT "\n");
}
close(FILE);
