#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [file] [read length]\n";
    exit -1;
}
$filename0 = $ARGV[0];
$len = $ARGV[1];

open(FILE, $filename0) || die "Can not open file $filename0: $!\n";
while($line = <FILE>){
    chomp $line;
    $line =~ s/^[ \t]+//;
    $line =~ s/[ \t]+$//;
    @list = split(/[ \t]+/, $line);
    $chr1 = $list[0];
    $str1 = $list[1];
    $sta1 = $list[2];
    $end1 = $list[3] + $len - 1;
    $chr2 = $list[4];
    $str2 = $list[5];
    $sta2 = $list[6];
    $end2 = $list[7] + $len - 1;
    $len1 = $end1 - $sta1 + 1;
    $len2 = $end2 - $sta2 + 1;
    printf(STDOUT "%s\t%s\t%d\t%d\t%d\t%s\t%s\t%d\t%d\t%d\n",
	   $chr1, $str1, $sta1, $end1, $len1, 
	   $chr2, $str2, $sta2, $end2, $len2);

}
close(FILE);
