#! /usr/bin/perl

if($#ARGV < 1){
    printf STDERR "usage: $0 [PE_rearrangement10.txt] [target_clusterFile] (shift)\n";
    exit -1;
}

$rearrangement_list	= $ARGV[0];
$tarClust_file		= $ARGV[1];
if($#ARGV ==2){ 
    $shift		= $ARGV[2];
}
$MX_BUFrN =1;
$MX_BUFcrd=5;

open(LIST, $rearrangement_list) || die "Can not open file $rearrangement_list: $!\n";
open(FILE, $tarClust_file)      || die "Can not open file $tarClust_file: $!\n";
while($list_buff = <LIST>){ 

    @column = split(/\t/, $list_buff);
    $dir  = $column[0+$shift]; $mdf_dir = "_".(lc $dir)."_";
    $evnt = $column[2+$shift];
    if($tarClust_file !~ $evnt){goto NEXT;}
    else{ 
	if($evnt eq "deletion" || $evnt eq "tandem_dup"){print $list_buff;}
	elsif($tarClust_file =~ $mdf_dir){print $list_buff;}
	else {goto NEXT;}
    }

    $nRead= $column[3+$shift]; 
    $ch1  = $column[4+$shift];  $clustSt_1l = $column[ 5+$shift];  $clustEn_1l = $column[ 6+$shift];	## _1'l' ; mean "list"
    $ch2  = $column[9+$shift];  $clustSt_2l = $column[10+$shift];  $clustEn_2l = $column[11+$shift];

    seek(FILE,0,0);
    $flg = $n =0;
    while($line = <FILE>){
	chomp $line;
	@columnC = split(/\t/, $line); 
	$rlen=length($columnC[9]);
	
	if($flg == 1 && $#columnC >=10 && ($columnC[2] eq $ch1 || $columnC[2] eq $ch2)){ 
	    if($n==0){       $clustSt_1c = $columnC[3];}	## _1'c' ; mean "cluster_file"
	    if($n==$nRead-1){$clustEn_1c = $columnC[3]+($rlen-1);}
	    if($n==$nRead){  	 $clustSt_2c = $columnC[3];}
	    if($n==(($nRead-1)*2)-1){  $clustEn_2c = $columnC[3]+($rlen-1);}
	    $tarid[$n] = $columnC[0]; $n++;
# printf "$clustSt_1l,$clustEn_1l  $clustSt_2l,$clustEn_2l\t\t$clustSt_1c,$clustEn_1c  $clustSt_2c,$clustEn_2c\t$rlen\n";
	}
	if($line =~ /^Cluster/){ 
	    $NumRead =  $line;
	    $NumRead =~ s/Cluster Member: //; 
	    if($nRead-$MX_BUFrN<=$NumRead && $NumRead<=$nRead+$MX_BUFrN){$flg = 1;} 
	}
	if($line =~ /^#####/ && $flg == 1){
	    if( ($clustSt_1c-$MX_BUFcrd<=$clustSt_1l && $clustSt_1l<=$clustSt_1c+$MX_BUFcrd  &&  $clustSt_2c-$MX_BUFcrd<=$clustSt_2l && $clustSt_2l<=$clustSt_2c+$MX_BUFcrd) ||
		($clustEn_1c-$MX_BUFcrd<=$clustEn_1l && $clustEn_1l<=$clustEn_1c+$MX_BUFcrd  &&  $clustEn_2c-$MX_BUFcrd<=$clustEn_2l && $clustEn_2l<=$clustEn_2c+$MX_BUFcrd)){
# printf "$clustSt_1l,$clustEn_1l  $clustSt_2l,$clustEn_2l\t\t$clustSt_1c,$clustEn_1c  $clustSt_2c,$clustEn_2c\t$rlen\n";
		for($i=0;$i<$nRead;$i++){ print $tarid[$i]."\n"; }
		goto NEXT;
	    }
	    $flg = $n =0;  @tarid =();
	}
    }
    NEXT:
}
close(LIST);
close(FILE);
