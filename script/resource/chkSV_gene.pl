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
    if($list[1] =~ /^NM_/){
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
	    if($chr1 eq $gene[$i]->{chr}){
		if(($gene[$i]->{cds_sta} <= $end1 && $end1 < $gene[$i]->{cds_end}) &&
		   ($gene[$i]->{cds_sta} < $sta2 && $sta2 <= $gene[$i]->{cds_end})
		    ){
		    for($j = 0; $j < $gene[$i]->{cds_exon_num}; $j++){
			if(($gene[$i]->{cds_exon_sta}[$j] <= $end1 && $end1 < $gene[$i]->{cds_exon_end}[$j]) &&
			   ($gene[$i]->{cds_exon_sta}[$j] < $sta2 && $sta2 <= $gene[$i]->{cds_exon_end}[$j])
			    ){
			    printf(STDOUT "\t%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
			    last;
			}
			elsif(($gene[$i]->{cds_exon_sta}[$j] <= $end1 && $end1 < $gene[$i]->{cds_exon_end}[$j]) ||
			      ($gene[$i]->{cds_exon_sta}[$j] < $sta2 && $sta2 <= $gene[$i]->{cds_exon_end}[$j])
			    ){
			    printf(STDOUT "\t%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
			    last;
			}
			elsif(($end1 < $gene[$i]->{cds_exon_sta}[$j] && $gene[$i]->{cds_exon_sta}[$j] < $sta2) &&
			      ($end1 < $gene[$i]->{cds_exon_end}[$j] && $gene[$i]->{cds_exon_end}[$j] < $sta2)
			    ){
			    printf(STDOUT "\t%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
			    last;
			}
		    }
		}
		elsif(($gene[$i]->{cds_sta} <= $end1 && $end1 < $gene[$i]->{cds_end}) ||
		      ($gene[$i]->{cds_sta} < $sta2 && $sta2 <= $gene[$i]->{cds_end})
		    ){
		    printf(STDOUT "\t%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
		}
		elsif(($end1 < $gene[$i]->{cds_sta} && $gene[$i]->{cds_sta} < $sta2) &&
		      ($end1 < $gene[$i]->{cds_end} && $gene[$i]->{cds_end} < $sta2)
		    ){
		    printf(STDOUT "\t%s,%s", $gene[$i]->{gene}, $gene[$i]->{ref});
		}
	    }
	}
	printf(STDOUT "\n");
    }
    else{
	printf(STDERR "error: %s\n", $line);
    }
}
close(FILE);
