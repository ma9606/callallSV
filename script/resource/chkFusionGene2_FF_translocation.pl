#! /usr/bin/perl

if($#ARGV != 2){
    printf STDERR "usage: $0 [gene pos. file] [rearrangement res. file] [read len.]\n";
    exit -1;
}
$filename0 = $ARGV[0];
$filename1 = $ARGV[1];
$len = $ARGV[2];

$n = 0;
open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    $line =~ s/^[ \t]+//;
    $line =~ s/[ \t]+$//;
    @list = split(/[ \t]+/, $line);
    $gene[$n]->{gene} = $list[0];
    $gene[$n]->{ref} = $list[1];
    $gene[$n]->{chr} = $list[2];
    $gene[$n]->{str} = $list[3];
    $gene[$n]->{gene_sta} = $list[4];
    $gene[$n]->{gene_end} = $list[5];
    $gene[$n]->{cds_sta} = $list[6];
    $gene[$n]->{cds_end} = $list[7];
    $gene[$n]->{exon_num} = $list[8];
    @list1 = split(/,/, $list[9]);
    @list2 = split(/,/, $list[10]);
    $gene[$n]->{line} = $line;
    $j = 0;
    $ok = 0;
    for($i = 0; $i < $gene[$n]->{exon_num}; $i++){
	if($list1[$i] <= $gene[$n]->{cds_sta} && $gene[$n]->{cds_sta} <= $list2[$i]){
	    $gene[$n]->{cds_exon_sta}[$j] = $gene[$n]->{cds_sta};
	    $gene[$n]->{cds_exon_end}[$j] = $list2[$i];
	    $j++;
	    $ok = 1;
	}
	if($list1[$i] <= $gene[$n]->{cds_end} && $gene[$n]->{cds_end} <= $list2[$i]){
	    $gene[$n]->{cds_exon_sta}[$j] = $list1[$i];
	    $gene[$n]->{cds_exon_end}[$j] = $gene[$n]->{cds_end};
	    $j++;
	    last;
	}
	else{
	    if($ok == 1){
		$gene[$n]->{cds_exon_sta}[$j] = $list1[$i];
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
    $line =~ s/^[ \t]+//;
    $line =~ s/[ \t]+$//;
    @list = split(/[ \t]+/, $line);
    $num = $list[0];
    $sta = $list[4 + 5 * ($num - 1)] + $len - 1;
    $chr_sta = $list[3 + 5 * ($num - 1)];
    $end = $list[4 + 5 * (2 * $num - 1)] + $len - 1;
    $chr_end = $list[3 + 5 * (2 * $num - 1)];
    $j = 0;
    $j1 = 0;
    $j2 = 0;
    $j3 = 0;
    $l = 0;
    $r = 0;
    for($i = 0; $i < $n; $i++){
	if($chr_sta eq $gene[$i]->{chr}){
	    if($gene[$i]->{cds_sta} <= $sta && $sta < $gene[$i]->{cds_end}){
		$res3_l[$l]->{gene} = $gene[$i]->{gene};
		$res3_l[$l]->{ref} = $gene[$i]->{ref};
		$res3_l[$l]->{str} = $gene[$i]->{str};
		$l++;
		$j3++;
		$j++;
	    }
	}
	if($chr_end eq $gene[$i]->{chr}){
	    if($gene[$i]->{cds_sta} <= $end && $end < $gene[$i]->{cds_end}){
		$res3_r[$r]->{gene} = $gene[$i]->{gene};
		$res3_r[$r]->{ref} = $gene[$i]->{ref};
		$res3_r[$r]->{str} = $gene[$i]->{str};
		$r++;
		$j3++;
		$j++;
	    }
	}
    }
    printf(STDOUT "%d\t%d\t%d\t%d\t%d\t%d\t%s", $j, $j1, $j2, $j3, $l, $r, $line);
    for($k = 0; $k < $l; $k++){
	printf(STDOUT "\t%s, %s, %s", $res3_l[$k]->{str}, $res3_l[$k]->{gene}, $res3_l[$k]->{ref});
    }
    for($k = 0; $k < $r; $k++){
	printf(STDOUT "\t%s, %s, %s", $res3_r[$k]->{str}, $res3_r[$k]->{gene}, $res3_r[$k]->{ref});
    }
    printf(STDOUT "\n");
}
close(FILE);
