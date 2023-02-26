#! /usr/bin/perl

if($#ARGV < 0){
    printf STDERR "usage: $0 [file] (-os)\n\t-os: Only Sequence (not with header)";
    exit -1;
}

open(FILE, $ARGV[0]) || die "Can not open file $conf: $!\n";
$length=0;
while($line = <FILE>){
  if($line =~ /^\>/){
     if($#ARGV == 0){
        @header = split(/\s+/, $line);
        @crd = split(/[\>,\-,_]/, $header[0]);
        print ">invert-".$crd[1]."_".$crd[3]."-".$crd[2];
        if($line =~ /-#/){print " #-\n";}   else{print " -#\n";}
     }
  }
  else{
    chop($line);
    @column = split(//, $line);  # Field Spacer: // = divide per one character
    for($i=0;$i<=$#column;$i++){
	if(   $column[$i] eq "a"){$seq[$length] = "t"; $length++;}  elsif($column[$i] eq "A"){$seq[$length] = "T"; $length++;}
	elsif($column[$i] eq "g"){$seq[$length] = "c"; $length++;}  elsif($column[$i] eq "G"){$seq[$length] = "C"; $length++;}
	elsif($column[$i] eq "c"){$seq[$length] = "g"; $length++;}  elsif($column[$i] eq "C"){$seq[$length] = "G"; $length++;}
	elsif($column[$i] eq "t"){$seq[$length] = "a"; $length++;}  elsif($column[$i] eq "T"){$seq[$length] = "A"; $length++;}
        else {					    $seq[$length] = $column[$i]; $length++;}
    }
  }
}
close(FILE);

$cnt=0;
for($i=$length;$i>=0;$i--){
    print $seq[$i];
    $cnt++;
    if($cnt==50){print "\n"; $cnt=0;}
}
print "\n";
