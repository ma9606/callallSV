#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [file1] [min. member]\n";
    exit -1;
}
$filename = $ARGV[0];
$min = $ARGV[1];
@tar_contig = ("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chr20","chr21","chr22","chrX","chrY");
@mdf_contig = ("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24");
@tar_cnt=(); for($i=0;$i<=$#tar_contig;$i++){$tar_cnt[$i]=0;}

open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
    if($line =~ /^Cluster/){
#	$title = "Cluster Member: #\n";
	@array_Cluster=();
    }
    elsif($line =~ /^\#/){
	for($i=0;$i<=$#tar_contig;$i++){if($tar_cnt[$i]>= $min){
	    @array_pos_sort = @array_chr =();  @array_pos_sort =sort{$a <=> $b} @array_pos;
	    for($j=0;$j<=$#array_pos_sort;$j++){ @eq = split(/\./, $array_pos_sort[$j]); push(@array_chr, $eq[1]);}
	    $tmp_pos=0; @array_tmp_cl=();

	    for($j=0;$j<$n;$j++){
	        if($array_chr[$j] == $mdf_contig[$i]){
		    if(($array_pos_sort[$j] - $tmp_pos)<1000){
			if($#array_tmp_cl==-1){push(@array_tmp_cl, $tmp_pos.".".$array_chr[$j]);}
			push(@array_tmp_cl, $array_pos_sort[$j]);
		    }
		    else{ 
			if($#array_tmp_cl >= $min-1){ push(@array_Cluster, @array_tmp_cl); }
			@array_tmp_cl=();
		    }
		    $tmp_pos = $array_pos_sort[$j];
	        }
	    }
	    if($#array_tmp_cl >= $min-1){ push(@array_Cluster, @array_tmp_cl); }
	}}
	if($#array_Cluster >=$min-1){
	    open(FILE_tmp, "> ./.tmp_${filename}");
	    for($i=0;$i<=$#array_Cluster;$i++){
	        @tar = split(/\./, $array_Cluster[$i]);
	        if(   $tar[1]==23){ $target = "chrX"."\t".$tar[0];}
	        elsif($tar[1]==24){ $target = "chrY"."\t".$tar[0];}
	    	else{		    $target = "chr".$tar[1]."\t".$tar[0];}

	    	for($j=0;$j<=$n;$j++){
		    if($tar_line[$j] =~ $target){printf(FILE_tmp "%s", $tar_line[$j]); $tar_line[$j]=""; last;}
	    	}
	    }
	    close(FILE_tmp);
	    system("sort -k4,4n ./.tmp_${filename} > ./.tmp_${filename}.srt");

	    printf(STDOUT "Cluster Member: %d\n",$#array_Cluster+1);
	    open(FILE_srt, "./.tmp_${filename}.srt");
	    while($srt = <FILE_srt>){
		printf (STDOUT "%s",$srt);
	    }
	    close(FILE_srt);
	    printf(STDOUT "#####\n");
	}
	$n =0;
	@array_pos = @array_chr =();
	@tar_cnt=(); for($i=0;$i<=$#tar_contig;$i++){$tar_cnt[$i]=0;}
    }
    else{
	@list = split(/\t/, $line);
	for($i=0;$i<=$#tar_contig;$i++){if($tar_contig[$i] eq $list[6]){$ep=$mdf_contig[$i];}}
	$pos= $list[7].".".$ep; 
	push(@array_pos, $pos); 
	for($i=0;$i<=$#tar_contig;$i++){if($list[6] eq $tar_contig[$i]){$tar_cnt[$i]++;}}
	$tar_line[$n] = $line;  $n++;
    }
}
close(FILE);
