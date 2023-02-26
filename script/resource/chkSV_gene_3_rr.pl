#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [refFlat file] [rearrangement res. file]\n";
    exit -1;
}
$filename0 = $ARGV[0];
$filename1 = $ARGV[1];

$n = 0;
open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    @list = split(/\t/, $line);
    $gene[$n]->{gene} = $list[0];
    $gene[$n]->{ref} = $list[1];
    $gene[$n]->{chr} = $list[2];
    $gene[$n]->{str} = $list[3];
    $gene[$n]->{gene_sta} = $list[4] + 1;
    $gene[$n]->{gene_end} = $list[5];
    $gene[$n]->{cds_sta} = $list[6] + 1;
    $gene[$n]->{cds_end} = $list[7];
    $gene[$n]->{exon_num} = $list[8];
    @list1 = split(/,/, $list[9]);
    @list2 = split(/,/, $list[10]);
    for($i = 0; $i < $gene[$n]->{exon_num}; $i++){
	$gene[$n]->{exon_sta}[$i] = $list1[$i] + 1;
	$gene[$n]->{exon_end}[$i] = $list2[$i];
    }
    $j = 0;
    $ok = 0;
    for($i = 0; $i < $gene[$n]->{exon_num}; $i++){
	if(($list1[$i] + 1 <= $gene[$n]->{cds_sta} && $gene[$n]->{cds_sta} <= $list2[$i]) &&
	   ($list1[$i] + 1 <= $gene[$n]->{cds_end} && $gene[$n]->{cds_end} <= $list2[$i])){
	    $gene[$n]->{cds_exon_sta}[$j] = $gene[$n]->{cds_sta};
	    $gene[$n]->{cds_exon_end}[$j] = $gene[$n]->{cds_end};
	    $j++;
	    last;
	}
	elsif($list1[$i] + 1 <= $gene[$n]->{cds_sta} && $gene[$n]->{cds_sta} <= $list2[$i]){
	    $gene[$n]->{cds_exon_sta}[$j] = $gene[$n]->{cds_sta};
	    $gene[$n]->{cds_exon_end}[$j] = $list2[$i];
	    $j++;
	    $ok = 1;
	}
	elsif($list1[$i] + 1 <= $gene[$n]->{cds_end} && $gene[$n]->{cds_end} <= $list2[$i]){
	    $gene[$n]->{cds_exon_sta}[$j] = $list1[$i] + 1;
	    $gene[$n]->{cds_exon_end}[$j] = $gene[$n]->{cds_end};
	    $j++;
	    last;
	}
	else{
	    if($ok == 1){
		$gene[$n]->{cds_exon_sta}[$j] = $list1[$i] + 1;
		$gene[$n]->{cds_exon_end}[$j] = $list2[$i];
		$j++;
	    }
	}
    }
    $gene[$n]->{cds_exon_num} = $j;
    $n++;
}
close(FILE);

open(FILE, $filename1) || die "Can not open file $filename1: $!\n";
while($line = <FILE>){
    chomp $line;
    @list = split(/\t/, $line);
    $num = $list[0];
    $chr1 = $list[1];
    $sta1 = $list[2];
    $end1 = $list[3];
    $len1 = $list[4];
    $chr2 = $list[5];
    $sta2 = $list[6];
    $end2 = $list[7];
    $len2 = $list[8];
    $ins = $list[9];
    if($chr1 eq $chr2){
	$sp = $sta2 - $end1 - 1;
	printf(STDOUT "%s\t%d", $line, $sp);
	for($i = 0; $i < $n; $i++){
	    $str = $gene[$i]->{str};
	    $cds_exon_num = $gene[$i]->{cds_exon_num};
	    $exon_num = $gene[$i]->{exon_num};
	    if($chr1 eq $gene[$i]->{chr}){
		if(($gene[$i]->{gene_sta} <= $end1 && $end1 < $gene[$i]->{gene_end}) &&
		   ($gene[$i]->{gene_sta} < $sta2 && $sta2 <= $gene[$i]->{gene_end})
		    ){
		    for($j = 0; $j < $exon_num; $j++){
			if(($gene[$i]->{exon_sta}[$j] <= $end1 && $end1 < $gene[$i]->{exon_end}[$j]) &&
			   ($gene[$i]->{exon_sta}[$j] < $sta2 && $sta2 <= $gene[$i]->{exon_end}[$j])
			    ){
			    printf(STDOUT "\tBoth_side:%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
			    last;
			}
			elsif(($gene[$i]->{exon_sta}[$j] <= $end1 && $end1 < $gene[$i]->{exon_end}[$j]) ||
			      ($gene[$i]->{exon_sta}[$j] < $sta2 && $sta2 <= $gene[$i]->{exon_end}[$j])
			    ){
			    printf(STDOUT "\tBoth_side:%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
			    last;
			}
			elsif(($end1 < $gene[$i]->{exon_sta}[$j] && $gene[$i]->{exon_sta}[$j] < $sta2) &&
			      ($end1 < $gene[$i]->{exon_end}[$j] && $gene[$i]->{exon_end}[$j] < $sta2)
			    ){
			    printf(STDOUT "\tBoth_side:%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
			    last;
			}
		    }
		}
		elsif($gene[$i]->{gene_sta} <= $end1 && $end1 < $gene[$i]->{gene_end}){
#		    if($end1 < $gene[$i]->{cds_exon_sta}[0]){
		    if(($end1 < $gene[$i]->{cds_exon_sta}[0]) ||
		       ($gene[$i]->{cds_exon_sta}[0] <= $end1 && $end1 < $gene[$i]->{cds_exon_end}[0])){
			if($str eq "+"){
			    printf(STDOUT "\t5'_side:+:5'_UTR:%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
			}
			elsif($str eq "-"){
			    printf(STDOUT "\t5'_side:-:3'_UTR:%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
			}
		    }
#		    elsif(($gene[$i]->{cds_exon_sta}[$cds_exon_num - 1] <= $end1 && 
#			   $end1 < $gene[$i]->{cds_exon_end}[$cds_exon_num - 1]) ||
#			  ($gene[$i]->{cds_exon_end}[$cds_exon_num - 1] <= $end1)){
		    elsif($gene[$i]->{cds_exon_end}[$cds_exon_num - 1] <= $end1){
			if($str eq "+"){
			    printf(STDOUT "\t5'_side:+:3'_UTR:%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
			}
			elsif($str eq "-"){
			    printf(STDOUT "\t5'_side:-:5'_UTR:%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
			}
		    }
		    else{
			$total_len = 0;
			for($j = 0; $j < $cds_exon_num - 1; $j++){
			    $total_len += $gene[$i]->{cds_exon_end}[$j] - $gene[$i]->{cds_exon_sta}[$j] + 1;
#			    if($gene[$i]->{cds_exon_end}[$j] <= $end1 && $end1 < $gene[$i]->{cds_exon_sta}[$j+1]){
#			    if(($gene[$i]->{cds_exon_sta}[$j] <= $end1 && $end1 < $gene[$i]->{cds_exon_end}[$j]) ||
#			       ($gene[$i]->{cds_exon_end}[$j] <= $end1 && $end1 < $gene[$i]->{cds_exon_sta}[$j+1])){
			    if(($gene[$i]->{cds_exon_end}[$j] <= $end1 && $end1 < $gene[$i]->{cds_exon_sta}[$j+1]) ||
			       ($gene[$i]->{cds_exon_sta}[$j+1] <= $end1 && $end1 < $gene[$i]->{cds_exon_end}[$j+1])){
				$a = $total_len % 3;
				if($str eq "-"){
				    if($a == 1){
					$a = 2;
				    }
				    elsif($a == 2){
					$a = 1;
				    }
				}
				if($str eq "+"){
				    printf(STDOUT "\t5'_side:+:%d:%s,%s", $a, $gene[$i]->{gene}, $gene[$i]->{ref});
				}
				elsif($str eq "-"){
				    printf(STDOUT "\t5'_side:-:%d:%s,%s", $a, $gene[$i]->{gene}, $gene[$i]->{ref});
				}
				last;
			    }
			}
		    }
		}
		elsif($gene[$i]->{gene_sta} < $sta2 && $sta2 <= $gene[$i]->{gene_end}){
#		    if($sta2 <= $gene[$i]->{cds_exon_sta}[0]){
		    if(($sta2 <= $gene[$i]->{cds_exon_sta}[0]) ||
		       ($gene[$i]->{cds_exon_sta}[0] < $sta2 && $sta2 <= $gene[$i]->{cds_exon_end}[0])){
			if($str eq "+"){
			    printf(STDOUT "\t3'_side:+:5'_UTR:%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
			}
			elsif($str eq "-"){
			    printf(STDOUT "\t3'_side:-:3'_UTR:%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
			}
		    }

#		    elsif(($gene[$i]->{cds_exon_sta}[$cds_exon_num - 1] < $sta2 && $sta2 <= $gene[$i]->{cds_exon_end}[$cds_exon_num - 1]) ||
#			  ($gene[$i]->{cds_exon_end}[$cds_exon_num - 1] < $sta2)){
		    elsif($gene[$i]->{cds_exon_end}[$cds_exon_num - 1] < $sta2){
			if($str eq "+"){
			    printf(STDOUT "\t3'_side:+:3'_UTR:%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
			}
			elsif($str eq "-"){
			    printf(STDOUT "\t3'_side:-:5'_UTR:%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
			}
		    }
		    else{
			$total_len = 0;
			for($j = 0; $j < $cds_exon_num - 1; $j++){
			    $total_len += $gene[$i]->{cds_exon_end}[$j] - $gene[$i]->{cds_exon_sta}[$j] + 1;
#			    if($gene[$i]->{cds_exon_end}[$j] < $sta2 && $sta2 <= $gene[$i]->{cds_exon_sta}[$j+1]){
#			    if(($gene[$i]->{cds_exon_sta}[$j] < $sta2 && $sta2 <= $gene[$i]->{cds_exon_end}[$j]) ||
#			       ($gene[$i]->{cds_exon_end}[$j] < $sta2 && $sta2 <= $gene[$i]->{cds_exon_sta}[$j+1])){
			    if(($gene[$i]->{cds_exon_end}[$j] < $sta2 && $sta2 <= $gene[$i]->{cds_exon_sta}[$j+1]) ||
			       ($gene[$i]->{cds_exon_sta}[$j+1] < $sta2 && $sta2 <= $gene[$i]->{cds_exon_end}[$j+1])){
				$a = $total_len % 3;
				if($str eq "-"){
				    if($a == 1){
					$a = 2;
				    }
				    elsif($a == 2){
					$a = 1;
				    }
				}
				if($str eq "+"){
				    printf(STDOUT "\t3'_side:+:%d:%s,%s", $a, $gene[$i]->{gene}, $gene[$i]->{ref});
				}
				elsif($str eq "-"){
				    printf(STDOUT "\t3'_side:-:%d:%s,%s", $a, $gene[$i]->{gene}, $gene[$i]->{ref});
				}
				last;
			    }
			}
		    }
		}
#		elsif(($end1 < $gene[$i]->{gene_sta} && $gene[$i]->{gene_sta} < $sta2) &&
#		      ($end1 < $gene[$i]->{gene_end} && $gene[$i]->{gene_end} < $sta2)
#		    ){
#		    printf(STDOUT "\t%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
#		}
	    }
	}
	printf(STDOUT "\n");
    }
    else{
	printf(STDERR "error: %s\n", $line);
    }
}
close(FILE);
