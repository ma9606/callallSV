#! /usr/bin/perl

$MAPQ_MIN = 0;
$NMRATE_MAX      = 0.10;
$MIN_COMPL_RATE  = 0.50;
$MIN_AS_DIFF	 = 0.001;
$EDGE_UNMATCH	 =  5;
$ALN_INSERT	 = 10;

my @FLAG_FS = ("65","67","73","97","99","129","131","137","161","163");
my @FLAG_RS = ("81","83","113","115","121","145","147","177","179","181");
my @FLAG_SE = ("69","73","89","101","117","121","137","133","165","153","185","181");

if($#ARGV < 0){ 
    printf STDERR "usage: $0 [file.sam]  (outfile[*.SA.sam] namebody) \n";
    exit -1; 
}
$filename = $ARGV[0];


if($ARGV[0] eq "\-" && $#ARGV==1){ $filename_body=$ARGV[1]; }
else {$filename_body = $filename; $filename_body =~ s/.sam//;}

open(FILE_SA, "> $filename_body.SA.sam") || die "Can not open file $filename.SA.sam: $!\n";
# open(FILE_SAA, "> $filename_body.SA.sam_add") || die "Can not open file $filename.SA.sam: $!\n";
my $outkey = 0;

sub get_junction{
    local $i; local $j; 
    local(@tarline)=@_;
    ##forDebug1/3B##   print "\n"; for($i=0;$i<=$#tarline;$i++){print $tarline[$i];}
    local @col1 = (); @col1 = split(/\t/, $tarline[0]);   
    local @col2 = (); @col2 = split(/\t/, $tarline[1]);
    local $tag = "";
    $FLG1 = $col1[1];	$FLG2 = $col2[1];
    $CH1  = $col1[2]; 	$CH2  = $col2[2]; 
    $ST1  = $col1[3]; 	$ST2  = $col2[3]; 
    $SEQ1 = $col1[9];	$SEQ2 = $col2[9];
    if(length($SEQ1)>length($SEQ2)){$shortLen = length($SEQ2); $readLen = length($SEQ1);} else{$shortLen = length($SEQ1); $readLen = length($SEQ2);}

    $MIN_COMPL = $readLen *$MIN_COMPL_RATE; 
    $MAX_OL = $shortLen;
    $MAX_IR = $readLen;

    $MQ1  = $col1[4]; 	$MQ2  = $col2[4];
    if($MQ1<$MAPQ_MIN || $MQ2<$MAPQ_MIN){goto SKIP;}

    $AS1 = $AS2 = $XS1 = $XS2 =0;
    if($#col1!=12){@strAS=(); @strXS=();  @strAS = split(/:/,$col1[13]);  @strXS = split(/:/,$col1[14]);  $AS1 =$strAS[2]; $XS1 =$strXS[2];}
    if($#col2!=12){@strAS=(); @strXS=();  @strAS = split(/:/,$col2[13]);  @strXS = split(/:/,$col2[14]);  $AS2 =$strAS[2]; $XS2 =$strXS[2];}
    if($AS1-$XS1< $AS1*$MIN_AS_DIFF && $AS2-$XS2< $AS2*$MIN_AS_DIFF){goto SKIP;}

    @_n = split(/[MIDSH]/, $col1[5]); 				@_l = split(/[0-9]+/, $col1[5]);
    @cgN1=(); for($i=0;$i<=$#_n;$i++){push(@cgN1, $_n[$i]);}	@cgL1=(); for($i=0;$i<=$#_l;$i++){push(@cgL1, $_l[$i]);}  splice(@cgL1,0,1);
    @_n = split(/[MIDSH]/, $col2[5]); 				@_l = split(/[0-9]+/, $col2[5]);
    @cgN2=(); for($i=0;$i<=$#_n;$i++){push(@cgN2, $_n[$i]);}	@cgL2=(); for($i=0;$i<=$#_l;$i++){push(@cgL2, $_l[$i]);}  splice(@cgL2,0,1);
    $tmp_bp = "";

    ##forDebug1/4C##  print "a_ $#cgL1,  @cgL1\n"; print "a_ $#cgN1,  @cgN1\n\n";
    ##forDebug2/4C##  print "b- $#cgL2,  @cgL2\n"; print "b- $#cgN2,  @cgN2\n\n";

    for($i=0;$i<$#cgN1;$i++){ if($cgL1[$i] eq "D"){splice(@cgL1,$i,1); splice(@cgN1,$i,1);} }
    for($i=0;$i<$#cgN2;$i++){ if($cgL2[$i] eq "D"){splice(@cgL2,$i,1); splice(@cgN2,$i,1);} }

    ##forDebug3/4C##  print "A- $#cgL1,  @cgL1\n"; print "A- $#cgN1,  @cgN1\n\n";
    ##forDebug4/4C##  print "B- $#cgL2,  @cgL2\n"; print "B- $#cgN2,  @cgN2\n\n";

    $cnt_fs=$cnt_rs=0;
    for($i=0;$i<=$#FLAG_FS;$i++){
	if($FLG1 == $FLAG_FS[$i]){$cnt_fs += 1;} elsif($FLG1 == $FLAG_FS[$i]+2048){$cnt_fs += 2;}
	if($FLG2 == $FLAG_FS[$i]){$cnt_fs += 1;} elsif($FLG2 == $FLAG_FS[$i]+2048){$cnt_fs += 2;}
	if($FLG1 == $FLAG_RS[$i]){$cnt_rs += 1;} elsif($FLG1 == $FLAG_RS[$i]+2048){$cnt_rs += 2;}
	if($FLG2 == $FLAG_RS[$i]){$cnt_rs += 1;} elsif($FLG2 == $FLAG_RS[$i]+2048){$cnt_rs += 2;}
    }

    @cgseq_1 = (); $start_point = 0; 
    for($i=0;$i<=$#cgL1;$i++){ 
        for($j=$start_point;$j<$start_point+$cgN1[$i];$j++){ $cgseq_1[$j] = $cgL1[$i];} 
        $start_point = $j; 
    }##forDebug1/3A##  for($i=0;$i<=$#cgseq_1;$i++){print $cgseq_1[$i];}print "\n"; 

    ## incase both two fragments are same direction
    if($cnt_fs==3 || $cnt_rs==3){
        @cgseq_2 = (); $start_point = 0; 
	for($i=0;$i<=$#cgL2;$i++){
	    for($j=$start_point;$j<$start_point+$cgN2[$i];$j++){ $cgseq_2[$j] = $cgL2[$i]; } 
	    $start_point = $j;
	}##forDebug2/3A##  for($i=0;$i<=$#cgseq_2;$i++){print $cgseq_2[$i];}print "\n";

	$cnt_ol = $cnt_ir = $cnt_cmpl = 0; @flg_microsq=();  $flg_btw=$flg_periphe=0;
	for($i=0;$i<$read_len;$i++){
	    $flg_microsq[$i] = 0;
	    if( ($cgseq_1[$i] eq "M" && $cgseq_2[$i] eq "H") || ($cgseq_1[$i] eq "S" && $cgseq_2[$i] eq "M")){ $cnt_cmpl++; $flg_btw=1; if($flg_periphe!=0){$flg_btw++;}}
	    if(  $cgseq_1[$i] eq "M" && $cgseq_2[$i] eq "M")						    { $cnt_ol++; $flg_microsq[$i] = 1; } 
	    if((($cgseq_1[$i] eq "S" && $cgseq_2[$i] eq "H") || ($cgseq_1[$i] eq "S" && $cgseq_2[$i] eq "H"))&& $flg_btw==1){ $cnt_ir++; $flg_microsq[$i] = 2; if($flg_btw!=0){$flg_periphe=1;}}
	}
	if($flg_microsq[0]!=0){		 $i=0; 		 while($flg_microsq[$i]!=0){$flg_microsq[$i]=0; $i++;}}
	if($flg_microsq[$read_len-1]!=0){$i=$read_len-1; while($flg_microsq[$i]!=0){$flg_microsq[$i]=0; $i--;}}

	$edge_unMatch=0;
	for($i=0;$i<$read_len/2;$i++){if($cgseq_1[$i] eq "M" || $cgseq_2[$i] eq "M"){last;} elsif($cgseq_1[$i] ne "M" && $cgseq_2[$i] ne "M"){ $edge_unMatch++;}}
	for($i=$read_len-1;$i>=$read_len/2;$i--){
	    if($cgseq_1[$i] eq "M" || $cgseq_2[$i] eq "M"){last;} elsif($cgseq_1[$i] ne "M" && $cgseq_2[$i] ne "M"){
		if($i==$read_len-1 && $edge_unMatch!=0){ $edge_unMatch+=999; last;}
		else{					 $edge_unMatch++;}
	    }
	}
	$cntA1 = $cntA2 =0; for($i=0;$i<=$read_len;$i++){ if($cgseq_1[$i] ne "S"){$cntA1++;}  if($cgseq_2[$i] ne "H"){$cntA2++;} }	# count No.Algnemnt lemngth
	
	if($flg_btw==1 && $cnt_ir!=0){$cnt_ir=0;}  ##forDebug2/3B##  printf("1_ol: %d\tir: %d\tcomplement: %d\tedge_unMatch: %d\n",$cnt_ol,$cnt_ir,$cnt_cmpl,$edge_unMatch);

	if($cnt_ol<=$MAX_OL && $cnt_ir<=$MAX_IR && $cnt_cmpl>=$MIN_COMPL &&
	  ($edge_unMatch<$EDGE_UNMATCH && ($cgseq_1[0] eq "M" || $cgseq_1[$read_len-1] eq "M" || $cgseq_2[0] eq "M" || $cgseq_2[$read_len-1] eq "M"))){
#	  (($cgseq_1[0] eq "M" && $cgseq_2[$read_len-1] eq "M") || ($cgseq_1[$read_len-1] eq "M" && $cgseq_2[0] eq "M"))){
	    @tmpsq=(); @tmpsq = split(//, $SEQ1);
	    if($cnt_ol!=0){$tag="overlap: ";}  elsif($cnt_ir!=0){$tag="interruption: ";} 
	    for($i=0;$i<=$#tmpsq;$i++){if($flg_microsq[$i]!=0){if($st==0){$st=$i;} $tag .= $tmpsq[$i]; $en=$i}}
	    if($cgL1[0] eq "M" && $cgL2[1] eq "M" && "ht".$CH1.($ST1+$cgN1[0]-1).$ST2.$CH2 ne $tmp_bp){
	    	printf ("chr%s\t%10d -%dM-> %10d\t|\t%10d -%dM-> %10d\tchr%s\t%s\t%s\t",$CH1,$ST1,$cntA1,$ST1+$cntA1-1,  $ST2,$cntA2,$ST2+$cntA2-1,$CH2, $col1[0],$SEQ1);
		if(length($tag)!=0){printf("%s\t%d-%d\t%d-%d\n",$tag,$MQ1,$MQ2, $AS1-$XS1,$AS2-$XS2);}  else{printf("\t%d-%d\t%d-%d\n",$MQ1,$MQ2, $AS1-$XS1,$AS2-$XS2);}
		$outkey=1; $tmp_bp = "ht".$CH1.($ST1+$cgN1[0]-1).$ST2.$CH2;
	    }
	    if($cgL1[1] eq "M" && $cgL2[0] eq "M" && "ht".$CH2.($ST2+$cgN2[0]-1).$ST1.$CH1 ne $tmp_bp){
	    	printf ("chr%s\t%10d -%dM-> %10d\t|\t%10d -%dM-> %10d\tchr%s\t%s\t%s\t",$CH2,$ST2,$cntA2,$ST2+$cntA2-1,  $ST1,$cntA1,$ST1+$cntA1-1,$CH1, $col1[0],$SEQ1);
		if(length($tag)!=0){printf("%s\t%d-%d\t%d-%d\n",$tag,$MQ2,$MQ1, $AS2-$XS2,$AS1-$XS1);}  else{printf("\t%d-%d\t%d-%d\n",$MQ2,$MQ1, $AS2-$XS2,$AS1-$XS1);}
		$outkey=1; $tmp_bp = "ht".$CH2.($ST2+$cgN2[0]-1).$ST1.$CH1;
	    }
	}
    }


    ## incase direction of two fragments are inverse
    elsif(($cnt_fs==2 && $cnt_rs==1) || ($cnt_fs==1 && $cnt_rs==2)){
        @cgseq_2 = (); $start_point = 0; 
	for($i=$#cgL2;$i>=0;$i--){
	    for($j=$start_point;$j<$start_point+$cgN2[$i];$j++){ $cgseq_2[$j] = $cgL2[$i]; } 
	    $start_point = $j; 
	}##forDebug3/3A##  for($i=0;$i<=$#cgseq_2;$i++){print $cgseq_2[$i];}print "\n";

	$cnt_ol = $cnt_ir = $cnt_cmpl = 0; @flg_microsq=(); $flg_btw=$flg_periphe=0;
	for($i=0;$i<$read_len;$i++){
	    $flg_microsq[$i] = 0;
	    if( ($cgseq_1[$i] eq "M" && $cgseq_2[$i] eq "H") || ($cgseq_1[$i] eq "S" && $cgseq_2[$i] eq "M")){ $cnt_cmpl++; $flg_btw=1; if($flg_periphe!=0){$flg_btw++;}}
	    if(  $cgseq_1[$i] eq "M" && $cgseq_2[$i] eq "M")						     		    { $cnt_ol++; $flg_microsq[$i] = 1;}
	    if((($cgseq_1[$i] eq "S" && $cgseq_2[$i] eq "H") || ($cgseq_1[$i] eq "S" && $cgseq_2[$i] eq "H"))&& $flg_btw==1){ $cnt_ir++; $flg_microsq[$i] = 2; if($flg_btw!=0){$flg_periphe=1;}}
	}
	if($flg_microsq[0]!=0){		 $i=0; 		 while($flg_microsq[$i]!=0){$flg_microsq[$i]=0; $i++;}}
	if($flg_microsq[$read_len-1]!=0){$i=$read_len-1; while($flg_microsq[$i]!=0){$flg_microsq[$i]=0; $i--;}}

        $edge_unMatch=0;
        for($i=0;$i<$read_len/2;$i++){if($cgseq_1[$i] eq "M" || $cgseq_2[$i] eq "M"){last;} elsif($cgseq_1[$i] ne "M" && $cgseq_2[$i] ne "M"){$edge_unMatch++;}}
        for($i=$read_len-1;$i>=$read_len/2;$i--){
            if($cgseq_1[$i] eq "M" || $cgseq_2[$i] eq "M"){last;} elsif($cgseq_1[$i] ne "M" && $cgseq_2[$i] ne "M"){
                if($i==$read_len-1 && $edge_unMatch!=0){ $edge_unMatch=999; last;}
                else{					 $edge_unMatch++;}
            }
        }
	$cntA1 = $cntA2 =0; for($i=0;$i<=$read_len;$i++){ if($cgseq_1[$i] ne "S"){$cntA1++;}  if($cgseq_2[$i] ne "H"){$cntA2++;} }	# count No.Algnemnt lemngth

	if($flg_btw==1 && $cnt_ir!=0){$cnt_ir=0;}  ##forDebug3/3B##  printf("2_ol: %d\tir: %d\tcomplement: %d\tedge_unMatch: %d\n",$cnt_ol,$cnt_ir,$cnt_cmpl,$edge_unMatch);

	if($cnt_ol<=$MAX_OL && $cnt_ir<=$MAX_IR && $cnt_cmpl>=$MIN_COMPL &&
	  ($edge_unMatch<$EDGE_UNMATCH && ($cgseq_1[0] eq "M" || $cgseq_2[$read_len-1] eq "M" || $cgseq_1[$read_len-1] eq "M" || $cgseq_2[0] eq "M"))){
#	  (($cgseq_1[0] eq "M" && $cgseq_2[$read_len-1] eq "M") || ($cgseq_1[$read_len-1] eq "M" && $cgseq_2[0] eq "M"))){
	    @tmpsq=(); @tmpsq = split(//, $SEQ1);
	    if($cnt_ol!=0){$tag="overlap: ";} elsif($cnt_ir!=0){$tag="interruption: ";}
	    for($i=0;$i<=$#tmpsq;$i++){if($flg_microsq[$i]!=0){if($st==0){$st=$i;} $tag .= $tmpsq[$i]; $en=$i}}

   	    if($cgL1[0] eq "M" && $cgL2[0] eq "M" && "hh".$CH1.($ST1+$cgN1[0]-1).($ST2+$cgN2[0]-1).$CH2 ne $tmp_bp){
	    	printf ("chr%s\t%10d -%dM-> %10d\t|\t%10d <-%dM- %10d\tchr%s\t%s\t%s\t",$CH1,$ST1,$cntA1,$ST1+$cntA1-1,  $ST2+$cntA2-1,$cntA2,$ST2,$CH2, $col1[0],$SEQ1);
		if(length($tag)!=0){printf("%s\t%d-%d\t%d-%d\n",$tag,$MQ1,$MQ2, $AS1-$XS1,$AS2-$XS2);}  else{printf("\t%d-%d\t%d-%d\n",$MQ1,$MQ2, $AS1-$XS1,$AS2-$XS2);}
		$outkey=1; $tmp_bp = "hh".$CH1.($ST1+$cgN1[0]-1).($ST2+$cgN2[0]-1).$CH2;
	    }
	    if($cgL1[0] eq "S" && $cgL1[1] eq "M" && $cgL2[0] eq "M" && "hh".$CH1.($ST1+$cgN1[1]-1).($ST2+$cgN2[0]-1).$CH2 ne $tmp_bp){
	    	printf ("chr%s\t%10d -%dM-> %10d\t|\t%10d <-%dM- %10d\tchr%s\t%s\t%s\t",$CH1,$ST1,$cntA1,$ST1+$cntA1-1,  $ST2+$cntA2-1,$cntA2,$ST2,$CH2, $col1[0],$SEQ1);
		if(length($tag)!=0){printf("%s\t%d-%d\t%d-%d\n",$tag,$MQ1,$MQ2, $AS1-$XS1,$AS2-$XS2);}  else{printf("\t%d-%d\t%d-%d\n",$MQ1,$MQ2, $AS1-$XS1,$AS2-$XS2);}
		$outkey=1; $tmp_bp = "hh".$CH1.($ST1+$cgN1[1]-1).($ST2+$cgN2[0]-1).$CH2;
	    }
	    if($cgL1[1] eq "M" && $cgL2[1] eq "M" && "tt".$CH2.$ST2.$ST1.$CH1 ne $tmp_bp){
	    	printf ("chr%s\t%10d <-%dM- %10d\t|\t%10d -%dM-> %10d\tchr%s\t%s\t%s\t",$CH2,$ST2+$cntA2-1,$cntA2,$ST2,  $ST1,$cntA1,$ST1+$cntA1-1,$CH1, $col1[0],$SEQ1);
		if(length($tag)!=0){printf("%s\t%d-%d\t%d-%d\n",$tag,$MQ2,$MQ1, $AS2-$XS2,$AS1-$XS1);}  else{printf("\t%d-%d\t%d-%d\n",$MQ2,$MQ1, $AS2-$XS2,$AS1-$XS1);}
		$outkey=1; $tmp_bp = "tt".$CH2.$ST2.$ST1.$CH1;
	    }
	}
    }
#    else {
#	print $cnt_fs,$cnt_rs."\n__".$tarline[0]."__".$tarline[1]."\n";
#    }
    SKIP:;    
    return $outkey;
}

open(FILE, $filename) || die "Can not open file $filename $!\n";
$n = 0;
while($line[$n] = <FILE>){
    if($line[$n] =~ /^@/){ next; }	# print $n." ".$line[$n];

    @column = split(/\t/, $line[$n]); 
    $FLAG[$n]  = $column[1];
    $CH_R[$n]  = $column[2];  $ST_R[$n]   = $column[3];  # 'ST_R' means 'STart coordinate'
    $CH_M[$n]  = $column[6];  $ST_M[$n]   = $column[7];  # 'ST_M' means 'STart coordinate of MateRead'
    $MAPQ[$n]  = $column[4];
    $CIGAR[$n] = $column[5];				 # ex. CIGAR = 40M60S
    if($CIGAR[$n] eq "*"){ $MATCH[$n] =0; }
    else{ 
        @CIGARstring_N = split(/[A-Z]/,$column[5]); 	 # CIGAR_number:          N[0]=40,  N[1]=60
        @CIGARstring_A = split(/[0-9]{1,}/,$column[5]);	 # CIGAR_char:   A[0]="", A[1]="M", A[2]="S"
        $MATCH[$n]=$insrt[$n]=0; for($i=1;$i<=$#CIGARstring_A;$i++){
	    if($CIGARstring_A[$i] eq "M"){$MATCH[$n] += $CIGARstring_N[($i-1)];}
	    if($CIGARstring_A[$i] eq "I"){$insrt[$n] += $CIGARstring_N[($i-1)];}
	} 
    }
# print "\$MATCH[$n], $MATCH[$n]   \$insrt[$n], $insrt[$n]\n";
    $alnLen[$n] = length($column[9]);
    $SQERR[$n]=($column[10] =~ s/#//g); if($SQERR[$n]==""){$SQERR[$n]=0;} # SQERR: number of '#' generated in base calling 
    @NMstring    = split(/:/,$column[11]); $NM[$n] = $NMstring[2];
    @ASstring    = split(/:/,$column[13]); $AS[$n] = $ASstring[2];  chomp($AS[$n]);
    @XSstring    = split(/:/,$column[14]); $XS[$n] = $XSstring[2];

    if($cur_read_id eq "" || ($column[0] eq $cur_read_id)){$n++;}
    else {
	$outkey = 0;
# for($i=0;$i<$n;$i++){print "==".$line[$i];}
	# skip properly-paired read (there are a pair of CIGAR=100M read)
	$n_fullMatch_CIGAR=0;
	for($i=0;$i<$n;$i++){
	    if($CIGAR[$i] eq $alnLen[$i]."M"){$n_fullMatch_CIGAR++;}
	    if($n_fullMatch_CIGAR==2){goto NEXT;}
	}

	$max_mq = 0;
	for($i=0;$i<$n;$i++){
	    next if($CIGAR[$i] eq $alnLen[$i]."M");
	    next if($CH_R[$i] =~ /^GL/ || $CH_R[$i] eq "hs37d5" || $CH_R[$i] =~ /^NC/ || $CH_R[$i] =~ /^M/);	# discard not-target contig(read)
	    next if($CH_M[$i] =~ /^GL/ || $CH_M[$i] eq "hs37d5" || $CH_M[$i] =~ /^NC/ || $CH_M[$i] =~ /^M/);	# discard not-target contig(mate)
#	    next if(($CIGAR[$i] =~ tr/H//)>2 || ($CIGAR[$i] =~ tr/S//)>2 || $CIGAR[$i] eq $alnLen[$i]."M");     # discard read too complex alignment or without soft/hard clip
	    next if($insrt[$i]>=$ALN_INSERT);									# discard too match Insert in alignment
	    next if($NM[$i]>$MATCH[$i]*$NMRATE_MAX);								# discard read with too much mismatch
# print "=@".$line[$i];

	    if($FLAG[$i]<2048){
		$read_len = $alnLen[$i];
		if($MAPQ[$i]>$max_mq){ $max_mq = $MAPQ[$i]; }
	    } 

	    if($tmp != $ST_M[$i] || $FLAG[$i]<2048){ @chimeric_fragment=(); push(@chimeric_fragment, $line[$i]); }
	    else{ push(@chimeric_fragment, $line[$i]); }
	    if($#chimeric_fragment>=1){
		@flag = split(/\t/, $chimeric_fragment[0]); 
		if($flag[1]<2048){ get_junction(@chimeric_fragment); $#chimeric_fragment -=1; } 
		else { 						     $#chimeric_fragment -=2; }
	    }
	    $tmp = $ST_M[$i];
	}
	if($outkey == 1){for($i=0;$i<$n;$i++){if($FLAG[$i]<2048){printf(FILE_SA "%s",$line[$i]);}}}

	$flg_SAadd=0; for($i=0;$i<$n;$i++){
	    next if($CH_R[$i] =~ /^GL/ || $CH_R[$i] eq "hs37d5" || $CH_R[$i] =~ /^NC/ || $CH_R[$i] =~ /^M/);	# discard not-target contig(read)
	    next if($CH_M[$i] =~ /^GL/ || $CH_M[$i] eq "hs37d5" || $CH_M[$i] =~ /^NC/ || $CH_M[$i] =~ /^M/);	# discard not-target contig(mate)
	    next if($FLAG[$i] >=2048);
	    next if($SQERR[$i] >= $read_len*0.30);
	    if($MATCH[$i]>$read_len*0.70 && $MAPQ[$i]>30){ $flg_SAadd+=1; }
	    elsif($MATCH[$i]<20){ 	     		   $flg_SAadd+=2; }
	} 
#	if($flg_SAadd==3){for($i=0;$i<$n;$i++){if($FLAG[$i]<2048){ printf(FILE_SAA "%s", $line[$i]); }}}

	NEXT:;
	$line[0] = $line[$n];
        @column = split(/\t/, $line[$0]); 
	$FLAG[0]  = $column[1];
	$CH_R[0]   = $column[2];  $ST_R[0]   = $column[3];
	$CH_M[0]   = $column[6];  $ST_M[0]   = $column[7];
	$MAPQ[0]  = $column[4];
	$CIGAR[0] = $column[5];
	if($CIGAR[0] eq "*"){ $MATCH[0] =0; }
	else{
            @CIGARstring_N = split(/[A-Z]/,$column[5]);      # CIGAR_number:          N[0]=40,  N[1]=60
            @CIGARstring_A = split(/[0-9]{1,}/,$column[5]);  # CIGAR_char:   A[0]="", A[1]="M", A[2]="S"
            $MATCH[0]=$insrt[0]=0; for($i=1;$i<=$#CIGARstring_A;$i++){
	    	if($CIGARstring_A[$i] eq "M"){$MATCH[0] += $CIGARstring_N[($i-1)];}
	    	if($CIGARstring_A[$i] eq "I"){$insrt[0] += $CIGARstring_N[($i-1)];}
	    } 
	}
        $alnLen[0] = length($column[9]);
    	$SQERR[0]=($column[10] =~ s/#//g); if($SQERR[0]==""){$SQERR[0]=0;} 
        @NMstring = split(/:/,$column[11]); $NM[0] = $NMstring[2];
        @ASstring    = split(/:/,$column[13]); $AS[0] = $ASstring[2];  chomp($AS[0]);
        @XSstring    = split(/:/,$column[14]); $XS[0] = $XSstring[2];
	$n=1;
    }
    $cur_read_id = $column[0];
}

$max_mq = 0;
for($i=0;$i<$n;$i++){
    next if($CH_R[$i] =~ /^GL/ || $CH_R[$i] eq "hs37d5" || $CH_R[$i] =~ /^NC/ || $CH_R[$i] =~ /^M/);
    next if($CH_M[$i] =~ /^GL/ || $CH_M[$i] eq "hs37d5" || $CH_M[$i] =~ /^NC/ || $CH_M[$i] =~ /^M/);    
#   next if(($CIGAR[$i] =~ tr/H//)>2 || ($CIGAR[$i] =~ tr/S//)>2 || $CIGAR[$i] eq $read_len."M");
    next if($insrt[$i]>=$ALN_INSERT);									# discard too match Insert in alignment
    next if($NM[$i]>$MATCH[$i]*$NMRATE_MAX);
    if($FLAG[$i]<2048 && $MAPQ[$i]>$max_mq){$max_mq = $MAPQ[$i];}

    if($i==0){@chimeric_fragment=(); push(@chimeric_fragment, $line[$i]);}

    if($tmp == $ST_M[$i]){push(@chimeric_fragment, $line[$i]);} 
    else{@chimeric_fragment=(); push(@chimeric_fragment, $line[$i]);}
 
    if($#chimeric_fragment>=1){
        get_junction(@chimeric_fragment);
        $#chimeric_fragment--;
    }
    $tmp = $ST_M[$i];
}
if($outkey == 1){for($i=0;$i<$n;$i++){if($FLAG[$i]<2048){printf(FILE_SA "%s", $line[$i]);}}}

$flg_SAadd=0; for($i=0;$i<$n;$i++){
    next if($CH_R[$i] =~ /^GL/ || $CH_R[$i] eq "hs37d5" || $CH_R[$i] =~ /^NC/ || $CH_R[$i] =~ /^M/);	
    next if($CH_M[$i] =~ /^GL/ || $CH_M[$i] eq "hs37d5" || $CH_M[$i] =~ /^NC/ || $CH_M[$i] =~ /^M/);	
    next if($FLAG[$i] >=2048);
    next if($SQERR[$i] >= $read_len*0.30);
    if($MATCH[$i]>$read_len*0.70 && $MAPQ[$i]>30){ $flg_SAadd+=1; }
    elsif($MATCH[$i]<20){ 	     		   $flg_SAadd+=2; }
} 
# if($flg_SAadd==3){for($i=0;$i<$n;$i++){if($FLAG[$i]<2048){ printf(FILE_SAA "%s", $line[$i]); }}}


close(FILE_SA);
# close(FILE_SAA);
close(FILE);
