#! /usr/bin/perl

if($#ARGV < 0){
    printf STDERR "usage: $0 [intraBP.list]\n";
    exit -1;
}

open(FILE, $ARGV[0]) || die "Can not open file $ARGV[0]: $!\n";
$n=0;
while($line = <FILE>){
    @column = split(/\t/, $line);
    $chL = $column[0];		$chR = $column[6];
    $bpL = $column[2];		$bpR = $column[4];
    $chL =~ s/\s+//;  $chR =~ s/\s+//;  $bpL =~ s/\s+//;  $bpR =~ s/\s+//;
    $drL = $column[1];		$drR = $column[5];  
    $olap =""; $inst="";
    if(   $column[9] =~ /interruption:/){$inst = $column[9]; $inst =~ s/interruption: //;}
    elsif($column[9] =~ /overlap:/){     $olap = $column[9]; $olap =~ s/overlap: //;
	@olstr = split(//, $olap);  
	$olbuff=""; for($i=0;$i<=$#olstr;$i++){ $olbuff .= "[".lc($olstr[$i]).$olstr[$i]."]"; }
    }

    print ">BP_".$chL."_".$bpL."-".$bpR."_".$chR."\n";
    $com="";
    if($drL =~ /=\>/ && $drR =~ /=\>/){
	$com  = "sed -e 1d ${chL}/${chL}_*-${bpL}_-#; ";
	if(length($olap)==0 && length($inst)==0){ $com .= "sed -e 1d ${chR}/${chR}_${bpR}-*_#- | tr -d '\n' | nkf -f40"; }
	elsif(length($olap)>0){ $com .=                   "sed -e 1d ${chR}/${chR}_${bpR}-*_#- | tr -d '\n' | sed -e \"1s/^$olbuff//\" | nkf -f40"; }
	elsif(length($inst)>0){ $com .=       "echo $inst; sed -e 1d ${chR}/${chR}_${bpR}-*_#- | tr -d '\n' | nkf -f40"; }  		
    }
    if($drL =~ /=\>/ && $drR =~ /\<=/){
	$com = "sed -e 1d ${chL}/${chL}_*-${bpL}_-#; ";
	if(length($olap)==0 && length($inst)==0){ $com .= "./.invert_nucSq.pl ${chR}/${chR}_*-${bpR}_-# -wo | tr -d '\n' | nkf -f40"; }
	elsif(length($olap)>0){ $com .=                   "./.invert_nucSq.pl ${chR}/${chR}_*-${bpR}_-# -wo | tr -d '\n' | sed -e \"1s/^$olbuff//\" | nkf -f40"; }
	elsif(length($inst)>0){ $com .=       "echo $inst; ./.invert_nucSq.pl ${chR}/${chR}_*-${bpR}_-# -wo | tr -d '\n' | nkf -f40"; } 
    }
    if($drL =~ /\<=/ && $drR =~ /\=>/){
	$com = "./.invert_nucSq.pl ${chL}/${chL}_${bpL}-*_#- -wo; ";
	if(length($olap)==0 && length($inst)==0){ $com .= "sed -e 1d ${chR}/${chR}_${bpR}-*_#- | tr -d '\n' | nkf -f40"; }
	elsif(length($olap)>0){ $com .=                   "sed -e 1d ${chR}/${chR}_${bpR}-*_#- | tr -d '\n' | sed -e \"1s/^$olbuff//\" | nkf -f40"; }
	elsif(length($inst)>0){ $com .=       "echo $inst; sed -e 1d ${chR}/${chR}_${bpR}-*_#- | tr -d '\n' | nkf -f40"; }
    }
    if($drL =~ /\<=/ && $drR =~ /\<=/){
	$com = "./.invert_nucSq.pl ${chL}/${chL}_${bpL}-*_#- -wo; ";
	if(length($olap)==0 && length($inst)==0){ $com .= "./.invert_nucSq.pl ${chR}/${chR}_*-${bpR}_-# -wo | tr -d '\n' | nkf -f40"; }
	elsif(length($olap)>0){ $com .=                   "./.invert_nucSq.pl ${chR}/${chR}_*-${bpR}_-# -wo | tr -d '\n' | sed -e \"1s/^$olbuff//\" | nkf -f40"; }
	elsif(length($inst)>0){ $com .=       "echo $inst; ./.invert_nucSq.pl ${chR}/${chR}_*-${bpR}_-# -wo | tr -d '\n' | nkf -f40"; }
    }
    if(length($com)!=0){ system($com); }  else{ print STDERR "ERROR; exit status 1;\n"; }
#    if(length($com)!=0){ print $com."\n"; }  else{ print STDERR "ERROR; exit status 1;\n"; }
}
close(FILE);
