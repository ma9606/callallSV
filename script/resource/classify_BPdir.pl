#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [chim.list] [out.dir]\n";
    printf STDERR "   ex) cd [smplID]/normal; ls */*.chim > .chimN.list; $0 .chimN.list tmpNout\n";
    printf STDERR "   ex) cd [smplID]/tumor;  ls */*.chim > .chimT.list; $0 .chimT.list tmpTout\n";
    exit -1;
}
$listname  = $ARGV[0];
$outdir    = $ARGV[1];

$curdir = `pwd`; chomp $curdir;
system("mkdir -p $curdir/$outdir\0");
system("cd $curdir/$outdir; mkdir -p HT/ HH/ TT/ trHT/ trHH/ trTT/; cd $curdir\0");

open(FILE_ht, "> ${outdir}/HT/.tmp.chim") || die "Can not open file ${outdir}/HT/.tmp.chim: $!\n";
open(FILE_hh, "> ${outdir}/HH/.tmp.chim") || die "Can not open file ${outdir}/HH/.tmp.chim: $!\n";
open(FILE_tt, "> ${outdir}/TT/.tmp.chim") || die "Can not open file ${outdir}/TT/.tmp.chim: $!\n";

open(FILE_tr_ht, "> ${outdir}/trHT/.tmp.chim") || die "Can not open file ${outdir}/trHT/.tmp.chim: $!\n";
open(FILE_tr_hh, "> ${outdir}/trHH/.tmp.chim") || die "Can not open file ${outdir}/trHH/.tmp.chim: $!\n";
open(FILE_tr_tt, "> ${outdir}/trTT/.tmp.chim") || die "Can not open file ${outdir}/trTT/.tmp.chim: $!\n";

open(LIST, $listname) || die "Can not open file $listame: $!\n";
while($filename = <LIST>){
    open(FILE, $filename) || die "Can not open file $filename: $!\n";

    while($line = <FILE>){
	@column = split(/\s+/, $line);
	$ch1 = $column[0]; $ch1 =~ s/chr//;
	$ch2 = $column[8]; $ch2 =~ s/chr//;

	if( (($column[2] =~ />/ && $column[6] =~ /</)  || ($column[2] =~ /</ && $column[6] =~ />/)) &&    		# incase joint HH[--><--] or TT[<--||-->]
	    (($column[0] ne $column[8] && $ch1 > $ch2) || ($column[0] eq $column[8] && $column[3] > $column[5])) ) 	# reassign as : chr_M crd_M  | crd_m chr_m  (M>m)
	{
	    @tmp = (); 
	    $tmp[0] = $column[0];  $column[0] = $column[8];  $column[8] = $tmp[0];
	    $tmp[1] = $column[1];  $column[1] = $column[7];  $column[7] = $tmp[1];

	    $tmpN2 = $column[2]; $tmpN2 =~ s/^.*?(\d+).*$/$1/;
    	    $tmpN6 = $column[6]; $tmpN6 =~ s/^.*?(\d+).*$/$1/;
    	    if($column[2] =~ />/){
            	$column[2] = "--".$tmpN6."M->";
            	$column[6] = "<-".$tmpN2."M--";
    	    } 
    	    else{
            	$column[2] = "<-".$tmpN6."M--";
            	$column[6] = "--".$tmpN2."M->";
    	    }
	    $tmp[3] = $column[3];  $column[3] = $column[5];  $column[5] = $tmp[3];

	    @nSeq = @cSeq =();  @nSeq = split(//,$column[10]);	# nSeq:orginal_nucleotide_seq., cSeq: complementary nucleotide_seq.  
	    for($i=$#nSeq;$i>=0;$i--){
		if(   $nSeq[$i] eq "a"){ push(@cSeq, "t"); }  elsif($nSeq[$i] eq "A"){ push(@cSeq, "T"); }
		elsif($nSeq[$i] eq "g"){ push(@cSeq, "c"); }  elsif($nSeq[$i] eq "G"){ push(@cSeq, "C"); }
		elsif($nSeq[$i] eq "c"){ push(@cSeq, "g"); }  elsif($nSeq[$i] eq "C"){ push(@cSeq, "G"); }
		elsif($nSeq[$i] eq "t"){ push(@cSeq, "a"); }  elsif($nSeq[$i] eq "T"){ push(@cSeq, "A"); }
		else { 			 push(@cSeq, $nSeq[$i]); }
	    }
	    $tmpseq=""; for($i=0;$i<=$#cSeq;$i++){$tmpseq .= $cSeq[$i];}  $column[10] = $tmpseq;

	   if($#column>=13){
	    @nSeq = @cSeq =();  @nSeq = split(//,$column[12]);
	    for($i=$#nSeq;$i>=0;$i--){
		if(   $nSeq[$i] eq "a"){ push(@cSeq, "t"); }  elsif($nSeq[$i] eq "A"){ push(@cSeq, "T"); }
		elsif($nSeq[$i] eq "g"){ push(@cSeq, "c"); }  elsif($nSeq[$i] eq "G"){ push(@cSeq, "C"); }
		elsif($nSeq[$i] eq "c"){ push(@cSeq, "g"); }  elsif($nSeq[$i] eq "C"){ push(@cSeq, "G"); }
		elsif($nSeq[$i] eq "t"){ push(@cSeq, "a"); }  elsif($nSeq[$i] eq "T"){ push(@cSeq, "A"); }
		else { 			 push(@cSeq, $nSeq[$i]); }
	    }
	    $tmpseq=""; for($i=0;$i<=$#cSeq;$i++){$tmpseq .= $cSeq[$i];}  $column[12] = $tmpseq;
	    @tmpsc=(); @tmpsc = split(/-/, $column[13]);  $column[13] = $tmpsc[1]."-".$tmpsc[0];
	    if($#column==14){
	    @tmpsc=(); @tmpsc = split(/-/, $column[14]);  $column[14] = $tmpsc[1]."-".$tmpsc[0];
	    }
	   }
	}

	$line = $column[0]."\t".$column[1]." ".$column[2]." ".$column[3]."\t|\t".$column[5]." ".$column[6]." ".$column[7]."\t".$column[8]."\t".$column[9]."\t".$column[10];
	if(   $#column==13){ $line .= "\t".$column[11]." ".$column[12]."\t".$column[13]."\n";}
	elsif($#column==14){ $line .= "\t".$column[11]." ".$column[12]."\t".$column[13]."\t".$column[14]."\n";}
	else {		  $line .= "\t".$column[11]."\t".$column[12]."\n";}

	if($column[0] eq $column[8]){
	    if($column[2] =~ ">" && $column[6] =~ ">"){ printf(FILE_ht "%s", $line); }
	    if($column[2] =~ ">" && $column[6] =~ "<"){ printf(FILE_hh "%s", $line); }
	    if($column[2] =~ "<" && $column[6] =~ ">"){ printf(FILE_tt "%s", $line); }
	}
	else {
	    if($column[2] =~ ">" && $column[6] =~ ">"){ printf(FILE_tr_ht "%s", $line); }
	    if($column[2] =~ ">" && $column[6] =~ "<"){ printf(FILE_tr_hh "%s", $line); }
	    if($column[2] =~ "<" && $column[6] =~ ">"){ printf(FILE_tr_tt "%s", $line); }
	}
    }
}
close(FILE);

close(FILE_ht);
close(FILE_hh);
close(FILE_tt);
close(FILE_tr_ht);
close(FILE_tr_hh);
close(FILE_tr_tt);

my @tmpDIR = ("HT","HH","TT","trHT","trHH","trTT");
my @chID   = ("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y");

for($i=0;$i<=$#tmpDIR;$i++){
    $dir = $curdir."/".$outdir."/".$tmpDIR[$i];
    system("cd $dir;");
    for($j=0;$j<=$#chID;$j++){
	$chFILE[$j] = "FILE_chr".$chID[$j]; $c = $chID[$j];
	open($chFILE[$j], "> ${dir}/.chr${c}.chim"); 
    }

    open(FILE, "$dir/.tmp.chim") || die "Can not open file $dir/.tmp.chim $!\n";
    while($line = <FILE>){
	@column = split(/\s+/,$line);
	if($column[0] eq "chr1"){printf(FILE_chr1 "%s", $line);}
	if($column[0] eq "chr2"){printf(FILE_chr2 "%s", $line);}
	if($column[0] eq "chr3"){printf(FILE_chr3 "%s", $line);}
	if($column[0] eq "chr4"){printf(FILE_chr4 "%s", $line);}
	if($column[0] eq "chr5"){printf(FILE_chr5 "%s", $line);}
	if($column[0] eq "chr6"){printf(FILE_chr6 "%s", $line);}
	if($column[0] eq "chr7"){printf(FILE_chr7 "%s", $line);}
	if($column[0] eq "chr8"){printf(FILE_chr8 "%s", $line);}
	if($column[0] eq "chr9"){printf(FILE_chr9 "%s", $line);}
	if($column[0] eq "chr10"){printf(FILE_chr10 "%s", $line);}
	if($column[0] eq "chr11"){printf(FILE_chr11 "%s", $line);}
	if($column[0] eq "chr12"){printf(FILE_chr12 "%s", $line);}
	if($column[0] eq "chr13"){printf(FILE_chr13 "%s", $line);}
	if($column[0] eq "chr14"){printf(FILE_chr14 "%s", $line);}
	if($column[0] eq "chr15"){printf(FILE_chr15 "%s", $line);}
	if($column[0] eq "chr16"){printf(FILE_chr16 "%s", $line);}
	if($column[0] eq "chr17"){printf(FILE_chr17 "%s", $line);}
	if($column[0] eq "chr18"){printf(FILE_chr18 "%s", $line);}
	if($column[0] eq "chr19"){printf(FILE_chr19 "%s", $line);}
	if($column[0] eq "chr20"){printf(FILE_chr20 "%s", $line);}
	if($column[0] eq "chr21"){printf(FILE_chr21 "%s", $line);}
	if($column[0] eq "chr22"){printf(FILE_chr22 "%s", $line);}
	if($column[0] eq "chrX"){printf(FILE_chrX "%s", $line);}
	if($column[0] eq "chrY"){printf(FILE_chrY "%s", $line);}

    }
    close(FILE_chr1);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr1.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - >  ${dir}/chr1.BP_list_0;");
    close(FILE_chr2);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr2.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - >  ${dir}/chr2.BP_list_0;");
    close(FILE_chr3);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr3.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - >  ${dir}/chr3.BP_list_0;");
    close(FILE_chr4);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr4.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - >  ${dir}/chr4.BP_list_0;");
    close(FILE_chr5);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr5.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - >  ${dir}/chr5.BP_list_0;");
    close(FILE_chr6);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr6.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - >  ${dir}/chr6.BP_list_0;");
    close(FILE_chr7);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr7.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - >  ${dir}/chr7.BP_list_0;");
    close(FILE_chr8);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr8.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - >  ${dir}/chr8.BP_list_0;");
    close(FILE_chr9);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr9.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - >  ${dir}/chr9.BP_list_0;");
    close(FILE_chr10);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr10.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - > ${dir}/chr10.BP_list_0;");
    close(FILE_chr11);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr11.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - > ${dir}/chr11.BP_list_0;");
    close(FILE_chr12);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr12.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - > ${dir}/chr12.BP_list_0;");
    close(FILE_chr13);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr13.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - > ${dir}/chr13.BP_list_0;");
    close(FILE_chr14);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr14.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - > ${dir}/chr14.BP_list_0;");
    close(FILE_chr15);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr15.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - > ${dir}/chr15.BP_list_0;");
    close(FILE_chr16);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr16.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - > ${dir}/chr16.BP_list_0;");
    close(FILE_chr17);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr17.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - > ${dir}/chr17.BP_list_0;");
    close(FILE_chr18);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr18.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - > ${dir}/chr18.BP_list_0;");
    close(FILE_chr19);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr19.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - > ${dir}/chr19.BP_list_0;");
    close(FILE_chr20);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr20.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - > ${dir}/chr20.BP_list_0;");
    close(FILE_chr21);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr21.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - > ${dir}/chr21.BP_list_0;");
    close(FILE_chr22);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chr22.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - > ${dir}/chr22.BP_list_0;");
    close(FILE_chrX);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chrX.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - >  ${dir}/chrX.BP_list_0;");
    close(FILE_chrY);	system("sort -k4,4n -k6,6n -k13,13 ${dir}/.chrY.chim | awk -f ./.judge_cluster.awk - | sort -k10,10nr | ./rm_minorAln.pl - >  ${dir}/chrY.BP_list_0;");
}
close(FILE);
