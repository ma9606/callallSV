#! /usr/bin/perl

if($#ARGV < 0){
    printf STDERR "usage: $0 [tar_cluster] [removed_multiLnk_cluster]\n";
    exit -1;
}

open(TAR,  $ARGV[0]) || die "Can not open file $ARGV[0]: $!\n";
open(WOML, $ARGV[1]) || die "Can not open file $ARGV[1]: $!\n";

while($line[$n] = <TAR>){
  if($line[$n] =~ "^0."){$line[0]=$line[$n]; $n=0; $svlist=$line[$n]; $cnt=0; $flg_pass=0; }
  else{
    if($line[$n] =~ "^Cluster Member:"){
	if($clM!=0 && $clM==$cnt){$flg_pass++;}
	@column = split(/\s+/, $line[$n]);  $clM =$column[2]; 
	$cnt=0;
    }elsif($line[$n] =~ "^#####"){
	if($clM!=0 && $clM==$cnt && $flg_pass==1){
	    for($i=0;$i<=$n;$i++){print $line[$i];}
	}
    }else{
    	seek(WOML,0,0);
    	while($read = <WOML>){
#	    if($line[$n] eq $read){$cnt++; print $cnt."\t".$line[$n]; last;}
	    if($line[$n] eq $read){$cnt++; last;}
	}
    }
  }
  $n++;
}
close(TAR);
close(WOML);
