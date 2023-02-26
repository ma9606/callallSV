#! /usr/bin/perl

$MX_INS=$ARGV[2];

if($#ARGV < 2){
    printf STDERR "usage: $0  [./sqcrID/sorted_chr#.sam]  [../SVseq/.list_chr#]  [maxInsertSize]\n";
    exit -1;
}

open(FP1, $ARGV[1]) || die "Can not open file $ARGV[1]: $!\n";	# read break-point(:defined $ch[]_$st[]-$en[], code[_#/#_]) list
$n=0;
while($line = <FP1>){
    chop($line);
    @column = split(/\t/, $line);
    if(   $column[3] eq "-#"){ $bp[$n]=$column[2]; }
    elsif($column[3] eq "#-"){ $bp[$n]=$column[1]; }
    $ch[$n]=$column[0];  $ch[$n] =~ s/chr//;
    $st[$n]=$bp[$n]-$MX_INS;	$en[$n]=$bp[$n]+$MX_INS;
    $code[$n]=$column[3];
    $n++;
}
close(FP1);

open(FP2, $ARGV[0]) || die "Can not open file $ARGV[0]: $!\n";	# read REFmapped_perChr.sam
@buff=();  $MAX_buff=5000;  $rLen=0;

while($N<=$n){
# print "$N, $n $bp[$N]\t$ch[$N]: $st[$N]-$en[$N] $code[$N]  | $cur_ch | \$st[\$N],\$sam[3]: $st[$N], $sam[3]  =====================================================\n";
    $flg=0;
    if($cur_ch ne $ch[$N]){
	@buff=(); $sam[3] = 999999999;
    }

    if($st[$N]<$sam[3]){
      for($i=0;$i<=$#buff;$i++){
	@bem = split(/\t/, $buff[$i]);  # @bem : Buffer_Expanded saM
	if($tmpid ne $bem[0]){
    	    if($ch[$N] eq $bem[2] && $st[$N]<=$bem[3] && $bem[7]+$rLen<=$en[$N]){
# $s3=$bem[3]+$rLen; $s7=$bem[7]+$rLen;
# print "hairu_bem$i?  ($bem[3], $bp[$N], $s3]\t[($bem[7], $bp[$N], $s7]  \n";
		#2a_ BP mapped as softclipped mode
		if(($bem[3]<$bp[$N] && $bp[$N]<$bem[3]+$rLen) || ($bem[7]<$bp[$N] && $bp[$N]<$bem[7]+$rLen)){
		    printf "%s\t%9d\t%9d\t%s\t%s\t%d-%d_%d-%d\tbSE\n",$ch[$N],$st[$N],$en[$N],$code[$N],$bem[0],$st[$N],$en[$N],$bem[3],$bem[3]+$bem[8]-length($bem[9]);
		}
		#2b_ BP mapped at inserted region between PE
		elsif($bem[3]<$bp[$N]-$rLen && $bp[$N]<$bem[7]){
		    printf "%s\t%9d\t%9d\t%s\t%s\t%d-%d_%d-%d\tbPE\n",$ch[$N],$st[$N],$en[$N],$code[$N],$bem[0],$st[$N],$en[$N],$bem[3],$bem[3]+$bem[8]-length($bem[9]);
		}
	    }
	    if($en[$N]<$bem[3]){ $N++; goto OUT;}
	}
	$tmpid=$bem[0];
      }
    }

    
    while($line = <FP2>){
	chop($line);
	@sam = split(/\t/, $line);
	if($rLen==0){$rLen=length($sam[9]);}

	if($tmpid ne $sam[0] && $ch[$N] eq $sam[2]){ 
    	    if($ch[$N] eq $sam[2] && $st[$N]<=$sam[3] && $sam[7]+$rLen<=$en[$N]){
# $s3=$sam[3]+$rLen; $s7=$sam[7]+$rLen;
# print "hairu?  ($sam[3], $bp[$N], $s3]\t[($sam[7], $bp[$N], $s7]\n";
		#1a_ BP mapped as softclipped mode
		if(($sam[3]<$bp[$N] && $bp[$N]<$sam[3]+$rLen) || ($sam[7]<$bp[$N] && $bp[$N]<$sam[7]+$rLen)){
		    printf "%s\t%9d\t%9d\t%s\t%s\t%d-%d_%d-%d\tSE\n",$ch[$N],$st[$N],$en[$N],$code[$N],$sam[0],$st[$N],$en[$N],$sam[3],$sam[3]+$sam[8]-length($sam[9]);
		}
		#1b_ BP mapped at inserted region between PE
		elsif($sam[3]<$bp[$N]-$rLen && $bp[$N]<$sam[7]){
		    printf "%s\t%9d\t%9d\t%s\t%s\t%d-%d_%d-%d\tPE\n",$ch[$N],$st[$N],$en[$N],$code[$N],$sam[0],$st[$N],$en[$N],$sam[3],$sam[3]+$sam[8]-length($sam[9]);
		}
		$flg=1;
	    }
	    if($#buff >= $MAX_buff){ shift @buff; }  push(@buff,$line);
	    if($en[$N]<$sam[3]){ $cur_ch= $ch[$N]; $N++; $tmpid = $sam[0]; goto OUT;}
	    $tmpid = $sam[0];
	}
    }
    close(FP2); exit;

    OUT:;
# print "\$cur_ch= \$ch[$N]:  $cur_ch, $ch[$N]\n";
}
