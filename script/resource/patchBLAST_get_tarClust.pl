#! /usr/bin/perl

if($#ARGV < 0){
    printf STDERR "usage: $0 [file]\n";
    exit -1;
}
$flgF=0;

open(FILE, $ARGV[0]) || die "Can not open file $ARGV[0]: $!\n";
while($line = <FILE>){
    @column = split(/\t/, $line);
    $dr    = $column[2];
    $event = $column[4];
    $supR  = $column[5];  $clmem_line = "Cluster Member: ".$supR;
    $chL= $column[6];	$clL = $column[7];   
    $chR= $column[11];	$clR = $column[12];

if($flgF==0){
    if($event eq "deletion"){
	open(CL,  "../deletion2_sco37.full.r2.all.noL.insMax.read4up.cluster.txt") || die "Can not open file ../deletion2_sco37.full.r2.all.noL.insMax.read4up.cluster.txt: $!\n";
	open(OUT,"> ./deletion2_sco37.full.r2.all.noL.insMax.read4up.cluster.txt");
    }
    if($event eq "tandem_dup"){
	open(CL,  "../tandem_duplication2_sco37.full.r2.all.noL.ins100up.read4up.cluster.txt") || die "Can not open file ../tandem_duplication2_sco37.full.r2.all.noL.ins100up.read4up.cluster.txt: $!\n";
	open(OUT,"> ./tandem_duplication2_sco37.full.r2.all.noL.ins100up.read4up.cluster.txt");
    }
    if($event eq "inversion"){
	if($dr eq "FF"){open(CL,  "../inversion2_ff_sco37.full.r2.all.noL.read4up.cluster.txt") || die "Can not open file ../inversion2_ff_sco37.full.r2.all.noL.read4up.cluster.txt: $!\n";
			open(OUT,"> ./inversion2_ff_sco37.full.r2.all.noL.read4up.cluster.txt");}
	if($dr eq "RR"){open(CL,  "../inversion2_rr_sco37.full.r2.all.noL.read4up.cluster.txt") || die "Can not open file ../inversion2_rr_sco37.full.r2.all.noL.read4up.cluster.txt: $!\n";
			open(OUT,"> ./inversion2_rr_sco37.full.r2.all.noL.read4up.cluster.txt");}
    }
    if($event eq "translocation"){
	if($dr eq "FR"){open(CL,  "../translocation2_fr_sco37.full.r2.all.noL.read4up.cluster.txt") || die "Can not open file ../translocation2_fr_sco37.full.r2.all.noL.read4up.cluster.txt: $!\n";
			open(OUT,"> ./translocation2_fr_sco37.full.r2.all.noL.read4up.cluster.txt");}
	if($dr eq "FF"){open(CL,  "../translocation2_ff_sco37.full.r2.all.noL.read4up.cluster.txt") || die "Can not open file ../translocation2_ff_sco37.full.r2.all.noL.read4up.cluster.txt: $!\n";
			open(OUT,"> ./translocation2_ff_sco37.full.r2.all.noL.read4up.cluster.txt");}
	if($dr eq "RR"){open(CL,  "../translocation2_rr_sco37.full.r2.all.noL.read4up.cluster.txt") || die "Can not open file ../translocation2_rr_sco37.full.r2.all.noL.read4up.cluster.txt: $!\n";
			open(OUT,"> ./translocation2_rr_sco37.full.r2.all.noL.read4up.cluster.txt");}
    }
    $flgF++;
}

    @clust=@flg=(); seek(CL,0,0);
    while($read = <CL>){
	push(@clust, $read);
	chomp($read); 
	@rcol = split(/\t/, $read);
	if($rcol[0] eq $clmem_line){$flg[0]++;}
	if($flg[0]>=1){ 
	    if(($rcol[2] eq $chL) && ($rcol[3] eq $clL)){$flg[1]++;}
	    if(($rcol[2] eq $chR) && ($rcol[3] eq $clR)){$flg[2]++;}
	}
	if($read eq "#####"){
	    if($flg[0]>0 && $flg[1]>0 && $flg[2]>0){printf OUT "%s",$line;  for($i=0;$i<=$#clust;$i++){printf OUT "%s", $clust[$i];}}
	    @clust=@flg=();
	}
    }
}
close(OUT); 
close(CL);
close(FILE);
