#! /usr/bin/perl

if($#ARGV < 0){
    printf STDERR "usage: $0 [all.sam.cla.tr.rmMulti2.sco37.mis2]\n";
    exit -1;
}
$filename = $ARGV[0];
open(FILE_p1, "> $filename.p1") || die "Can not open file $filename.p1: $!\n";
open(FILE_p2, "> $filename.p2") || die "Can not open file $filename.p2: $!\n";
open(FILE_p3, "> $filename.p3") || die "Can not open file $filename.p3: $!\n";
open(FILE_p4, "> $filename.p4") || die "Can not open file $filename.p4: $!\n";

open(FILE, $ARGV[0]) || die "Can not open file $ARGV[0]: $!\n";
while($line = <FILE>){
    @column = split(/\t/, $line);
    if($column[2] !~ "chr"){$tmp = "chr".$column[2]; $column[2] =$tmp;}
    if($column[6] !~ "chr"){$tmp = "chr".$column[6]; $column[6] =$tmp;}

    if(   $column[2] eq "chr1" || $column[6] eq "chr1"  ||  $column[2] eq "chr4" || $column[6] eq "chr4"){ printf(FILE_p1 "%s", $line);}
    elsif($column[2] eq "chr2" || $column[6] eq "chr2"  ||  $column[2] eq "chr5" || $column[6] eq "chr5"){ printf(FILE_p2 "%s", $line);}
    elsif($column[2] eq "chr3" || $column[6] eq "chr3"  ||  $column[2] eq "chr6" || $column[6] eq "chr6"  ||  $column[2] eq "chr7" || $column[6] eq "chr7"){ printf(FILE_p3 "%s", $line);}
    else{printf(FILE_p4 "%s", $line);}
}
close(FILE);
close(FILE_p1); close(FILE_p2); close(FILE_p3); close(FILE_p4);
