#! /usr/bin/perl

if($#ARGV != 3){
    printf STDERR "usage: $#ARGV $0 [sam file] [read length] [min. insert] [max. insert]\n";
    exit -1;
}
$filename = $ARGV[0];
$len = $ARGV[1];
$min = $ARGV[2];
$max = $ARGV[3];

$MAX_CERR = $len * 0.30;   # maxNo.baseCallError less than 30% of lead length
$MAX_NM =   $len * 0.03;   # maxNo.mismatch less than 3% of read length
$MIN_AS =   $len * 0.80;   # minAlignementScore is 80% of full scrore(=read length)

open(FILE_um, "> $filename.cla.um") || die "Can not open file $filename.cla.um: $!\n";
open(FILE_se, "> $filename.cla.se") || die "Can not open file $filename.cla.se: $!\n";
open(FILE_fr_y, "> $filename.cla.fr_y") || die "Can not open file $filename.cla.fr_y: $!\n";
open(FILE_ff, "> $filename.cla.ff") || die "Can not open file $filename.cla.ff: $!\n";
open(FILE_rr, "> $filename.cla.rr") || die "Can not open file $filename.cla.rr: $!\n";
open(FILE_fr_n, "> $filename.cla.fr_n") || die "Can not open file $filename.cla.fr_n: $!\n";
open(FILE_rf, "> $filename.cla.rf") || die "Can not open file $filename.cla.rf: $!\n";
open(FILE_tr, "> $filename.cla.tr") || die "Can not open file $filename.cla.tr: $!\n";

open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line1 = <FILE>){
    if($line1 !~ /^@/){
	@list1 = split(/\t/, $line1); if($list1[1]>=2000 || $#list1>16){next;}
	REGET_L2:;
	$line2 = <FILE>;
	@list2 = split(/\t/, $line2); if($list2[1]>=2000 || $#list2>16){goto REGET_L2;}
	while($list1[0] ne $list2[0]){
	    $line1 = $line2;
	    @list1 = split(/\t/, $line1);
	    $line2 = <FILE>;
	    @list2 = split(/\t/, $line2);
	}
	if($list1[1] <= $list2[1]){
	    $flag1 = $list1[1];		$flag2 = $list2[1];
	    $cig1 = $list1[5];		$cig2 = $list2[5];
	    $chr1 = $list1[6];		$chr2 = $list2[6];
	    $ins1 = $list1[8];		$ins2 = $list2[8];
	    # No. Base Call Error(#)
	    @cnt = split(/#/,$list1[10]."_"); $ce1 = $#cnt;	@cnt = split(/#/,$list2[10]); $ce2 = $#cnt;
	    # No. Mismatch
	    @mn_ = split(/:/,$list1[11]); $mn1  = $mn_[2];	@mn_ = split(/:/,$list2[11]); $mn2  = $mn_[2];
	    # Alignment Score
	    @as_ = split(/:/,$list1[13]); $as1  = $as_[2];	@as_ = split(/:/,$list2[13]); $as2  = $as_[2];
	}
	else{
	    $flag1 = $list2[1];		$flag2 = $list1[1];
	    $cig1 = $list2[5];		$cig2 = $list1[5];
	    $chr1 = $list2[6];		$chr2 = $list1[6];
	    $ins1 = $list2[8];		$ins2 = $list1[8];
	    @cnt = split(/#/,$list2[10]."_"); $ce1 = $#cnt;	@cnt = split(/#/,$list1[10]); $ce2 = $#cnt;
	    @mn_ = split(/:/,$list2[11]); $mn1 = $mn_[2];	@mn_ = split(/:/,$list1[11]); $mn2 = $mn_[2];
	    @as_ = split(/:/,$list2[13]); $as1 = $as_[2];	@as_ = split(/:/,$list1[13]); $as2 = $as_[2];
	}
	if(($ce1>=$MAX_CERR && $mn1>$MAX_NM && $as1<$MIN_AS) || ($ce2>=$MAX_CERR && $mn2>$MAX_NM && $as2<$MIN_AS)){
	    if(($ce1>=$MAX_CERR && $mn1>$MAX_NM && $as1<$MIN_AS)&&($ce2>=$MAX_CERR && $mn2>$MAX_NM && $as2<$MIN_AS)){ $chr1 = "*"; $chr2 = "*"; }
	    elsif($ce1>=$MAX_CERR && $mn1>$MAX_NM && $as1<$MIN_AS){ $chr1 = "*"; $flag = 121 . "-" . 181; }
	    elsif($ce2>=$MAX_CERR && $mn2>$MAX_NM && $as2<$MIN_AS){ $chr2 = "*"; $flag = 117 . "-" . 185; }
	}
	else{
	    $flag = $flag1 . "-" . $flag2;
	}


	if($chr1 eq "*" && $chr2 eq "*"){
	    printf(FILE_um "%s", $line1);
	    printf(FILE_um "%s", $line2);
	}
	elsif($chr1 eq "=" && $chr2 eq "="){
	    if($cig1 eq "*" || $cig2 eq "*"){
		printf(FILE_se "%s", $line1);
		printf(FILE_se "%s", $line2);
	    }
	    elsif($flag eq "69-137" ||
		  $flag eq "73-133" ||
		  $flag eq "121-181" ||
		  $flag eq "117-185"
		){
		printf(FILE_se "%s", $line1);
		printf(FILE_se "%s", $line2);
	    }
	    elsif($flag eq "65-129" ||
		  $flag eq "67-131"
		){
		printf(FILE_ff "%s", $line1);
		printf(FILE_ff "%s", $line2);
	    }
	    elsif($flag eq "113-177" ||
		  $flag eq "115-179"
		){
		printf(FILE_rr "%s", $line1);
		printf(FILE_rr "%s", $line2);
	    }
	    elsif($flag eq "83-163" ||
		  $flag eq "99-147" ||
		  $flag eq "81-161" ||
		  $flag eq "97-145"
		){
		if($flag2 == 161 || $flag2 == 163){
		    if($min <= $ins2 && $ins2 <= $max){
			printf(FILE_fr_y "%s", $line1);
			printf(FILE_fr_y "%s", $line2);
		    }		    
		    elsif($len <= $ins2){
			printf(FILE_fr_n "%s", $line1);
			printf(FILE_fr_n "%s", $line2);
		    }
		    else{
			printf(FILE_rf "%s", $line1);
			printf(FILE_rf "%s", $line2);
		    }
		}
		elsif($flag1 == 97 || $flag1 == 99){
		    if($min <= $ins1 && $ins1 <= $max){
			printf(FILE_fr_y "%s", $line1);
			printf(FILE_fr_y "%s", $line2);
		    }		    
		    elsif($len <= $ins1){
			printf(FILE_fr_n "%s", $line1);
			printf(FILE_fr_n "%s", $line2);
		    }
		    else{
			printf(FILE_rf "%s", $line1);
			printf(FILE_rf "%s", $line2);
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
	else{
	    if($flag eq "121-181" || $flag eq "117-185"){
	    	printf(FILE_se "%s", $line1);
	    	printf(FILE_se "%s", $line2);
	    }
	    else{
	    	printf(FILE_tr "%s", $line1);
	    	printf(FILE_tr "%s", $line2);
	    }
	}
    }
}
close(FILE);

close(FILE_um);
close(FILE_se);
close(FILE_fr_y);
close(FILE_ff);
close(FILE_rr);
close(FILE_fr_n);
close(FILE_rf);
close(FILE_tr);
