#! /usr/bin/perl
# modifyed by M.Adachi on 160106, for detectGR_list ver.2 
# 1. Check SAMflag(only use top hit of bwa-mem mapping output), 
# 2. Modify malformat , and 
# 3. Discard non-regular contig
# 4. Check uniformity of read length among samfiles
#
$MIN_ALNRATE = 0.90;
$MIN_MQ = 30;

if($#ARGV != 3){
    printf STDERR "usage: $0 [sam file] [max. insert] [prefix(fileid)] [.conf]\n";
    exit -1;
}
$filename = $ARGV[0];
# $len = $ARGV[1];
# $min = $ARGV[2];
$max = $ARGV[1];
$fileid = $ARGV[2];


$conf = $ARGV[3];
open(FILE, $conf) || die "Can not open file $conf: $!\n";
while($line = <FILE>){
    if($line =~ /^READ_LEN=/){  $READ_LEN_CONF = substr($line,9);  }
    elsif($line =~ /^READ_LEN_N=/){$READ_LEN_N = substr($line,11); }
}
close(FILE);

use Cwd; $wd = Cwd::getcwd();
@wdir = split(/\//, $wd);	# wdir: WorkingDirectory, tumor / normal

sub modifySamFormat{
    my (@col) = @_;
    if($col[2]/1!=0){	# chID type: INT
	if($col[6] eq "="){$mdf_line = $col[0]."\t".$col[1]."\tchr".$col[2]."\t".$col[3]."\t".$col[4]."\t".$col[5]."\t".   $col[6];}
	else {             $mdf_line = $col[0]."\t".$col[1]."\tchr".$col[2]."\t".$col[3]."\t".$col[4]."\t".$col[5]."\tchr".$col[6];}
    }
    else {		# chID type: CHAR [ X/Y/MT/hs37d5,GLXXXXX.X, etc. ]
	if(   $col[2] =~ /[X-Y]/){$mdfch2 = "chr".$col[2];}
	elsif($col[2] eq  "MT"  ){$mdfch2 = "chrM";}
	else {                    $mdfch2 = $col[2];}

	if($col[6] eq "="){$mdf_line = $col[0]."\t".$col[1]."\t".$mdfch2."\t".$col[3]."\t".$col[4]."\t".$col[5]."\t".$col[6];}
	else {
	    if($col[6] =~ /[X-Y]/){$mdfch6 = "chr".$col[6];}
	    elsif($col[6] eq "MT"){$mdfch6 = "chrM";}
	    else{		   $mdfch6 = $col[6];}
	                   $mdf_line = $col[0]."\t".$col[1]."\t".$mdfch2."\t".$col[3]."\t".$col[4]."\t".$col[5]."\t".$mdfch6;
	}
    }
    for($i=7;$i<$#col;$i++){$mdf_line .= "\t".$col[$i];} $mdf_line .= "\t".$col[$#col];
    return $mdf_line;
}

sub invert_sq{
    @plus_sq = split(//, @_[0]);
    my @_sq; $length=0;
    for($i=0;$i<=$#plus_sq;$i++){
	if(   $plus_sq[$i] eq "A"){$_sq[$length] = "T"; $length++;}
	elsif($plus_sq[$i] eq "G"){$_sq[$length] = "C"; $length++;}
	elsif($plus_sq[$i] eq "C"){$_sq[$length] = "G"; $length++;}
	elsif($plus_sq[$i] eq "T"){$_sq[$length] = "A"; $length++;}
	else {$_sq[$length] = $plus_sq[$i]; $length++;}
    }
    $org_sq ="";
    for($i=$length;$i>=0;$i--){$org_sq .= $_sq[$i];}
    return $org_sq;
}

open(FILE_R1, "> ${fileid}_SV1.fq") || die "Can not open file ${fileid}_SV1.fq $!\n";
open(FILE_R2, "> ${fileid}_SV2.fq") || die "Can not open file ${fileid}_SV2.fq $!\n";
open(FILE_sam, "> ${fileid}_org.sam") || die "Can not open file ${fileid}_org.sam $!\n";

open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line[0] = <FILE>){
    if($line[0] !~ /^@/){	

	@column0 = split(/\t/, $line[0]);  
	while($column0[1]>1000){ 
	    $line[0] = <FILE>;
	    @column0 = split(/\t/, $line[0]);
	}
	$line[1] = <FILE>;
	@column1 = split(/\t/, $line[1]);  
	while($column1[1]>1000){ 
	    $line[1] = <FILE>;
	    @column1 = split(/\t/, $line[1]);
	}

	while($column0[0] ne $column1[0]){
	    $line[0] = $line[1];
	    @column0 = split(/\t/, $line[0]);
	    $line[1] = <FILE>;
	    @column1 = split(/\t/, $line[1]);
	    while($column1[1]>1000){
	        $line[1] = <FILE>;
		@column1 = split(/\t/, $line[1]);
            }
	}

	$FORMAT_READ_LEN = $READ_LEN_CONF / 1;
#	if(length($column0[9])!=$FORMAT_READ_LEN){
#	    open(FILE_err, "> classifyFlag3_non-uniformity_READLEN.err");
#	    printf(FILE_err  "___ %s\n", $line[0]);
#	    printf(FILE_err "all SAM-formated input files are required uniformity in read length.\n");
#	    printf(FILE_err "%d [.rearrangement.conf] != %d [%s]   %s\n", $FORMAT_READ_LEN, length($column0[9]), $fileid, $line[0]);
#	    close(FILE_err);
#	    exit -1;
#	}
	$len  = $min = $FORMAT_READ_LEN;
	$asMn = $len * $MIN_ALNRATE;

	if($flg0==0){ $ret0 = &modifySamFormat(@column0); if($ret0 >= 0){$line[0] = $ret0;} else{printf(STDERR "__%s",$line[0]);}} 
	if($flg1==0){ $ret1 = &modifySamFormat(@column1); if($ret1 >= 0){$line[1] = $ret1;} else{printf(STDERR "__%s",$line[1]);}}


	$flg_multi = $sazMx =0;
	if($column0[4]==60 && $line[1]=~/SA:Z/){
	    my @saz; @saz = split(/;/,$column1[15]);
	    if($#saz>=1){for($i=1;$i<$#saz;$i++){
		my @p_saz; @p_saz = split(/,/,$saz[$i]);
		if($i==1){if($p_saz[4]>$MIN_MQ){$sazMx = $p_saz[4];}}  elsif($sazMx<=$p_saz[4] && $p_saz[4]>$MIN_MQ){$flg_multi =1;}
	    }}
	}
	elsif($column1[4]==60 && $line[0]=~/SA:Z/){
	    my @saz; @saz = split(/;/,$column0[15]);
	    if($#saz>=1){for($i=1;$i<$#saz;$i++){
		my @p_saz; @p_saz = split(/,/,$saz[$i]);
		if($i==1){if($p_saz[4]>$MIN_MQ){$sazMx = $p_saz[4];}}  elsif($sazMx<=$p_saz[4] && $p_saz[4]>$MIN_MQ){$flg_multi =1;}
	    }}
	}
	if($flg_multi == 1){next;}

	if((length($ret0)>0 && length($ret1)>0)||($flg0>0 && $flg1>0)){ 
	    judge_SAMflag_pair(@line); 
        }
    }
}


sub judge_SAMflag_pair{

    my (@jline) = @_;
    @list1 = split(/\t/, $jline[0]);
    @list2 = split(/\t/, $jline[1]);
    $line1 = $jline[0];
    $line2 = $jline[1];

    if($list1[1] <= $list2[1]){
        $flag1 = $list1[1];	$flag2 = $list2[1];
        $cig1 = $list1[5];	$cig2 = $list2[5];
        $chr1 = $list1[6];	$chr2 = $list2[6];
        $ins1 = $list1[8];	$ins2 = $list2[8];
    }
    else{
        $flag1 = $list2[1];	$flag2 = $list1[1];
        $cig1 = $list2[5];	$cig2 = $list1[5];
        $chr1 = $list2[6];	$chr2 = $list1[6];
        $ins1 = $list2[8];	$ins2 = $list1[8];
    }
    $hd1 = $list1[0];	$hd2 = $list2[0]; 
    $sq1 = $list1[9];	$sq2 = $list2[9];
    $mq1 = $list1[10];	$mq2 = $list2[10];
    @as1 = split(/:/, $list1[13]);  @as2 = split(/:/, $list2[13]);

    $flag = $flag1 . "-" . $flag2;

    if($chr1 eq "*" && $chr2 eq "*"){		# FILE_um
	printf(FILE_sam "%s%s", $jline[0],$jline[1]);
	printf(FILE_R1 "@%s\n%s\n+\n%s\n", $hd1,$sq1,$mq1);
	printf(FILE_R2 "@%s\n%s\n+\n%s\n", $hd2,$sq2,$mq2);
    }
    elsif($chr1 eq "=" && $chr2 eq "="){
        if($flag eq "69-137" ||	    # *F	# FILE_se	
    	  $flag eq "73-133"  ||     # F*	   
    	  $flag eq "117-185" ||	    # *R
    	  $flag eq "121-181" 	    # R*	# FILE_se
    	){
	    printf(FILE_sam "%s%s", $jline[0],$jline[1]);
	    if($flag=~/185/){$sq2= &invert_sq($sq2);}
	    if($flag=~/121/){$sq1= &invert_sq($sq1);}
	    printf(FILE_R1 "@%s\n%s\n+\n%s\n", $hd1,$sq1,$mq1);
	    printf(FILE_R2 "@%s\n%s\n+\n%s\n", $hd2,$sq2,$mq2);
        }
        elsif($cig1 eq "*" || $cig2 eq "*"){	# FILE_se, for iregullar flag expression
	    printf(FILE_sam "%s%s", $jline[0],$jline[1]);
	    printf(FILE_R1 "@%s\n%s\n+\n%s\n", $hd1,$sq1,$mq1);
	    printf(FILE_R2 "@%s\n%s\n+\n%s\n", $hd2,$sq2,$mq2);
        }
        elsif($flag eq "65-129" ||  # FF
    	  $flag eq "67-131"	    # FF	# FILE_ff
    	){
	    printf(FILE_sam "%s%s", $jline[0],$jline[1]);
	    printf(FILE_R1 "@%s\n%s\n+\n%s\n", $hd1,$sq1,$mq1);
	    printf(FILE_R2 "@%s\n%s\n+\n%s\n", $hd2,$sq2,$mq2);
        }
        elsif($flag eq "113-177" || # RR
    	  $flag eq "115-179"	    # RR	# FILE_rr
    	){
	printf(FILE_sam "%s%s", $jline[0],$jline[1]);
	    $sq1= &invert_sq($sq1);
	    $sq2= &invert_sq($sq2);
	    printf(FILE_R1 "@%s\n%s\n+\n%s\n", $hd1,$sq1,$mq1);
	    printf(FILE_R2 "@%s\n%s\n+\n%s\n", $hd2,$sq2,$mq2);
        }
        elsif($flag eq "83-163" || # RF
    	  $flag eq "99-147" ||     # FR
    	  $flag eq "81-161" ||     # RF
    	  $flag eq "97-145"	   # FR
    	){
    	if($flag2 == 161 || $flag2 == 163){
	    $sq1= &invert_sq($sq1);
    	    if($min <= $ins2 && $ins2 <= $max){
	     if($as1[2]<$asMn || $as2[2]<$asMn  ||  $jline[0]=~"SA:Z" || $jline[1]=~"SA:Z"){	# FILE_fr_y
		printf(FILE_sam "%s%s", $jline[0],$jline[1]);
	    	printf(FILE_R1 "@%s\n%s\n+\n%s\n", $hd1,$sq1,$mq1);
	    	printf(FILE_R2 "@%s\n%s\n+\n%s\n", $hd2,$sq2,$mq2);
	      }
    	    }		    
    	    elsif($len <= $ins2){	# FILE_fr_n
		printf(FILE_sam "%s%s", $jline[0],$jline[1]);
	    	printf(FILE_R1 "@%s\n%s\n+\n%s\n", $hd1,$sq1,$mq1);
	    	printf(FILE_R2 "@%s\n%s\n+\n%s\n", $hd2,$sq2,$mq2);
    	    }
    	    else{			# FILE_rf
		printf(FILE_sam "%s%s", $jline[0],$jline[1]);
	    	printf(FILE_R1 "@%s\n%s\n+\n%s\n", $hd1,$sq1,$mq1);
	    	printf(FILE_R2 "@%s\n%s\n+\n%s\n", $hd2,$sq2,$mq2);
    	    }
    	}
    	elsif($flag1 == 97 || $flag1 == 99){
	    $sq2= &invert_sq($sq2);
    	    if($min <= $ins1 && $ins1 <= $max){
	      if($as1[2]<$asMn || $as2[2]<$asMn  ||  $jline[0]=~"SA:Z" || $jline[1]=~"SA:Z"){	# FILE_fr_y
		printf(FILE_sam "%s%s", $jline[0],$jline[1]);
	    	printf(FILE_R1 "@%s\n%s\n+\n%s\n", $hd1,$sq1,$mq1); 
	    	printf(FILE_R2 "@%s\n%s\n+\n%s\n", $hd2,$sq2,$mq2); 
	      }
    	    }		    
    	    elsif($len <= $ins1){	# FILE_fr_n
		printf(FILE_sam "%s%s", $jline[0],$jline[1]);
	    	printf(FILE_R1 "@%s\n%s\n+\n%s\n", $hd1,$sq1,$mq1);
	    	printf(FILE_R2 "@%s\n%s\n+\n%s\n", $hd2,$sq2,$mq2);
    	    }
    	    else{			# FILE_rf
		printf(FILE_sam "%s%s", $jline[0],$jline[1]);
	    	printf(FILE_R1 "@%s\n%s\n+\n%s\n", $hd1,$sq1,$mq1);
	    	printf(FILE_R2 "@%s\n%s\n+\n%s\n", $hd2,$sq2,$mq2);
    	    }
    	}
    	else{
    	    printf(STDOUT "3\t%s", $line1);
    	    printf(STDOUT "3\t%s", $line2);
    	}
        }
        else{
    	printf(STDOUT "2\t%s", $line1);
    	printf(STDOUT "2\t%s", $line2);
        }
    }
    else{	# FILE_tr
	printf(FILE_sam "%s%s", $jline[0],$jline[1]);
	if($flag=~/81/  || $flag=~/113/){$sq1= &invert_sq($sq1);}
	if($flag=~/145/ || $flag=~/177/){$sq2= &invert_sq($sq2);}
	printf(FILE_R1 "@%s\n%s\n+\n%s\n", $hd1,$sq1,$mq1);
	printf(FILE_R2 "@%s\n%s\n+\n%s\n", $hd2,$sq2,$mq2);
    }
}

close(FILE);
close(FILE_R1);
close(FILE_R2);
close(FILE_sam);
