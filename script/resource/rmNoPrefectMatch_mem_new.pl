#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [Cluter file] [num]\n";
    exit -1;
}
$filename0 = $ARGV[0];
$num = $ARGV[1];

$n = 0;
$ok2 = 0;
$res = "";
open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    $res .= $line;
    if($line =~ /^Cluster/){
	$n++;
    }
    elsif($line =~ /^\#/){
	if($ok2 == 1){
	    printf(STDOUT "%s", $res);
	}
	$n = 0;
	$ok2 = 0;
	$res = "";
    }
    else{
	@list = split(/\t/, $line);
	$name = $list[0];
#	@list11 = split(/:/, $list[11]);
#	if($list11[2] == 0){
#	    $ok = 1;
#	}
#	else{
#	    $ok = 0;
#	}
	$ok = 1;
	@list = split(/\t/, $line);
	for($i = 11; $i <= $#list; $i++){
	    if($list[$i] =~ /^NM/){
		@list2 = split(/:/, $list[$i]);
		if($num < $list2[2]){
		    $ok = 0;
		}
	    }
	}
	if($n == 1){
	    if($ok == 1){
		$hash{$name} = 1;
	    }
	}
	elsif($n == 2){
	    if($ok == 1){
		if($hash{$name} == 1){
		    $ok2 = 1;
		}
	    }
	}
    }
}
close(FILE);
