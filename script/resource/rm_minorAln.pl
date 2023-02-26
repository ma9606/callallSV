#! /usr/bin/perl

$MX_TLR = 10;	# MaX ToLeRance of BP-coordinate(bp)
if($#ARGV < 0){
    printf STDERR "usage: $0 [sort-No.read intraBP.list_0]\n";
    exit -1;
}

open(FILE, $ARGV[0]) || die "Can not open file $ARGV[0]: $!\n";
@bpL = @bpR = @chR = @rN =(); $n=0;
while($line = <FILE>){
    @column = split(/\t/, $line); 
    $flg=0; for($i=0;$i<$n;$i++){ 
	if(	($bpL[$i]-$MX_TLR)<=$column[2] && $column[2]<=($bpL[$i]+$MX_TLR)  && 
		($bpR[$i]-$MX_TLR)<=$column[4] && $column[4]<=($bpR[$i]+$MX_TLR)  &&
		($bpL[$i]!=$column[2] && $bpR[$i]!=$column[4]) &&
		$column[6] eq $chR[$i]	){ $flg++; last; }
    }
    if($flg==0){
	print $line;
    	push(@bpL, $column[2]);	push(@bpR, $column[4]);
    	push(@chR, $column[6]);	push(@rN,  $column[7]);
	$n++;
    }
}
close(FILE);
