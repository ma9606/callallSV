#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [file] [read len.]\n";
    exit -1;
}
$filename1 = $ARGV[0];
$len = $ARGV[1];

open(FILE, $filename1) || die "Can not open file $filename1: $!\n";
while($line = <FILE>){
    chomp $line;
    $line =~ s/^[ \t]+//;
    $line =~ s/[ \t]+$//;
#    @list = split(/[ \t]+/, $line);
    @list = split(/\t/, $line);
    $j1 = $list[1];
    $j2 = $list[2];
    $l = $list[4];
    $r = $list[5];
    $num = $list[6];
    $len2 = $list[7];
    $chr = $list[9];
    $sta = $list[10 + 5 * ($num - 1)] + $len - 1;
    $end = $list[10 + 5 * $num];
    $chr_sta = $list[9 + 5 * ($num - 1)];
    $chr_end = $list[9 + 5 * $num];
    $str_sta = $list[11 + 5 * ($num - 1)];
    $str_end = $list[11 + 5 * $num];
#    $i = 8 + 10 * $num;
    $i = $#list - $j1 -$j2 - $l - $r + 1;
#    printf(STDOUT "%d\t%d\n", $num, $end - $sta - 1);
    printf(STDOUT "%d\n", $num);
    printf(STDOUT "%s %s %d\t", $chr_sta, $str_sta, $sta);
    printf(STDOUT "%s %s %d", $chr_end, $str_end, $end);
    for($k = 0; $k < $j1; $k++){
	printf(STDOUT "\t%s", $list[$i]);
	$i++;
    }
    printf(STDOUT "\n");
    printf(STDOUT "%s %s %d\t", $chr_sta, $str_sta, $sta);
    printf(STDOUT "%s %s %d", $chr_end, $str_end, $end);
    for($k = 0; $k < $j2; $k++){
	printf(STDOUT "\t%s", $list[$i]);
	$i++;
    }
    printf(STDOUT "\n");
    printf(STDOUT "%s\t%s\t%d", $chr_sta, $str_sta, $sta);
    for($k = 0; $k < $l; $k++){
	printf(STDOUT "\t%s", $list[$i]);
	$i++;
    }
    printf(STDOUT "\n");
    printf(STDOUT "%s\t%s\t%d", $chr_end, $str_end, $end);
    for($k = 0; $k < $r; $k++){
	printf(STDOUT "\t%s", $list[$i]);
	$i++;
    }
    printf(STDOUT "\n");
    printf(STDOUT "\n");
}
close(FILE);
