#! /usr/bin/perl
# modified by M_Adachi for rf(tandem)reads, based on extractHighInsert_bwa.pl

if($#ARGV != 2){
    printf STDERR "usage: $0 [file] [rm-insert_mini(45)] [rm-insert_max(49)]\n";
    exit -1;
}
$filename = $ARGV[0];
$min = $ARGV[1];
$max = $ARGV[2];

open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
    @list = split(/\t/, $line);
    $ins = $list[8];
    if($ins < 0){
	$ins *= -1;
    }
    $line2 = <FILE>;
    @list2 = split(/\t/, $line2);
    $ins2 = $list2[8];
    if($ins2 < 0){
	$ins2 *= -1;
    }
    if($ins ne $ins2){
	printf(STDERR "%s", $line);
	printf(STDERR "%s", $line2);
    }
    else{
	if($ins< $min || $max < $ins){
	    printf(STDOUT "%s", $line);
	    printf(STDOUT "%s", $line2);
	}
    }
}
close(FILE);
