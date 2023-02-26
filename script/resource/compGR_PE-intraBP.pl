#! /usr/bin/perl

if($#ARGV < 5){
    printf STDERR "usage: $0 [intraBP.list] [rearrangement10.txt] [smplID] [read_length] [PATH_tmpT] [shift] (-opt)\n";
    printf STDERR "  (-opt): ONLY merged-SVline are output in intraBP.list-format\n";
    exit -1;
}
$smplID = $ARGV[2];
$readLen= $ARGV[3];
$path_tmpT= $ARGV[4]; 
$shift  = $ARGV[5];

my $cnt_wo_rdd = $olRate = 0;

open(DEL,    "./.deletion_fr_cluster.txt") || die "Can not open file .deletion_cluster.txt: $!\n";
open(INV_FF, "./.inversion_ff_cluster.txt") || die "Can not open file .inversion_ff_cluster.txt: $!\n";
open(INV_RR, "./.inversion_rr_cluster.txt") || die "Can not open file .inversion_rr_cluster.txt: $!\n";
open(TDM,    "./.tandem_dup_rf_cluster.txt") || die "Can not open file .tandem_cluster.txt: $!\n";
open(TR_FF, "./.translocation_ff_cluster.txt") || die "Can not open file .translocation_ff_cluster.txt: $!\n";
open(TR_FR, "./.translocation_fr_cluster.txt") || die "Can not open file .translocation_fr_cluster.txt: $!\n";
open(TR_RR, "./.translocation_rr_cluster.txt") || die "Can not open file .translocation_rr_cluster.txt: $!\n";

sub judge_overlap{
    local(@c)=@_;  # 'c' mean Corrdinate
    $olRate_L = $olRate_R = 0;
    $clLen_SC_L = $c[5] - $c[4];   $clLes_SC_R = $c[7] - $c[6];

    if(   $c[4]<=$c[0] && $c[0]<=$c[5] && $c[5]<=$c[1]){$olRate_L = ($c[5]-$c[0])/$clLen_SC_L;}      
    elsif($c[0]<=$c[4] && $c[4]<=$c[5] && $c[5]<=$c[1]){$olRate_L = 1;}      
    elsif($c[0]<=$c[4] && $c[4]<=$c[1] && $c[1]<=$c[5]){$olRate_L = ($c[1]-$c[4])/$clLen_SC_L;}      
#    else {printf("Left:  PE_[ %d - %d ]\tSoftClip_[ %d - %d ]\n",$c[0],$c[1],$c[4],$c[5]);} 
 
    if(   $c[6]<=$c[2] && $c[2]<=$c[7] && $c[7]<=$c[3]){$olRate_R = ($c[7]-$c[2])/$clLes_SC_R;}      
    elsif($c[2]<=$c[6] && $c[6]<=$c[7] && $c[7]<=$c[3]){$olRate_R = 1;}      
    elsif($c[2]<=$c[6] && $c[6]<=$c[3] && $c[3]<=$c[7]){$olRate_R = ($c[3]-$c[6])/$clLes_SC_R;}      
#    else {printf("Right: PE_[ %d - %d ]\tSoftClip_[ %d - %d ]\n",$c[2],$c[3],$c[6],$c[7]);} 

    $olRate = ($olRate_L + $olRate_R)/2;
# print "overlap:\t".$olRate."\t[ ".$olRate_L." , ".$olRate_R." ]\n";
    return($olRate);
}

sub judge_mergeablity{
    $cnt_wo_rdd =0;
    local(@tarline)=@_;  # print "@\@_".$tarline[0]."\n@\@_".$tarline[1];
    local @colS = (); @colS = split(/\s+/, $tarline[0]);   ## intraBP.list('S'oftclip) 
    local @colP = (); @colP = split(/\t/,  $tarline[1]);   ## rearrangement.txt('P'aired End)

    $cl_flg=0; @read_id=(); $tmpdir="";
    if($colS[10] =~ $colP[2+$shift] && $colS[10] =~ /deletion/){
	seek(DEL,0,0);
	while($buff = <DEL>){
	    if($cl_flg==1 && length($buff)>50){last;}
	    if($tarline[1] =~ $buff){$cl_flg=1;}
	    if($cl_flg==1 && length($buff)<=50){ chomp($buff); push(@read_id, $buff);}
	}
	$tmpdir = "HT";
    }
    elsif($colS[10] =~ $colP[2+$shift] && $colS[10] =~ /tandem_dup/){
	seek(TDM,0,0);
	while($buff = <TDM>){
	    if($cl_flg==1 && length($buff)>50){last;}
	    if($tarline[1] =~ $buff){$cl_flg=1;}
	    if($cl_flg==1 && length($buff)<=50){ chomp($buff); push(@read_id, $buff); }
	}
	$tmpdir = "HT";
    }
    elsif($colS[10] =~ $colP[2+$shift] && $colS[10] =~ /inversion_ff/){
	seek(INV_FF,0,0);
	while($buff = <INV_FF>){
	    if($cl_flg==1 && length($buff)>50){last;}
	    if($tarline[1] =~ $buff){$cl_flg=1; }
	    if($cl_flg==1 && length($buff)<=50){ chomp($buff); push(@read_id, $buff);}
	}
	$tmpdir = "HH";
    }
    elsif($colS[10] =~ $colP[2+$shift] && $colS[10] =~ /inversion_rr/){
	seek(INV_RR,0,0);
	while($buff = <INV_RR>){
	    if($cl_flg==1 && length($buff)>50){last;}
	    if($tarline[1] =~ $buff){$cl_flg=1;}
	    if($cl_flg==1 && length($buff)<=50){ chomp($buff); push(@read_id, $buff); }
	}
	$tmpdir = "TT";
    }
    elsif($colS[10] =~ $colP[2+$shift] && $colS[10] =~ /translocation_fr/){
	seek(TR_FR,0,0);
	while($buff = <TR_FR>){
	    if($cl_flg==1 && length($buff)>50){last;}
	    if($tarline[1] =~ $buff){$cl_flg=1;}
	    if($cl_flg==1 && length($buff)<=50){ chomp($buff); push(@read_id, $buff); }
	}
	$tmpdir = "trHT";
    }
    elsif($colS[10] =~ $colP[2+$shift] && $colS[10] =~ /translocation_ff/){
	seek(TR_FF,0,0);
	while($buff = <TR_FF>){
	    if($cl_flg==1 && length($buff)>50){last;}
	    if($tarline[1] =~ $buff){$cl_flg=1;}
	    if($cl_flg==1 && length($buff)<=50){ chomp($buff); push(@read_id, $buff); }
	}
	$tmpdir = "trHH";
    }
    elsif($colS[10] =~ $colP[2+$shift] && $colS[10] =~ /translocation_rr/){
	seek(TR_RR,0,0);
	while($buff = <TR_RR>){  
	    if($cl_flg==1 && length($buff)>50){last;}
	    if($tarline[1] =~ $buff){$cl_flg=1;}
	    if($cl_flg==1 && length($buff)<=50){ chomp($buff); push(@read_id, $buff); }
	}
	$tmpdir = "trTT";
    }
    else {print $colS[10]."_iB_".$tarline[0]."\n".$colP[2+$shift]."_PE_".$tarline[1]."\n";}

#   print "BEFORE RMDUP_cntPE :\t\t".($#read_id + 1)."\n";
    system("grep $colS[3] $path_tmpT/tmpTout/$tmpdir/.$chr1.chim | grep $colS[5] | cut -f6 > .tmp.id_$$\0");
    open(TMP_FP, "./.tmp.id_$$");
    while($buff = <TMP_FP>){
	chomp($buff);
	push(@read_id, $buff);
    }
    close(TMP_FP);

#   print "BEFORE RMDUP_PE+iBP :\t\t".($#read_id + 1)."\n";
    local $i,$j;
#   for($i=0;$i<=$#read_id;$i++){print $i."\t".$read_id[$i]."\n";}

 
    for($i=0;$i<=$#read_id;$i++){$flg_rid[$i]=0;}
    $cnt_wo_rdd =0;
    for($i=0;$i<=$#read_id;$i++){
	if($flg_rid[$i]==0){$cnt_wo_rdd++;}
	for($j=0;$j<=$#read_id;$j++){
	    if($i!=$j && $read_id[$i]eq$read_id[$j] && $flg_rid[$j]==0){$flg_rid[$j]=1;}
	}
    }
#   print "COUNT_WITHOUT_REDUNDANCY:  ".$cnt_wo_rdd."\n";
#   if(($#read_id +1) == $cnt_wo_rdd){
#	print "No read-overlap between PE- and iBP-cluster\n";
#       print $colS[1]." - ".$colS[3]."\t".$colS[5]." - ".$colS[7]."\n";
#	print $colP[5+$shift]." - ".$colP[6+$shift]."\t".$colP[10+$shift]." - ".$colP[11+$shift]."\n";
#	print "No read-overlap between PE- and iBP-cluster\n"; return $cnt_wo_rdd;
#   }
#   else { return $cnt_wo_rdd; }
    return $cnt_wo_rdd;
}


open(FILE, $ARGV[1]) || die "Can not open file $conf: $!\n";
$n=0;
while($line[$n] = <FILE>){  ## Read PE-GR list, caliculate distance between psuedo-BP coordinate and intraBP-coordinate 
    @column = split(/\t/, $line[$n]);
    $dr[$n] = $column[0+$shift];
    $ch1[$n] = $column[4+$shift];  $clst1[$n] = $column[ 5+$shift];  $clen1[$n] = $column[ 6+$shift];	$anno1[$n] = $column[ 8+$shift];
    $ch2[$n] = $column[9+$shift];  $clst2[$n] = $column[10+$shift];  $clen2[$n] = $column[11+$shift];	$anno2[$n] = $column[13+$shift];
    $id[$n]  = $column[1+$shift];
    $evnt[$n] = $column[2+$shift];
    $count[$n]= $column[3+$shift];
    $flg_prnt[$n] = 0;
    $n++;
}
if($n==0){$id[0]=$smplID;}
close(FILE);


open(FILE, $ARGV[0]) || die "Can not open file $conf: $!\n";
while($line2 = <FILE>){     ## Read intraBP.list, store pair of coordinates of Breakpoint.   # print "\n#iBP:____".$line2;
    chomp($line2);
    @column = split(/\s+/, $line2);  $NF = $#column;
    $chr1 = $column[0];  $bp1  = $column[3]; $bpEnd1  = $column[1]; 
    $chr2 = $column[8];  $bp2  = $column[5]; $bpEnd2  = $column[7];
    $NoRead = $column[9];

    $event = $column[10];
    if($event =~ /_fr/ || $event eq "deletion"){$dir="FR";} 
    if($event eq "tandem_dup"){$dir="RF";}
    if($event =~ /_ff/){$dir="FF";} 
    if($event =~ /_rr/){$dir="RR";} 

    if($column[11] eq "\-"){$interTp = "-";  	    $interSq = "";	    $infoMq  = $column[12]; $infoAs  = $column[13];}
    else {		    $interTp = $column[11]; $interSq = $column[12]; $infoMq  = $column[13]; $infoAs  = $column[14];}
    $infoVAF = $column[$NF-7].",".$column[$NF-6].",".$column[$NF-5].",".$column[$NF-4].",".$column[$NF-3].",".$column[$NF-2].":".$column[$NF-1];
#   $infoVAF = $column[$NF-7].",".$column[$NF-6].                   ",".$column[$NF-4].",".$column[$NF-3].                   ":".$column[$NF-1];

    my @judge_GRlist; push(@judge_GRlist,$line2);
    $annote1=$annote2="-";
    for($i=0;$i<$n;$i++){ ## search around PE-list([0]~[$n])  
        $cnt_wo_rdd = $olRate = 0;

	my @judge_ol;
	$cl1_L = $clst1[$i] - $readLen;  $cl1_R = $clen1[$i] + $readLen;   push(@judge_ol,$clst1[$i]);  push(@judge_ol,$clen1[$i]); 
	$cl2_L = $clst2[$i] - $readLen;  $cl2_R = $clen2[$i] + $readLen;   push(@judge_ol,$clst2[$i]);  push(@judge_ol,$clen2[$i]);

	if($event=~$evnt[$i] && $event eq "deletion"   && $dir eq $dr[$i] && $dir eq "FR" ){ 
            if(($cl1_L<=$bpEnd1 && $bp1<=$cl1_R) && ($cl2_L<=$bp2 && $bpEnd2<=$cl2_R) && $bp1<$bp2){ 
		push(@judge_ol,$bpEnd1); push(@judge_ol,$bp1);  push(@judge_ol,$bp2); push(@judge_ol,$bpEnd2);  judge_overlap(@judge_ol);
		push(@judge_GRlist,$line[$i]); judge_mergeablity(@judge_GRlist); 
		if($cnt_wo_rdd < ($NoRead+$count[$i]) || $olRate >=0.95 ){$flg_prnt[$i]=$bp1;  $annote1=$anno1[$i]; $annote2=$anno2[$i];  goto OUTPUT;}
	    }
	}

	if($event=~$evnt[$i] && $event =~ "tandem_dup" && $dir eq $dr[$i] && $dir eq "RF" ){
            if(($cl1_L<=$bp2 && $bpEnd2<=$cl1_R) && ($cl2_L<=$bpEnd1 && $bp1<=$cl2_R) && $bp1>$bp2){ 
		push(@judge_ol,$bp2); push(@judge_ol,$bpEnd2);  push(@judge_ol,$bpEnd1); push(@judge_ol,$bp1);  judge_overlap(@judge_ol);
		push(@judge_GRlist,$line[$i]); judge_mergeablity(@judge_GRlist); 
		if($cnt_wo_rdd < ($NoRead+$count[$i]) || $olRate >=0.95 ){$flg_prnt[$i]=$bp1;  $annote1=$anno1[$i]; $annote2=$anno2[$i];  goto OUTPUT;}
	    }
	}

 	if($event=~$evnt[$i] && $event =~ "inversion"  && $dir eq $dr[$i]){
	  if($dir eq "FF"){
	    if(($cl1_L<=$bpEnd1 && $bp1<=$cl1_R) && ($cl2_L<=$bpEnd2 && $bp2<=$cl2_R)){ 
		push(@judge_ol,$bpEnd1); push(@judge_ol,$bp1);  push(@judge_ol,$bpEnd2); push(@judge_ol,$bp2);  judge_overlap(@judge_ol);
		push(@judge_GRlist,$line[$i]); judge_mergeablity(@judge_GRlist); 
		if($cnt_wo_rdd < ($NoRead+$count[$i]) || $olRate >=0.95 ){$flg_prnt[$i]=$bp1;  $annote1=$anno1[$i]; $annote2=$anno2[$i];  goto OUTPUT;}
	    }
	  }
	  if($dir eq "RR"){
	    if(($cl1_L<=$bp1 && $bpEnd1<=$cl1_R) && ($cl2_L<=$bp2 && $bpEnd2<=$cl2_R)){ 
		push(@judge_ol,$bp1); push(@judge_ol,$bpEnd1);  push(@judge_ol,$bp2); push(@judge_ol,$bpEnd2);  judge_overlap(@judge_ol);
		push(@judge_GRlist,$line[$i]); judge_mergeablity(@judge_GRlist); 
		if($cnt_wo_rdd < ($NoRead+$count[$i]) || $olRate >=0.95 ){$flg_prnt[$i]=$bp1;  $annote1=$anno1[$i]; $annote2=$anno2[$i];  goto OUTPUT;}
	    }
	  }
        }

        if($event=~$evnt[$i] && $event =~ "translocation" && $dir eq $dr[$i]){
	  if($dir eq "FR"){
	    if(($chr1 eq $ch1[$i] && $chr2 eq $ch2[$i]) && ($cl1_L<=$bpEnd1 && $bp1<=$cl1_R) && ($cl2_L<=$bp2 && $bpEnd2<=$cl2_R)){ 
		push(@judge_ol,$bpEnd1); push(@judge_ol,$bp1);  push(@judge_ol,$bp2); push(@judge_ol,$bpEnd2);  judge_overlap(@judge_ol);
		push(@judge_GRlist,$line[$i]); judge_mergeablity(@judge_GRlist); 
		if($cnt_wo_rdd < ($NoRead+$count[$i]) || $olRate >=0.95 ){$flg_prnt[$i]=$bp1;  $annote1=$anno1[$i]; $annote2=$anno2[$i];  goto OUTPUT;}
		else {$#judge_GRlist--;}
	    }
	  }
	  if($dir eq "FF"){
	    if(($chr1==$ch1[$i] && $chr2==$ch2[$i]) && ($cl1_L<=$bpEnd1 && $bp1<=$cl1_R) && ($cl2_L<=$bpEnd2 && $bp2<=$cl2_R)){ 
		push(@judge_ol,$bpEnd1); push(@judge_ol,$bp1);  push(@judge_ol,$bpEnd2); push(@judge_ol,$bp2);  judge_overlap(@judge_ol);
		push(@judge_GRlist,$line[$i]); judge_mergeablity(@judge_GRlist); 
		if($cnt_wo_rdd < ($NoRead+$count[$i]) || $olRate >=0.95 ){$flg_prnt[$i]=$bp1;  $annote1=$anno1[$i]; $annote2=$anno2[$i];  goto OUTPUT;}
		else {$#judge_GRlist--;}
	    }
	    elsif($cnt_wo_rdd==0 && $olRate <0.95 &&
	       ($chr1==$ch2[$i] && $chr2==$ch1[$i]) && ($cl1_L<=$bpEnd2 && $bp2<=$cl1_R) && ($cl2_L<=$bpEnd1 && $bp1<=$cl2_R)){ 
		push(@judge_ol,$bpEnd2); push(@judge_ol,$bp2);  push(@judge_ol,$bpEnd1); push(@judge_ol,$bp1);  judge_overlap(@judge_ol);
		push(@judge_GRlist,$line[$i]); judge_mergeablity(@judge_GRlist); 
		if($cnt_wo_rdd < ($NoRead+$count[$i]) || $olRate >=0.95 ){$flg_prnt[$i]=$bp1;  $annote1=$anno1[$i]; $annote2=$anno2[$i];  goto OUTPUT;}
	    }
	  }
	  if($dir eq "RR"){
	    if(($chr1==$ch1[$i] && $chr2==$ch2[$i]) && ($cl1_L<=$bp1 && $bpEnd1<=$cl1_R) && ($cl2_L<=$bp2 && $bpEnd2<=$cl2_R)){ 
		push(@judge_ol,$bp1); push(@judge_ol,$bpEnd1);  push(@judge_ol,$bp2); push(@judge_ol,$bpEnd2);  judge_overlap(@judge_ol);
		push(@judge_GRlist,$line[$i]); judge_mergeablity(@judge_GRlist);
		if($cnt_wo_rdd < ($NoRead+$count[$i]) || $olRate >=0.95 ){$flg_prnt[$i]=$bp1;  $annote1=$anno1[$i]; $annote2=$anno2[$i];  goto OUTPUT;}
		else {$#judge_GRlist--;}
	    }
	    elsif($cnt_wo_rdd==0 && $olRate <0.95 &&
	       ($chr1==$ch2[$i] && $chr2==$ch1[$i]) && ($cl1_L<=$bp2 && $bpEnd2<=$cl1_R) && ($cl2_L<=$bp1 && $bpEnd1<=$cl2_R)){ 
		push(@judge_ol,$bp2); push(@judge_ol,$bpEnd2);  push(@judge_ol,$bp1); push(@judge_ol,$bpEnd1);  judge_overlap(@judge_ol);
		push(@judge_GRlist,$line[$i]); judge_mergeablity(@judge_GRlist); 
		if($cnt_wo_rdd < ($NoRead+$count[$i]) || $olRate >=0.95 ){$flg_prnt[$i]=$bp1;  $annote1=$anno1[$i]; $annote2=$anno2[$i];  goto OUTPUT;}
	    }
	  }
        }
    }
    OUTPUT:;

    $shift_buff ="m\t"; for($i=1;$i<$shift;$i++){$shift_buff .= "-\t"}
    @ev=split(/_/, $event); if($event eq "tandem_dup"){$ev[0]="tandem_dup";}
    if(	  $dir eq "FR"){ $bp1L=$bpEnd1; $bp1R=$bp1;     $bp2L=$bp2;    $bp2R=$bpEnd2;   $dist = $bp2L-$bp1R;}
    elsif($dir eq "RF"){ $bp1L=$bp2;    $bp1R=$bpEnd2;  $bp2L=$bpEnd1; $bp2R=$bp1;      $dist = $bp2R-$bp1L;}
    elsif($dir eq "FF"){ $bp1L=$bpEnd1; $bp1R=$bp1;     $bp2L=$bpEnd2; $bp2R=$bp2;      $dist = $bp2R-$bp1R;}
    elsif($dir eq "RR"){ $bp1L=$bp1;    $bp1R=$bpEnd1;  $bp2L=$bp2;    $bp2R=$bpEnd2;   $dist = $bp2L-$bp1L;}
    else {print "\$dir is not defined, [$dir]\n";}
    if($chr1 ne $chr2){ $dist = "-"; }

   if($#ARGV==5){
    if($cnt_wo_rdd > $NoRead){
	print $shift_buff.$dir."\t".$id[0]."\t".$ev[0]."\t".$cnt_wo_rdd."\t".$chr1."\t".$bp1L."\t".$bp1R."\t".($bp1R-$bp1L)."\t".$annote1."\t".$chr2."\t".$bp2L."\t".$bp2R."\t".($bp2R-$bp2L)."\t".$annote2."\t-\t".$dist."\t".$interTp." ".$interSq."\t".$infoMq."\t".$infoAs."\t".$infoVAF."\n";
    }
    elsif($olRate > 0.95){
	print $shift_buff.$dir."\t".$id[0]."\t".$ev[0]."\t".$cnt_wo_rdd."\t".$chr1."\t".$bp1L."\t".$bp1R."\t".($bp1R-$bp1L)."\t".$annote1."\t".$chr2."\t".$bp2L."\t".$bp2R."\t".($bp2R-$bp2L)."\t".$annote2."\t-\t".$dist."\t".$interTp." ".$interSq."\t".$infoMq."\t".$infoAs."\t".$infoVAF."\n";
    }
    else {
	$shift_buff ="n\t"; for($i=1;$i<$shift;$i++){$shift_buff .= "-\t"}
	print $shift_buff.$dir."\t".$id[0]."\t".$ev[0]."\t".    $NoRead."\t".$chr1."\t".$bp1L."\t".$bp1R."\t".($bp1R-$bp1L)."\t".$annote1."\t".$chr2."\t".$bp2L."\t".$bp2R."\t".($bp2R-$bp2L)."\t".$annote2."\t-\t".$dist."\t".$interTp." ".$interSq."\t".$infoMq."\t".$infoAs."\t".$infoVAF."\n";
    }
   }
   # incase:(-opt) 
   else{ 
    if($cnt_wo_rdd > $NoRead){	print $line2."\n";}
    elsif($olRate > 0.95){	print $line2."\n";}
   }

#    if($cnt_wo_rdd == $NoRead && $olRate < 0.95){  
#	  # case that any corresponding PE-rearrangement not found.
#	  print "S$olRate".$shift_buff.$dir."\t".$id[0]."\t".$ev[0]."\tn_".$NoRead."\t".$chr1."\t".$bp1L."\t".$bp1R."\t0\t-\t".$chr2."\t".$bp2L."\t".$bp2R."\t0\t-\t-\t$dist\n";
#    } 
#    else{ print "T$olRate".$shift_buff.$dir."\t".$id[0]."\t".$ev[0]."\tm_".$cnt_wo_rdd."\t".$chr1."\t".$bp1L."\t".$bp1R."\t0\t-\t".$chr2."\t".$bp2L."\t".$bp2R."\t0\t-\t-\t$dist\n";
#	  print "T".$judge_GRlist[1]; 
#    }

    NEXT:
}
close(FILE);
close(DEL);
close(INV_FF);
close(INV_RR);
close(TDM);
close(TR_FF);
close(TR_FR);
close(TR_RR);

if($#ARGV==5){for($i=0;$i<$n;$i++){
#   print $flg_prnt[$i]."\t".$line[$i];
    if($flg_prnt[$i]==0){print $line[$i];}
}} # print "________________________\n"; for($i=0;$i<$n;$i++){print $flg_prnt[$i]."\n";}
