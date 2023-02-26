#! /usr/bin/perl

$MX_LOWSQBASE = 300;
$MX_INS=$ARGV[2];

if($#ARGV < 3){
    printf STDERR "usage: $0  [sorted.bam]  [SORTED_grepTRANS_intraBP.list_0_filtR]  [maxInsertSize]  [path:samtools]\n";
    exit -1;
}
$mxis=$ARGV[2];
$SAMTOOLS_DIR=$ARGV[3];
@_id = split(/\//, $ARGV[0]);
@_dr = split(/_/, $_id[$#_id-1]);  $dirid = $_dr[$#_dr];
$bamid = $_id[$#_id];              $bamid =~ s/\.bam//;

# read break-point list
  open(FP1, $ARGV[1]) || die "Can not open file $ARGV[1]: $!\n";

# open sorted.bam for search support PE for softclip-breakpoint
$com="${SAMTOOLS_DIR}/samtools  view $ARGV[0] | awk \047\$2<2000 && \$7!=\042=\042{print}\047 > $_id[($#_id-1)]/$_id[$#_id].tmpsam"; system($com);
open(FP2, "$_id[($#_id-1)]/$_id[$#_id].tmpsam") || die "Can not open file $_id[($#_id-1)]/$_id[$#_id].tmpsam: $!\n";

@line=(); $cnt=$buf_st=$buf_en=0;
while($list = <FP1>){
    @column = split(/\s+/, $list);
    if($column[0]!~$chL){$buf_st=$buf_en=0; @line=();}

    $chL =$column[0];$chL=~s/chr//;  $bpL =$column[3];   $drL =$column[2];   @scope_L = ();	
    if($drL =~ ">"){push(@scope_L,$bpL-$mxis); push(@scope_L,$bpL);}
	       else{push(@scope_L,$bpL); push(@scope_L,$bpL+$mxis);}
    $chR =$column[8];$chR=~s/chr//;  $bpR =$column[5];   $drR =$column[6];   @scope_R = ();
    if($drR =~ "<"){push(@scope_R,$bpR-$mxis); push(@scope_R,$bpR);}
	       else{push(@scope_R,$bpR); push(@scope_R,$bpR+$mxis);}
    $sup =$column[9];


    $cnt=0;
    if($#line>=-1){for($i=0;$i<=$#line;$i++){
	@sam = split(/\t/, $line[$i]);
	if($i==0){$buf_st=$sam[3];}else{$buf_en=$sam[3];} 
	if($chL eq $sam[2]){
	    if(   $sam[3] < $scope_L[0]){next;}
	    elsif($sam[3] < $scope_L[1]){
		if(($sam[6] eq $chR) && ($scope_R[0]<$sam[7] && $sam[7]<$scope_R[1])){if($cnt==0){print $list;} print $line[$i]; $cnt++;}
	    }
	}
    } 
    }

    if($buf_st!=0 && $buf_en!=0){
      	if($scope_L[1]<$buf_en){                                 goto OUT;}
    }
    while($buff = <FP2>){
	@sam = split(/\t/, $buff);
	$sam[2] =~ s/chr//;  $sam[6] =~ s/chr//;
	if($sam[10]){
	    $n_rep = $sam[10] =~ s/##########//g;
	    if($n_rep*10 >=$MX_LOWSQBASE){next;}
	}
	if($chL eq $sam[2]){
	    if(   $sam[3] < $scope_L[0]){if($#line>=30){shift(@line);} push(@line,$buff);  next;}
	    elsif($sam[3] < $scope_L[1]){
		if(($sam[6] eq $chR) && ($scope_R[0]<$sam[7] && $sam[7]<$scope_R[1])){if($cnt==0){print $list;} print $buff; $cnt++;}
		if($#line>=30){shift(@line);} push(@line,$buff); 
	    }
	    else {if($#line>=30){shift(@line);} push(@line,$buff); goto OUT;}
	}
	else {@line=(); $sam[3]=1; goto OUT;}
    }
    close(FP2); 
    OUT:;
    $prescope_L1=$scope_L[1];
}
close(FP1);
