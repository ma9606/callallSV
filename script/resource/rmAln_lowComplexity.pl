#! /usr/bin/perl

if($#ARGV < 2){
    printf STDERR "usage: $0 [iBPlist-RpMasker.iBout] [intraBP.list_0] [read_length]\n";
    exit -1;
}

$MIN_ALNLEN  = 25;	# The softclip whose algnment length under $MIN_ALNLEN, isnot reliable
$MIN_CLSIZE  = 20;
$MIN_CLMEMB  =  3;
$MAX_RATIO = 0.75;			$MAX_RATIO_TR = 0.50;	# mean overlap-rate between softclip-alignment and repeat assigned region
$MAX_OVLSQ   = 30;			$MAX_OVLSQ_TR   = 25;
$MAX_ITRSQ   = ($ARGV[2]-$MIN_ALNLEN*2);	$MAX_ITRSQ_TR   = 20;

@TAR_RPFAM = ("Simple_repeat", "Satellite", "Low_complexity");


## Parsing .iBout and extract filter target and store their crds. into @list
open(FILE, $ARGV[0]) || die "Can not open file $ARGV[0]: $!\n";
@ch = @crd = @crd_0 = @evnt =();
while($line = <FILE>){
    @column = split(/\t/, $line);
#   $column[0]	chr1
#   $column[1]  726170
#   $column[2]  726219
#   $column[3]  _#/#_
#   $column[4]  NoRead,ol/ir_seq,MQ	[NoRead<=3] __(1)
#   $column[5]  clusterSize  		[<30]       __(2)
# ---
#   $column[6]  chrRp 
#   $column[7]  repeatSt
#   $column[8]  repearEn
#   $column[9]  Rp_family 		[tar: Simple_repeat/Satellite/Low_complexity] __(3a)
#   $column[10]  Rp_name, strand
#   $column[11]  No.ol

    $flg=0;
    $ratio = $column[11]/$column[5];	# [ratio >0.50]__(3b)
    @note = split(/, /, $column[4]);
    
    if($note[1] =~/translocation/){
	if($note[0]<=$MIN_CLMEMB && $ratio>=$MAX_RATIO_TR){ 
	    for($i=0;$i<=$#TAR_RPFAM;$i++){if($TAR_RPFAM[$i] =~ $column[9] && $note[$#note]< 60){$flg++;}} 
	    if($note[2]=~/interruption:/ && length($note[2])-13 >=$MAX_ITRSQ_TR && $note[$#note]<=10){$flg++; }
	    if($note[2]=~/overlap:/      && length($note[2])-8  >=$MAX_OVLSQ    && $note[$#note]<=10){$flg++; }
#	    for($i=0;$i<=$#TAR_RPFAM;$i++){if($TAR_RPFAM[$i] =~ $column[9] && $note[$#note]<60){print "_1__$TAR_RPFAM[$i],$note[$#note],$line";  $flg++;}} 
#	    if($note[2]=~/interruption:/ && length($note[2])-13 >=$MAX_ITRSQ_TR && $note[$#note]<=10){print "_2__$note[2],$line";  $flg++; }
#	    if($note[2]=~/overlap:/      && length($note[2])-8  >=$MAX_OVLSQ && $note[$#note]<=10){print "_3__$note[2],$line";  $flg++; }
#	    if($note[$#note]==0){print "_4__$note[$#note],$line";  $flg++; }
    	}
    }
    else {
	if($note[0]<=$MIN_CLMEMB && $ratio>=$MAX_RATIO){ 
	    for($i=0;$i<=$#TAR_RPFAM;$i++){if($TAR_RPFAM[$i] =~ $column[9]   && $note[$#note]< 60){$flg++;}} 
	    if($note[2]=~/interruption:/ && length($note[2])-13 >=$MAX_ITRSQ && $note[$#note]<=10){$flg++;}
#	    if($note[2]=~/overlap:/      && length($note[2])-8 >=$MAX_OVLSQ ){print "_3__$note[2],$MAX_OVLSQ,$line"; $flg++;}
    	}
    }

    if($flg!=0){
	    push(@ch, $column[0]);
	    if($column[3] eq "_#"){push(@crd, $column[2]); push(@crd_0, $column[1]);}  
	    else{		   push(@crd, $column[1]); push(@crd_0, $column[2]);}
	    push(@evnt, $note[1]);
    }
}
# for($i=0;$i<=$#crd;$i++){print "$i,  $ch[$i], $crd[$i],  $crd_0[$i], $evnt[$i]\n";}   exit;

for($i=0;$i<=$#crd;$i++){push(@flag,0);}
@idxSt =(); @idxEn =();
@chrom =("chrY","chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10",
	 "chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chr20","chr21","chr22","chrX"); 
$tmpCh=""; 
for($i=0;$i<=$#crd;$i++){ 
    if($tmpCh ne $ch[$i]){for($j=0;$j<=$#chrom;$j++){
	if($ch[$i] eq $chrom[$j]){$idxSt[$j]=$i;}
	if($tmpCh  eq $chrom[$j]){$idxEn[$j]=$i-1;}
    }}
    $tmpCh = $ch[$i];
} $idxEn[0] = $#crd;

# print "$#idxSt, $#idxEn\n"; 
# for($i=0;$i<=$#idxSt;$i++){print "$i:   $idxSt[$i],  $idxEn[$i]\n";} exit;


open(FILE, $ARGV[1]) || die "Can not open file $ARGV[1]: $!\n";
while($line = <FILE>){
    @column = split(/\s+/, $line);
#   $column[0]	chr[_]
#   $column[1]  left_edge
#   $column[2]  ==>
#   $column[3]  bp_L
#   $column[4]  |
#   $column[5]  bp_R
#   $column[6]  <== 
#   $column[7]  right_edge
#   $column[8]  chr[_] 
#   $column[9]  No.reads
#   $column[10]  event[del/inv/tdm/trns]
    $flg=0;

    if($column[0] ne $column[8]){	# case: traslocation
	for($i=0;$i<=$#chrom;$i++){
	    if($column[0] eq $chrom[$i]){for($j=$idxSt[$i];$j<=$idxEn[$i];$j++){if($column[3]==$crd[$j] && $column[1]==$crd_0[$j] && $column[9]<=$MIN_CLMEMB){$flg++; $flag[$j]++;}}}
	    if($column[8] eq $chrom[$i]){for($j=$idxSt[$i];$j<=$idxEn[$i];$j++){if($column[5]==$crd[$j] && $column[7]==$crd_0[$j] && $column[9]<=$MIN_CLMEMB){$flg++; $flag[$j]++;}}}
	}
    }
    else{				# case: deletion, tandem_duplication, inversion
    	for($i=0;$i<=$#chrom;$i++){if($column[0] eq $chrom[$i]){
	    for($j=$idxSt[$i];$j<=$idxEn[$i];$j++){
		if($column[3]==$crd[$j] && $column[1]==$crd_0[$j] && $column[10] eq $evnt[$j] && $column[9]<=$MIN_CLMEMB){$flg++; $flag[$j]++;}
		if($column[5]==$crd[$j] && $column[7]==$crd_0[$j] && $column[10] eq $evnt[$j] && $column[9]<=$MIN_CLMEMB){$flg++; $flag[$j]++;}
	    }
    	}}
    }
    if($flg==0){print $line;}
}
# for($i=0;$i<=$#crd;$i++){print "$flag[$i]\t$ch[$i], $crd[$i], $evnt[$i]\n";}
