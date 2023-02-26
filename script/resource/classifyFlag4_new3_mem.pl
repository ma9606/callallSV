#! /usr/bin/perl
# modifyed by M.Adachi on 160106, for detectGR_list ver.2 
# 1. Check SAMflag(only use top hit of bwa-mem mapping output), 
# 2. Modify malformat , and 
# 3. Discard non-regular contig
# 4. Check uniformity of read length among samfiles
#
# modifyed by M.Adachi on 180320
# exclude "chrM" from @tar_contig

@tar_contig = {"chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chr20","chr21","chr22","chrX","chrY"};

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
    $mdf_line ="";
    if($col[2]/1!=0||$col[2]=~/[X-Y,M]/){
	if($col[2] eq "MT" || $col[6] eq "MT"){
	    return -1;
	}
	elsif($col[6] eq "="){
	    $mdf_line = $col[0]."\t".$col[1]."\tchr".$col[2]."\t".$col[3]."\t".$col[4]."\t".$col[5]."\t".$col[6];
	    for($i=7;$i<$#col;$i++){$mdf_line .= "\t".$col[$i];} $mdf_line .= "\t".$col[$#col];
	    return $mdf_line;
	}
	elsif($col[6]/1!=0||$col[6]=~/[X-Y]/){
	    $mdf_line = $col[0]."\t".$col[1]."\tchr".$col[2]."\t".$col[3]."\t".$col[4]."\t".$col[5]."\tchr".$col[6];
	    for($i=7;$i<$#col;$i++){$mdf_line .= "\t".$col[$i];} $mdf_line .= "\t".$col[$#col];
	    return $mdf_line;
	}
	else { return -1; }
    }
}


# open(FILE_um, "> $fileid.cla.um") || die "Can not open file $fileid.cla.um: $!\n";
# open(FILE_se, "> $fileid.cla.se") || die "Can not open file $fileid.cla.se: $!\n";
# open(FILE_fr_y, "> $fileid.cla.fr_y") || die "Can not open file $fileid.cla.fr_y: $!\n";
open(FILE_ff, "> $fileid.cla.ff") || die "Can not open file $fileid.cla.ff: $!\n";
open(FILE_rr, "> $fileid.cla.rr") || die "Can not open file $fileid.cla.rr: $!\n";
open(FILE_fr_n, "> $fileid.cla.fr_n") || die "Can not open file $fileid.cla.fr_n: $!\n";
open(FILE_rf, "> $fileid.cla.rf") || die "Can not open file $fileid.cla.rf: $!\n";
open(FILE_tr, "> $fileid.cla.tr") || die "Can not open file $fileid.cla.tr: $!\n";


open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line[0] = <FILE>){
    if($line[0] !~ /^@/){	

	@column0 = split(/\t/, $line[0]);  
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

	if($wdir[$#wdir] eq "tumor"){$FORMAT_READ_LEN = $READ_LEN_CONF;} elsif($wdir[$#wdir] eq "normal"){$FORMAT_READ_LEN = $READ_LEN_N;} 
#	if(length($column0[9])!=$FORMAT_READ_LEN){
#	    open(FILE_err, "> classifyFlag3_non-uniformity_READLEN.err");
#	    printf(FILE_err  "___ %s\n", $line[0]);
#	    printf(FILE_err "all SAM-formated input files are required uniformity in read length.\n");
#	    printf(FILE_err "%d [.rearrangement.conf] != %d [%s]   %s\n", $FORMAT_READ_LEN, length($column0[9]), $fileid, $line[0]);
#	    close(FILE_err);
#	    exit -1;
#	}
	$len = $min = $FORMAT_READ_LEN;

	$flg0=0; for($i=0;$i<=$#tar_contig;$i++){ if($column0[2] eq $tar_contig[$i]){$flg0=1; last;}}
	if($flg0==0){ $ret0 = &modifySamFormat(@column0); if($ret0 >= 0){$line[0] = $ret0;}} 
	$flg1=0; for($i=0;$i<=$#tar_contig;$i++){ if($column1[2] eq $tar_contig[$i]){$flg1=1; last;}}
	if($flg1==0){ $ret1 = &modifySamFormat(@column1); if($ret1 >= 0){$line[1] = $ret1;}} 

	if(((length($ret0)>0 && length($ret1)>0)||($flg0>0 && $flg1>0)) && 
	   ($column0[2] ne "MT" && $column0[6] ne "MT" && $column1[2] ne "MT" && $column1[6] ne "MT")){ judge_SAMflag_pair(@line); }
    }
}


sub judge_SAMflag_pair{

    my (@jline) = @_;
    @list1 = split(/\t/, $jline[0]);
    @list2 = split(/\t/, $jline[1]);
    $line1 = $jline[0];
    $line2 = $jline[1];

    if($list1[1] <= $list2[1]){
        $flag1 = $list1[1];
        $cig1 = $list1[5];
        $chr1 = $list1[6];
        $ins1 = $list1[8];
        $flag2 = $list2[1];
        $cig2 = $list2[5];
        $chr2 = $list2[6];
        $ins2 = $list2[8];
    }
    else{
        $flag1 = $list2[1];
        $cig1 = $list2[5];
        $chr1 = $list2[6];
        $ins1 = $list2[8];
        $flag2 = $list1[1];
        $cig2 = $list1[5];
        $chr2 = $list1[6];
        $ins2 = $list1[8];
    }

    $flag = $flag1 . "-" . $flag2;

    if($chr1 eq "*" && $chr2 eq "*"){
#      printf(FILE_um "%s", $line1);
#      printf(FILE_um "%s", $line2);
    }
    elsif($chr1 eq "=" && $chr2 eq "="){
        if($cig1 eq "*" || $cig2 eq "*"){
#   	printf(FILE_se "%s", $line1);
#   	printf(FILE_se "%s", $line2);
        }
        elsif($flag eq "69-137" ||
    	  $flag eq "73-133" ||
    	  $flag eq "121-181" ||
    	  $flag eq "117-185"
    	){
#   	printf(FILE_se "%s", $line1);
#   	printf(FILE_se "%s", $line2);
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
#		printf(FILE_fr_y "%s", $line1);
#		printf(FILE_fr_y "%s", $line2);
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
#		printf(FILE_fr_y "%s", $line1);
#		printf(FILE_fr_y "%s", $line2);
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
        printf(FILE_tr "%s", $line1);
        printf(FILE_tr "%s", $line2);
    }
}

close(FILE);

# close(FILE_um);
# close(FILE_se);
# close(FILE_fr_y);
close(FILE_ff);
close(FILE_rr);
close(FILE_fr_n);
close(FILE_rf);
close(FILE_tr);
