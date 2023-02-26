#! /usr/bin/perl
$MN_SUPREAD = 4;

if($#ARGV < 2){
    printf STDERR "usage: $0 [intraBP.list] [dir.tumor] [dir.normal] (maxInsertSize)\n";
    exit -1;
}
if($#ARGV==2 || $ARGV[3]<=0){ $mxis = 1500; }   else { $mxis = $ARGV[3];}

## REF/SV supportReads <<Tumor>> ===============================================================
open(RF_Ts, $ARGV[1]."/pChr_REFsupp/REFsupp_SE.bplist") || die "Can not open file $ARGV[1]/pChr_REFsupp/REFsupp_SE.bplist: $!\n";
$nRF_Ts = 0; while($line = <RF_Ts>){
    @extcolm = split(/\s+/, $line);
    $cnt_RF_Ts[$nRF_Ts] = $extcolm[1];	$chr_RF_Ts[$nRF_Ts] = "chr".$extcolm[2];	$crd_RF_Ts[$nRF_Ts] = $extcolm[3];
    if($extcolm[4] eq "-#"){$kye_RF_Ts[$nRF_Ts] = "==>"} else {$kye_RF_Ts[$nRF_Ts] = "<=="}
    $nRF_Ts++;
} close(RF_Ts);
open(RF_Tp, $ARGV[1]."/pChr_REFsupp/REFsupp_PE.bplist") || die "Can not open file $ARGV[1]/pChr_REFsupp/REFsupp_PE.bplist: $!\n";
$nRF_Tp = 0; while($line = <RF_Tp>){
    @extcolm = split(/\s+/, $line);
    $cnt_RF_Tp[$nRF_Tp] = $extcolm[1];	$chr_RF_Tp[$nRF_Tp] = "chr".$extcolm[2];	$crd_RF_Tp[$nRF_Tp] = $extcolm[3];
    if($extcolm[4] eq "-#"){$kye_RF_Tp[$nRF_Tp] = "==>"} else {$kye_RF_Tp[$nRF_Tp] = "<=="}
    $nRF_Tp++;
} close(RF_Tp);


open(SV_Ts, $ARGV[1]."/pChr_SVmatch/SVmatch_SE.bplist") || die "Can not open file $ARGV[1]/pChr_SVmatch/SVmatch_SE.bplist: $!\n";  
$nSV_Ts = 0; while($line = <SV_Ts>){
    @sv0_colm = split(/\s+/, $line);	
    $sv0_colm[2] =~ s/_/ /g; $sv0_colm[2] =~ s/-/ /;
    @sv_colm  = split(/\s+/, $sv0_colm[2]); 
    $cnt_SV_Ts[$nSV_Ts] = $sv0_colm[1];	$chr_SV_Ts[$nSV_Ts] = $sv_colm[1];
    $bpL_SV_Ts[$nSV_Ts] = $sv_colm[2];	$bpR_SV_Ts[$nSV_Ts] = $sv_colm[3];
    $nSV_Ts++
} close(SV_Ts);
open(SV_Tp, $ARGV[1]."/pChr_SVmatch/SVmatch_PE.bplist") || die "Can not open file $ARGV[1]/pChr_SVmatch/SVmatch_PE.bplist: $!\n";  
$nSV_Tp = 0; while($line = <SV_Tp>){
    @sv0_colm = split(/\s+/, $line);	
    $sv0_colm[2] =~ s/_/ /g; $sv0_colm[2] =~ s/-/ /;
    @sv_colm  = split(/\s+/, $sv0_colm[2]); 
    $cnt_SV_Tp[$nSV_Tp] = $sv0_colm[1];	$chr_SV_Tp[$nSV_Tp] = $sv_colm[1];
    $bpL_SV_Tp[$nSV_Tp] = $sv_colm[2];	$bpR_SV_Tp[$nSV_Tp] = $sv_colm[3];
    $nSV_Tp++
} close(SV_Tp);


open(SVtr_Ts, $ARGV[1]."/pChr_SVmatch_tr/SVmatch_tr_SE.bplist") || die "Can not open file $ARGV[1]/pChr_SVmatch_tr/SVmatch_tr_SE.bplist: $!\n"; 
$nSVtr_Ts = 0; while($line = <SVtr_Ts>){
    @sv0_colm = split(/\s+/, $line);    
    $sv0_colm[2] =~ s/_/ /g;  $sv0_colm[2] =~ s/-/ /;  @sv_colm  = split(/\s+/, $sv0_colm[2]);
    $cnt_SVtr_Ts[$nSVtr_Ts] = $sv0_colm[1];   
    $chL_SVtr_Ts[$nSVtr_Ts] = $sv_colm[1];    $chR_SVtr_Ts[$nSVtr_Ts] = $sv_colm[4];
    $bpL_SVtr_Ts[$nSVtr_Ts] = $sv_colm[2];    $bpR_SVtr_Ts[$nSVtr_Ts] = $sv_colm[3];
    $nSVtr_Ts++
} close(SVtr_Ts);

open(SVtr_Tp, $ARGV[1]."/pChr_SVmatch_tr/SVmatch_tr_PE.bplist") || die "Can not open file $ARGV[1]/pChr_SVmatch_tr/SVmatch_tr_PE.bplist: $!\n"; 
$nSVtr_Tp = 0; while($line = <SVtr_Tp>){
    @sv0_colm = split(/\s+/, $line);    
    $sv0_colm[2] =~ s/_/ /g;  $sv0_colm[2] =~ s/-/ /;  @sv_colm  = split(/\s+/, $sv0_colm[2]);
    $cnt_SVtr_Tp[$nSVtr_Tp] = $sv0_colm[1];   
    $chL_SVtr_Tp[$nSVtr_Tp] = $sv_colm[1];    $chR_SVtr_Tp[$nSVtr_Tp] = $sv_colm[4];
    $bpL_SVtr_Tp[$nSVtr_Tp] = $sv_colm[2];    $bpR_SVtr_Tp[$nSVtr_Tp] = $sv_colm[3];
    $nSVtr_Tp++
} close(SVtr_Tp);

## REF/SV supportReads <<Normal>> ===============================================================
open(RF_Ns, $ARGV[2]."/pChr_REFsupp/REFsupp_SE.bplist") || die "Can not open file $ARGV[2]/pChr_REFsupp/REFsupp_SE.bplist: $!\n";
$nRF_Ns = 0; while($line = <RF_Ns>){
    @extcolm = split(/\s+/, $line);
    $cnt_RF_Ns[$nRF_Ns] = $extcolm[1];	$chr_RF_Ns[$nRF_Ns] = "chr".$extcolm[2];	$crd_RF_Ns[$nRF_Ns] = $extcolm[3];
    if($extcolm[4] eq "-#"){$kye_RF_Ns[$nRF_Ns] = "==>"} else {$kye_RF_Ns[$nRF_Ns] = "<=="}
    $nRF_Ns++;
} close(RF_Ns);
open(RF_Np, $ARGV[2]."/pChr_REFsupp/REFsupp_PE.bplist") || die "Can not open file $ARGV[2]/pChr_REFsupp/REFsupp_PE.bplist: $!\n";
$nRF_Np = 0; while($line = <RF_Np>){
    @extcolm = split(/\s+/, $line);
    $cnt_RF_Np[$nRF_Np] = $extcolm[1];	$chr_RF_Np[$nRF_Np] = "chr".$extcolm[2];	$crd_RF_Np[$nRF_Np] = $extcolm[3];
    if($extcolm[4] eq "-#"){$kye_RF_Np[$nRF_Np] = "==>"} else {$kye_RF_Np[$nRF_Np] = "<=="}
    $nRF_Np++;
} close(RF_Np);

open(SV_Ns, $ARGV[2]."/pChr_SVmatch/SVmatch_SE.bplist") || die "Can not open file $ARGV[2]/pChr_SVmatch/SVmatch_SE.bplist: $!\n";  
$nSV_Ns = 0; while($line = <SV_Ns>){
    @sv0_colm = split(/\s+/, $line);	
    $sv0_colm[2] =~ s/_/ /g; $sv0_colm[2] =~ s/-/ /;
    @sv_colm  = split(/\s+/, $sv0_colm[2]); 
    $cnt_SV_Ns[$nSV_Ns] = $sv0_colm[1];	$chr_SV_Ns[$nSV_Ns] = $sv_colm[1];
    $bpL_SV_Ns[$nSV_Ns] = $sv_colm[2];	$bpR_SV_Ns[$nSV_Ns] = $sv_colm[3];
    $nSV_Ns++
} close(SV_Ns);
open(SV_Np, $ARGV[2]."/pChr_SVmatch/SVmatch_PE.bplist") || die "Can not open file $ARGV[2]/pChr_SVmatch/SVmatch_PE.bplist: $!\n";  
$nSV_Np = 0; while($line = <SV_Np>){
    @sv0_colm = split(/\s+/, $line);	
    $sv0_colm[2] =~ s/_/ /g; $sv0_colm[2] =~ s/-/ /;
    @sv_colm  = split(/\s+/, $sv0_colm[2]); 
    $cnt_SV_Np[$nSV_Np] = $sv0_colm[1];	$chr_SV_Np[$nSV_Np] = $sv_colm[1];
    $bpL_SV_Np[$nSV_Np] = $sv_colm[2];	$bpR_SV_Np[$nSV_Np] = $sv_colm[3];
    $nSV_Np++
} close(SV_Np);

open(SVtr_Ns, $ARGV[2]."/pChr_SVmatch_tr/SVmatch_tr_SE.bplist") || die "Can not open file $ARGV[2]/pChr_SVmatch_tr/SVmatch_tr_SE.bplist: $!\n"; 
$nSVtr_Ns = 0; while($line = <SVtr_Ns>){
    @sv0_colm = split(/\s+/, $line);    
    $sv0_colm[2] =~ s/_/ /g;  $sv0_colm[2] =~ s/-/ /;  @sv_colm  = split(/\s+/, $sv0_colm[2]);
    $cnt_SVtr_Ns[$nSVtr_Ns] = $sv0_colm[1];   
    $chL_SVtr_Ns[$nSVtr_Ns] = $sv_colm[1];    $chR_SVtr_Ns[$nSVtr_Ns] = $sv_colm[4];
    $bpL_SVtr_Ns[$nSVtr_Ns] = $sv_colm[2];    $bpR_SVtr_Ns[$nSVtr_Ns] = $sv_colm[3];
    $nSVtr_Ns++
} close(SVtr_Ns);
open(SVtr_Np, $ARGV[2]."/pChr_SVmatch_tr/SVmatch_tr_PE.bplist") || die "Can not open file $ARGV[2]/pChr_SVmatch_tr/SVmatch_tr_PE.bplist: $!\n"; 
$nSVtr_Np = 0; while($line = <SVtr_Np>){
    @sv0_colm = split(/\s+/, $line);    
    $sv0_colm[2] =~ s/_/ /g;  $sv0_colm[2] =~ s/-/ /;  @sv_colm  = split(/\s+/, $sv0_colm[2]);
    $cnt_SVtr_Np[$nSVtr_Np] = $sv0_colm[1];   
    $chL_SVtr_Np[$nSVtr_Np] = $sv_colm[1];    $chR_SVtr_Np[$nSVtr_Np] = $sv_colm[4];
    $bpL_SVtr_Np[$nSVtr_Np] = $sv_colm[2];    $bpR_SVtr_Np[$nSVtr_Np] = $sv_colm[3];
    $nSVtr_Np++
} close(SVtr_Np);

# print "=1====\$nRF_Ts  $nRF_Ts\n"; for($i=0;$i<=$nRF_Ts ;$i++){print "$i, $chr_RF_Ts[$i]\t$crd_RF_Ts[$i]\t$cnt_RF_Ts[$i]\n";}
# print "=2====\$nRF_Tp  $nRF_Tp\n"; for($i=0;$i<=$nRF_Tp ;$i++){print "$i, $chr_RF_Tp[$i]\t$crd_RF_Tp[$i]\t$cnt_RF_Tp[$i]\n";}
# print "=3====\$nSV_Ts  $nSV_Ts\n"; for($i=0;$i<=$nSV_Ts ;$i++){print "$i, $chr_SV_Ts[$i]\t$bpL_SV_Ts[$i],$bpR_SV_Ts[$i]\t$cnt_SV_Ts[$i]\n";}
# print "=4====\$nSV_Tp  $nSV_Tp\n"; for($i=0;$i<=$nSV_Tp ;$i++){print "$i, $chr_SV_Tp[$i]\t$bpL_SV_Tp[$i],$bpR_SV_Tp[$i]\t$cnt_SV_Tp[$i]\n";}
# print "=5====\$nSVtr_Ts  $nSVtr_Ts\n"; for($i=0;$i<=$nSVtr_Ts ;$i++){print "$i, $chL_SVtr_Ts[$i],$chR_SVtr_Ts[$i]\t$bpL_SVtr_Ts[$i],$bpR_SVtr_Ts[$i]\t$cnt_SVtr_Ts[$i]\n";}
# print "=6====\$nSVtr_Tp  $nSVtr_Tp\n"; for($i=0;$i<=$nSVtr_Tp ;$i++){print "$i, $chL_SVtr_Tp[$i],$chR_SVtr_Tp[$i]\t$bpL_SVtr_Tp[$i],$bpR_SVtr_Tp[$i]\t$cnt_SVtr_Tp[$i]\n";}

# print "_1____\$nRF_Ns  $nRF_Ns\n";  for($i=0;$i<=$nRF_Ns ;$i++){print "$i, $chr_RF_Ns[$i]\t$crd_RF_Ns[$i]\t$cnt_RF_Ns[$i]\n";}
# print "_2____\$nRF_Np  $nRF_Np\n";  for($i=0;$i<=$nRF_Np ;$i++){print "$i, $chr_RF_Np[$i]\t$crd_RF_Np[$i]\t$cnt_RF_Np[$i]\n";}
# print "_3____\$nSV_Ns  $nSV_Ns\n";  for($i=0;$i<=$nSV_Ns ;$i++){print "$i, $chr_SV_Ns[$i]\t$bpL_SV_Ns[$i],$bpR_SV_Ns[$i]\t$cnt_SV_Ns[$i]\n";}
# print "_4____\$nSV_Np  $nSV_Np\n";  for($i=0;$i<=$nSV_Np ;$i++){print "$i, $chr_SV_Np[$i]\t$bpL_SV_Np[$i],$bpR_SV_Np[$i]\t$cnt_SV_Np[$i]\n";}
# print "_5____\$nSVtr_Ns  $nSVtr_Ns\n";  for($i=0;$i<=$nSVtr_Ns ;$i++){print "$i, $chL_SVtr_Ns[$i],$chR_SVtr_Ns[$i]\t$bpL_SVtr_Ns[$i],$bpR_SVtr_Ns[$i]\t$cnt_SVtr_Ns[$i]\n";}
# print "_6____\$nSVtr_Np  $nSVtr_Np\n";  for($i=0;$i<=$nSVtr_Np ;$i++){print "$i, $chL_SVtr_Np[$i],$chR_SVtr_Np[$i]\t$bpL_SVtr_Np[$i],$bpR_SVtr_Np[$i]\t$cnt_SVtr_Np[$i]\n";}
# exit;

## intraBP.list ======================================================================
open(FILE, $ARGV[0]) || die "Can not open file $ARGV[0]: $!\n";
$n=0;
while($line = <FILE>){
    @column = split(/\t/, $line); chomp($line);
    $chL = $column[0];		$chR = $column[6];	$chL =~ s/\s+//;  $chR =~ s/\s+//;
    $bpL = $column[2];		$bpR = $column[4];	$bpL =~ s/\s+//;  $bpR =~ s/\s+//;	$sizeGR = sqrt(($bpR-$bpL)*($bpR-$bpL));
    $drL = $column[1];		$drR = $column[5];  
    
    if($column[8] =~ /translocation/ || $sizeGR >$mxis){ ######## in case large-scale SV or translocation, counts PE+SE as No.supportREF_read
	# count No.reads supported REF
	$count_RF_T = 0;
	$flg_RF_T=0; for($i=0;$i<$nRF_Ts;$i++){	# <Tumor>_REF_SE
	    if($chL==$chr_RF_Ts[$i] && $bpL==$crd_RF_Ts[$i] && $drL=~$kye_RF_Ts[$i]){$count_RF_T+=$cnt_RF_Ts[$i]; $flg_RF_T++;}
	    if($chR==$chr_RF_Ts[$i] && $bpR==$crd_RF_Ts[$i] && $drR!~$kye_RF_Ts[$i]){$count_RF_T+=$cnt_RF_Ts[$i]; $flg_RF_T++;}
	    if($flg_RF_T==2){last;}
	}
	$flg_RF_T=0; for($i=0;$i<$nRF_Tp;$i++){	# <Tumor>_REF_PE
	    if($chL==$chr_RF_Tp[$i] && $bpL==$crd_RF_Tp[$i] && $drL=~$kye_RF_Tp[$i]){$count_RF_T+=$cnt_RF_Tp[$i]; $flg_RF_T++; }
	    if($chR==$chr_RF_Tp[$i] && $bpR==$crd_RF_Tp[$i] && $drR!~$kye_RF_Tp[$i]){$count_RF_T+=$cnt_RF_Tp[$i]; $flg_RF_T++; }
	    if($flg_RF_T==2){last;}
	}

	$count_RF_N = 0;
	$flg_RF_N=0; for($i=0;$i<$nRF_Ns;$i++){	# <Normal>_REF_SE
	    if($chL==$chr_RF_Ns[$i] && $bpL==$crd_RF_Ns[$i] && $drL=~$kye_RF_Ns[$i]){ $count_RF_N+=$cnt_RF_Ns[$i]; $flg_RF_N++; }
	    if($chR==$chr_RF_Ns[$i] && $bpR==$crd_RF_Ns[$i] && $drR!~$kye_RF_Ns[$i]){ $count_RF_N+=$cnt_RF_Ns[$i]; $flg_RF_N++; }
	    if($flg_RF_N==2){last;}
	}
	$flg_RF_N=0; for($i=0;$i<$nRF_Np;$i++){	# <Normal>_REF_PE
	    if($chL==$chr_RF_Np[$i] && $bpL==$crd_RF_Np[$i] && $drL=~$kye_RF_Np[$i]){ $count_RF_N+=$cnt_RF_Np[$i]; $flg_RF_N++; }
	    if($chR==$chr_RF_Np[$i] && $bpR==$crd_RF_Np[$i] && $drR!~$kye_RF_Np[$i]){ $count_RF_N+=$cnt_RF_Np[$i]; $flg_RF_N++; }
	    if($flg_RF_N==2){last;}
	}

	# count No.reads supported SV
	$count_SV_T = $count_SV_Tp = $count_SV_Ts = 0; 
	$count_SV_N = $count_SV_Np = $count_SV_Ns = 0;

	if($column[8] =~ /translocation/){
	    for($i=0;$i<$nSVtr_Ts;$i++){ if($chL==$chL_SVtr_Ts[$i] && $bpL==$bpL_SVtr_Ts[$i] && $bpR==$bpR_SVtr_Ts[$i] && $chR==$chR_SVtr_Ts[$i]){ $count_SV_Ts  = $cnt_SVtr_Ts[$i]; last;}}
	    for($i=0;$i<$nSVtr_Tp;$i++){ if($chL==$chL_SVtr_Tp[$i] && $bpL==$bpL_SVtr_Tp[$i] && $bpR==$bpR_SVtr_Tp[$i] && $chR==$chR_SVtr_Tp[$i]){ $count_SV_Tp  = $cnt_SVtr_Tp[$i]; last;}}
	    if(($count_SV_Ts+$count_SV_Tp> $MN_SUPREAD  &&  $count_SV_Tp>=1) || $column[7]>=$MN_SUPREAD){
	 	$count_SV_T = $count_SV_Ts+$count_SV_Tp; }else{$count_SV_T = "-";}

	    $count_SV_Np = $count_SV_Ns =0;
	    for($i=0;$i<$nSVtr_Ns;$i++){ if($chL==$chL_SVtr_Ns[$i] && $bpL==$bpL_SVtr_Ns[$i] && $bpR==$bpR_SVtr_Ns[$i] && $chR==$chR_SVtr_Ns[$i]){ $count_SV_Ns  = $cnt_SVtr_Ns[$i]; last;}}
	    for($i=0;$i<$nSVtr_Np;$i++){ if($chL==$chL_SVtr_Np[$i] && $bpL==$bpL_SVtr_Np[$i] && $bpR==$bpR_SVtr_Np[$i] && $chR==$chR_SVtr_Np[$i]){ $count_SV_Np  = $cnt_SVtr_Np[$i]; last;}}
	        $count_SV_N = $count_SV_Ns+$count_SV_Np;
	}
	else{
	    for($i=0;$i<$nSV_Ts;$i++){ if($chL==$chr_SV_Ts[$i] && $bpL==$bpL_SV_Ts[$i] && $bpR==$bpR_SV_Ts[$i] && $chR==$chR_SV_Ts[$i]){ $count_SV_T  = $cnt_SV_Ts[$i]; last;}}
	    for($i=0;$i<$nSV_Tp;$i++){ if($chL==$chr_SV_Tp[$i] && $bpL==$bpL_SV_Tp[$i] && $bpR==$bpR_SV_Tp[$i] && $chR==$chR_SV_Tp[$i]){ $count_SV_T += $cnt_SV_Tp[$i]; $count_SV_Tp = $cnt_SV_Tp[$i]; last;}}
	    for($i=0;$i<$nSV_Ns;$i++){ if($chL==$chr_SV_Ns[$i] && $bpL==$bpL_SV_Ns[$i] && $bpR==$bpR_SV_Ns[$i] && $chR==$chR_SV_Ns[$i]){ $count_SV_N  = $cnt_SV_Ns[$i]; last;}}
	    for($i=0;$i<$nSV_Np;$i++){ if($chL==$chr_SV_Np[$i] && $bpL==$bpL_SV_Np[$i] && $bpR==$bpR_SV_Np[$i] && $chR==$chR_SV_Np[$i]){ $count_SV_N += $cnt_SV_Np[$i]; $count_SV_Np = $cnt_SV_Np[$i]; last;}}
	}
    }
    else{ #################################################### in case {SVsize < max insert size}, only conut SE for estimating No.supportREF_read
	$count_RF_T = 0; @array=(); $count_RF_N =0;
	open(EXTL, "$ARGV[1]/pChr_REFsupp/${chL}.extlist");
	@array=();
	while($eline = <EXTL>){
	    @ecolm = split(/\t/, $eline);
	    if(($ecolm[1]==($bpL-$mxis)||$ecolm[1]==($bpR-$mxis)) && $ecolm[6]=~/SE/){ push(@array, $ecolm[4]); }
	} close(EXTL);
	%hash =(); foreach(@array){ $hash{$_}++; }  
	@uniq = keys %hash;  if($#uniq==-1){$count_RF_T=0;} else{$count_RF_T = $#uniq;}

	$count_RF_N = 0; @array=();
	open(EXTL, "$ARGV[2]/pChr_REFsupp/${chL}.extlist");
	while($eline = <EXTL>){
	    @ecolm = split(/\t/, $eline);
	    if(($ecolm[1]==($bpL-$mxis)||$ecolm[1]==($bpR-$mxis)) && $ecolm[6]=~/SE/){ push(@array, $ecolm[4]); }
	} close(EXTL);
	%hash =(); foreach(@array){ $hash{$_}++; }  
	@uniq = keys %hash;  if($#uniq==-1){$count_RF_N=0;} else{$count_RF_N = $#uniq;}

	$count_SV_T = $count_SV_N =0;
	for($i=0;$i<$nSV_Ts;$i++){ if($chL==$chr_SV_Ts[$i] && $bpL==$bpL_SV_Ts[$i] && $bpR==$bpR_SV_Ts[$i] && $chR==$chR_SV_Ts[$i]){ $count_SV_T = $cnt_SV_Ts[$i]; last;}}
	for($i=0;$i<$nSV_Ns;$i++){ if($chL==$chL_SV_Ns[$i] && $bpL==$bpL_SV_Ns[$i] && $bpR==$bpR_SV_Ns[$i] && $chR==$chR_SV_Ns[$i]){ $count_SV_N = $cnt_SV_Ns[$i]; last;}}
	$count_SV_Tp = $count_SV_Np = "-";
    }

    if($column[7]>=$MN_SUPREAD || $count_SV_T>=$MN_SUPREAD){print "$line\t$count_RF_T\t$count_SV_T\t$count_SV_Tp\t$count_RF_N\t$count_SV_N\t$count_SV_Np\n";}
}
close(FILE);
