#! /usr/bin/perl

if($#ARGV < 0){
    printf STDERR "usage: $0 [sorted.sam]\n";
    exit -1;
}

@buff_PE=();  $MAX_bufPE=100;  @flg=();
$rLen=0;

open(FILE, $ARGV[0]) || die "Can not open file $ARGV[0]: $!\n";
while($line = <FILE>){

    if($#buff_PE>=$MAX_bufPE){
	for($i=0;$i<=$#buff_PE;$i++){
	    $flg[$i]=0;
	    @sam=split(/\t/, $buff_PE[$i]);
	    for($j=$i+1;$j<=$#buff_PE;$j++){
		if($buff_PE[$j] =~ $sam[0]){ print $buff_PE[$i],$buff_PE[$j]; $flg[$i]=$flg[$j]=1; last; }
	    }
	}
	@buff_tmp=();
	for($i=0;$i<=$#buff_PE;$i++){if($flg[$i]==0){ push(@buff_tmp, $buff_PE[$i]);}}
	@buff_PE=(); 
	if($#buff_tmp-($MAX_bufPE/2)<=0){ for($i=0;$i<=$#buff_tmp;$i++){ push(@buff_PE, $buff_tmp[$i]); } }
	else 		    { for($i=$#buff_tmp-50;$i<=$#buff_tmp;$i++){ push(@buff_PE, $buff_tmp[$i]); } }
    }

    @sam=split(/\t/, $line);

    if($rLen==0){
	$rLen = length($sam[9]);
#   	$MX_MISMA  = $rLen*0.10;
#   	$MN_ASSCR  = $rLen*0.80;
   	$MN_ASSCR  = $rLen*0.90;
   	$MN_ASUNQ  = $rLen*0.01;
    }

    next if $sam[1]!=83 && $sam[1]!=163 && $sam[1]!=99 && $sam[1]!=147;
    next if $sam[5] ne length($sam[9])."M";
    @nm=split(/:/,$sam[11]);
    next if $nm[2] > $MX_MISMA;
    @as=split(/:/,$sam[13]); @xs=split(/:/,$sam[14]);
    next if $as[2]-$xs[2] < $MN_ASUNQ;
    next if $as[2] < $MN_ASSCR;
 
    push(@buff_PE, $line);
}

for($i=0;$i<=$#buff_PE;$i++){
    $flg[$i]=0;
    @sam=split(/\t/, $buff_PE[$i]);
    for($j=$i+1;$j<=$#buff_PE;$j++){
	if($buff_PE[$j] =~ $sam[0]){ print $buff_PE[$i],$buff_PE[$j]; $flg[$i]=$flg[$j]=1; last; }
    }
}

close(FILE);
