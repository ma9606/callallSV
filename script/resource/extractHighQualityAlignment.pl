#! /usr/bin/perl

if($#ARGV != 1){
    printf STDERR "usage: $0 [file] [num]\n";
    exit -1;
}
$filename = $ARGV[0];
$max = $ARGV[1];

open(FILE, $filename) || die "Can not open file $filename: $!\n";
while($line = <FILE>){
    chomp $line;
    $ok = 1;
    @list = split(/\t/, $line);
    for($i = 11; $i <= $#list; $i++){
	if($list[$i] =~ /^XT/){
	    @list2 = split(/:/, $list[$i]);
	    if($list2[2] ne "U"){
		$ok = 0;
	    }
	}
	elsif($list[$i] =~ /^NM/){
	    @list2 = split(/:/, $list[$i]);
	    if($max < $list2[2]){
		$ok = 0;
	    }
	}
	elsif($list[$i] =~ /^X0/){
	    @list2 = split(/:/, $list[$i]);
	    if($list2[2] != 1){
		$ok = 0;
	    }
	}
	elsif($list[$i] =~ /^X1/){
	    @list2 = split(/:/, $list[$i]);
	    if($list2[2] != 0){
		$ok = 0;
	    }
	}
	elsif($list[$i] =~ /^XM/){
	    @list2 = split(/:/, $list[$i]);
	    if($max < $list2[2]){
		$ok = 0;
	    }
	}
	elsif($list[$i] =~ /^XO/){
	    @list2 = split(/:/, $list[$i]);
	    if($list2[2] != 0){
		$ok = 0;
	    }
	}
	elsif($list[$i] =~ /^XG/){
	    @list2 = split(/:/, $list[$i]);
	    if($list2[2] != 0){
		$ok = 0;
	    }
	}
    }

    $line2 = <FILE>;
    chomp $line2;
    @list = split(/\t/, $line2);
    for($i = 11; $i <= $#list; $i++){
	if($list[$i] =~ /^XT/){
	    @list2 = split(/:/, $list[$i]);
	    if($list2[2] ne "U"){
		$ok = 0;
	    }
	}
	elsif($list[$i] =~ /^NM/){
	    @list2 = split(/:/, $list[$i]);
	    if($max < $list2[2]){
		$ok = 0;
	    }
	}
	elsif($list[$i] =~ /^X0/){
	    @list2 = split(/:/, $list[$i]);
	    if($list2[2] != 1){
		$ok = 0;
	    }
	}
	elsif($list[$i] =~ /^X1/){
	    @list2 = split(/:/, $list[$i]);
	    if($list2[2] != 0){
		$ok = 0;
	    }
	}
	elsif($list[$i] =~ /^XM/){
	    @list2 = split(/:/, $list[$i]);
	    if($max < $list2[2]){
		$ok = 0;
	    }
	}
	elsif($list[$i] =~ /^XO/){
	    @list2 = split(/:/, $list[$i]);
	    if($list2[2] != 0){
		$ok = 0;
	    }
	}
	elsif($list[$i] =~ /^XG/){
	    @list2 = split(/:/, $list[$i]);
	    if($list2[2] != 0){
		$ok = 0;
	    }
	}
    }

    if($ok == 1){
	printf(STDOUT "%s\n", $line);
	printf(STDOUT "%s\n", $line2);
    }
}
close(FILE);
