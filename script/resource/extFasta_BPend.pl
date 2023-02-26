#! /usr/bin/perl

if($#ARGV < 1){
    printf STDERR "usage: $0 [\$IHOME/hg19/Sequence/Chromosomes/chr#.fa] [list(:prep_extFasta_mklist.awk.out)]\n";
    exit -1;
}

open(FP1, $ARGV[1]) || die "Can not open file $ARGV[1]: $!\n";
$n=0;
while($line = <FP1>){
    chop($line);
    @column = split(/\t/, $line);
    $st[$n]   = $column[0];
    $en[$n]   = $column[1];
    $code[$n] = $column[2];
    $n++;
}
close(FP1);

open(FP2, $ARGV[0]) || die "Can not open file $ARGV[0]: $!\n";
@fname = split(/_/,  $ARGV[0]);
$contig = $fname[$#fname];

$N=$cnt=$flg=0;
while($line = <FP2>){chomp $line; if($line !~ /^>/){$lN=length($line); last;}} seek(FP2,0,0); 	# lN= No.base/1-line
@buff=();  $MX_buffline=100;  $st_buff=$en_buff=0;

while($N<=$n){

    if($lN <$cnt && $st[$N]<=$cnt+$lN){ 
	for($i=0;$i<=$#buff;$i++){
	    $bnt = $st_buff+$lN*$i;	# $bnt : "$cnt" for @"b"uff
	    if($bnt<=$st[$N] && $st[$N]<$bnt+$lN && $flg==0){
		open(FP_W, "> ./${contig}/${contig}_$st[$N]-$en[$N]_$code[$N]") || die "Can not open file ./${contig}/${contig}_$st[$N]-$en[$N]_$code[$N]: $!\n";
		printf FP_W  ">".$contig."_".$st[$N]."-".$en[$N]."\t".$code[$N]."\n";

		@char = split(//, $buff[$i]);
	    	if($en[$N]<=$bnt+$lN){ 
	    	    if($en[$N] % $lN==0){for($j=$st[$N] % $lN-1; $j<=$#char;$j++){printf(FP_W "%s",$char[$j]);} printf(FP_W "\n");}
	    	    else{for($j=$st[$N] % $lN-1; $j<=$en[$N] % $lN;$j++){printf(FP_W "%s",$char[$j]);}  printf(FP_W "\n");}
	    	}
	    	if($st[$N] % $lN==0){printf(FP_W "%s\n" ,$char[$#char]);}
	   	else {for($j=$st[$N] % $lN-1; $j<=$#char;$j++){printf(FP_W "%s",$char[$j]);}  printf(FP_W "\n");}
	    	$flg=1;
	    }
    	    elsif($bnt<$en[$N] && $en[$N]<$bnt+$lN){
		@char = split(//, $buff[$i]);
		if($en[$N] % $lN==0){printf(FP_W "%s\n" ,$buff[$i]);}
		else {for($j=0;$j<$en[$N] % $lN;$j++){printf(FP_W "%s",$char[$j]);}}
		printf(FP_W "\n");
		close(FP_W);
		$N++; $bnt += length($buff[$i]);  $flg=0;  goto OUT;
            }
    	    elsif($flg==1){printf(FP_W "%s\n" ,$buff[$i]);}
    	    $bnt += length($buff[$i]);
	}
    }


    while($line = <FP2>){if($line !~ /^\>/){
	chop($line);

	if($#buff>=$MX_buffline){ shift @buff; } else{$st_buff =1;}
	push(@buff,$line);  
	$en_buff += length($line);
	$st_buff =  $en_buff-(length($line)*($#buff+1))+1;

    	if($cnt<=$st[$N] && $st[$N]<=$cnt+$lN && $flg==0){
	    open(FP_W, "> ./${contig}/${contig}_$st[$N]-$en[$N]_$code[$N]") || die "Can not open file ./${contig}/${contig}_$st[$N]-$en[$N]_$code[$N]: $!\n";
	    printf FP_W ">".$contig."_".$st[$N]."-".$en[$N]."\t".$code[$N]."\n";  

            @char = split(//, $line);
	    if($en[$N]<=$cnt+$lN){ 
	    	if($en[$N] % $lN==0){for($i=$st[$N] % $lN-1; $i<=$#char;$i++){printf(FP_W "%s",$char[$i]);} printf(FP_W "\n"); goto OUT;}
	    	else{for($i=$st[$N] % $lN-1; $i<=$en[$N] % $lN;$i++){printf(FP_W "%s",$char[$i]);}  printf(FP_W "\n"); goto OUT;}
	    }
	    if($st[$N] % $lN==0){printf(FP_W "%s\n" ,$char[$#char]);}
	    else {for($i=$st[$N] % $lN-1; $i<=$#char;$i++){printf(FP_W "%s",$char[$i]);}  printf(FP_W "\n");}
	    $flg=1;
    	}
    	elsif($cnt<$en[$N] && $en[$N]<=$cnt+$lN){
            @char = split(//, $line);
	    if($en[$N] % $lN==0){printf(FP_W "%s\n" ,$line);}
	    else {for($i=0;$i<$en[$N] % $lN;$i++){printf(FP_W "%s",$char[$i]);}}
	    printf(FP_W "\n");
	    close(FP_W);
	    $N++; $cnt += length($line); $flg=0; goto OUT;
        }
    	elsif($flg==1){printf(FP_W "%s\n" ,$line);}

    	$cnt += length($line);
    }}
    close(FP2); 
    exit;

    OUT:;
}

