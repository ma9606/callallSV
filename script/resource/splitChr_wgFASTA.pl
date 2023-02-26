#! /usr/bin/perl

if($#ARGV < 0){
    printf STDERR "usage: $0 [whole.genome.fa]\n";
    exit -1;
}

open(FILE, $ARGV[0]) || die "Can not open file $ARGV[0]: $!\n";
$nambody=$ARGV[0];
@chID = ("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y");

$n=0;
$fpid="fp".$n;

while($line = <FILE>){
  if($line =~ /^>/ && $n>$#chID){
    close($fpid);
    close(FILE);
    exit;
  }

  if($line =~ /^>$chID[0] /){
    $outfile = $nambody."_chr".$chID[0];
    open($fpid, "> $outfile");
    @column  = split(/\s+/, $line); 
    $column[0] =~ s/>/>chr/;
    printf($fpid "%s\n", $column[0]);
    $n=1;
  }
  elsif($line =~ /^>$chID[$n] /){
	close($fpid); 

	$outfile=$nambody."_chr".$chID[$n];
	open($fpid, "> $outfile");
    	@column  = split(/\s+/, $line); 
    	$column[0] =~ s/>/>chr/;
    	printf($fpid "%s\n", $column[0]);
	$n++;

  }else{
	printf($fpid "%s", $line);
  }
}
