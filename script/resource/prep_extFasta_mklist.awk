{
    if($1==chID){
	st = $4-(mxis-1);  en = $4+(mxis-1);
	if($3~">"){print st"\t"$4"\t-#";}
	else {     print $4"\t"en"\t#-";}
    }
    if($9==chID){
	st = $6-(mxis-1);  en = $6+(mxis-1);
	if($7~">"){print $6"\t"en"\t#-";}
	else {     print st"\t"$6"\t-#";}
    }
}
