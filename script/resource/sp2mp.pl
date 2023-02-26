#! /usr/bin/perl

#
# % sp2mp.prl [No.CPU] < [file listed tasks] 
#

if($#ARGV != 0){
    printf STDERR "usage: sp2mp.prl [num. cpu] < [task file]\n";
    exit -1;
}

# No.CPU
$cnum = $ARGV[0];

# Read all tasks and get num of total tasks
$tnum = 0;
while($a_line = <STDIN>){
    chop $a_line;
    if(($a_line !~ /^#/) && ($a_line !~ /^[ \t]*$/)){
	$task[$tnum+1] = $a_line;
	$tnum++;
    }
}

# parallelize tasks according to No.CPU
$start = 1;
$finish = 0;
if($tnum < $cnum){
    $cnum = $tnum;
}
for($i = 0; $i < $cnum; $i++){
    if($pid = fork){
	# Parent process
	printf(STDERR "Task %d (pid=%d) is generated...\n",
	       $start, $pid);
	$start++;
    }
    elsif(defined $pid){
	# Child process
	printf(STDERR "Task %d is starting...\n", $start);
	system($task[$start]);
	printf(STDERR "Task %d is finished...\n", $start);
	exit 0;
    }
    elsif($! =~ /No more process/){
	sleep 5;
	redo FORK;
    }
    else{
	die "Cannot fork: $!\n";
    }
}

# Finish one task, fork next task.
for( ; ; ){

    $pid = wait;
    $finish++;

    if($finish == $tnum){
	last;
    }

    if($start <= $tnum){
	if($pid = fork){
	    # Parent process
	    printf(STDERR "Task %d (pid=%d) is generated...\n",
		   $start, $pid);
	    $start++;
	}
	elsif(defined $pid){
	    # Child process
	    printf(STDERR "Task %d is starting...\n", $start);
	    system($task[$start]);
	    printf(STDERR "Task %d is finished...\n", $start);
	    exit 0;
	}
	elsif($! =~ /No more process/){
	    sleep 5;
	    redo FORK;
	}
	else{
	    die "Cannot fork: $!\n";
	}
    }
}


exit 0;

