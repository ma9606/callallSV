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
	printf(STDOUT "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s", 
	       $list[0], $list[1], $list[2], $list[3], $list[4], $list[5], $list[6], $list[7], $list[8], $list[9], $list[10], $list[11], $list[12], $list[13]);
	undef %hash;
	for($i = 14; $i <= $#list; $i++){
	    @list2 = split(/\,/, $list[$i]);
	    if($hash{$list2[0]} != 1){
		$hash{$list2[0]} = 1;
		printf(STDOUT "\t%s", $list[$i]);
	    }
	}
	printf(STDOUT "\n");
    }
    else{
	printf(STDOUT "%s\n", $line);
    }
}
close(FILE);
