#! /usr/bin/perl

if($#ARGV ne 1){
    printf STDERR "usage: $0 [target.sam.gz]  [filename]\n";
    exit -1;
}

open(FILE, $ARGV[0]) || die "Can not open file $ARGV[0]: $!\n";
$nambody=$ARGV[1];

$n=0; $nid=sprintf("%03d", $n);
$fpid="SP".$n;   
$outname=$nambody."_".$nid;
open($fpid, "> ./$outname");

$cnt=0;
while($line = <FILE>){
    if($line =~ /^@/){next;}

    @column = split(/\t/, $line);
    if($column[0] ne $cur_readid){$cnt++;}
    if($cnt==2000000){
	close($fpid); 

	$cnt=0;
	$n++; $nid=sprintf("%03d", $n);
	$fpid="SP".$n; 
	$outname=$nambody."_".$nid;
	open($fpid, "> ./$outname");

	printf($fpid "%s", $line);

    }else{
	printf($fpid "%s", $line);
    }
    $cur_readid = $column[0];
}
close($fpid);
close(FILE);
