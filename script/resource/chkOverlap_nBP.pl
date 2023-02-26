#!/usr/bin/perl

$MAX_SLIPPAGE = 5;
$MAX_occupancy_N = 0.25;
$MAX_NCNT = 3;

if($#ARGV < 0){
    printf STDERR "usage: $0 [BPlist_N <tab> BPlist_T]\n";
    exit -1;
}

open(LIST, $ARGV[0]) || die "Can not open file $ARGV[0]: $!\n";
while($list_0 = <LIST>){
    @list = split(/\s+/, $list_0);   # $list[0]:normal, $list[1]:tumor

    # open normal_BPlist
    open(FILE, $list[0]) || die "Can not open file $list[0]: $!\n";
    $n = 0; @nBP_3 = @nBP_5 = @nBP_NumRead = ();
    while($line = <FILE>){
	@column = split(/\s+/, $line); 
	$nBP_3[$n] = $column[3];
	$nBP_5[$n] = $column[5];
	$nBP_NumRead[$n] = $column[9];
	$n++;
    }
    close(FILE);

    # open tumor_BPlist
    open(FILE, $list[1]) || die "Can not open file $list[1]: $!\n";
    while($line = <FILE>){
	@column = split(/\s+/, $line);
	$flg=0; for($i=0;$i<$n;$i++){
	    if( ($nBP_3[$i]-$MAX_SLIPPAGE)<=$column[3] && $column[3]<=($nBP_3[$i]+$MAX_SLIPPAGE) && 
		($nBP_5[$i]-$MAX_SLIPPAGE)<=$column[5] && $column[5]<=($nBP_5[$i]+$MAX_SLIPPAGE)){ 
		$rate = $nBP_NumRead[$i] / $column[9];
		if($rate > $MAX_occupancy_N || $nBP_NumRead[$i]>=$MAX_NCNT){$flg++;}
	    }
	}
	if($flg == 0){print $line;}
    }
    close(FILE);
}
close(LIST);

