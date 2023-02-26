#!/usr/bin/perl

$MAX_SLIPPAGE = 5;
$MAX_occupancy_N = 0.01;
$MAX_NCNT = 1;

if($#ARGV < 1){
    printf STDERR "usage: $0 [BPlist_N] [BPlist_T]\n";
    exit -1;
}

# open SORTED normal_BPlist
open(FILE, $ARGV[0]) || die "Can not open file $ARGV[0]: $!\n";
$n = 0; @nBP_3 = @nBP_5 = @nBP_NumRead = ();
while($line = <FILE>){
    @column = split(/\s+/, $line); 
    $nBP_3[$n] = $column[3];
    $nBP_5[$n] = $column[5];
    $nBP_NumRead[$n] = $column[9];
    $n++;
}
close(FILE);

# open SORTED tumor_BPlist
open(FILE, $ARGV[1]) || die "Can not open file $ARGV[1]: $!\n";
$N=0;
while($line = <FILE>){
    @column = split(/\s+/, $line);
    $flg=0; for($i=0;$i<$n;$i++){
        if( ($nBP_3[$i]-$MAX_SLIPPAGE)<=$column[3] && $column[3]<=($nBP_3[$i]+$MAX_SLIPPAGE) && 
    	    ($nBP_5[$i]-$MAX_SLIPPAGE)<=$column[5] && $column[5]<=($nBP_5[$i]+$MAX_SLIPPAGE)){ 
    	$rate = $nBP_NumRead[$i] / $column[9];
    	if($rate > $MAX_occupancy_N || $nBP_NumRead[$i] >$MAX_NCNT){$flg++; $N=$n; last;}
        }
    }
    if($flg == 0){print $line;}
}
close(FILE);
