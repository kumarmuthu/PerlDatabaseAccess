# Author: Muthukumar Subramanian
# v2018.01.26.01 - developed for common executable query
package MUTHUKUMAR_DB;
use DBI;
use Data::Dumper;
use DBD::ODBC;
use Sub::Identify ':all';
sub database_req
{
	my %i=@_;
	my $user = "sa";
	my $pw = 'P@ssword';
	my $dsn=DBI->connect("DBI:ODBC:Driver={SQL Server};Server=localhost;UID=$user;PWD=$pw;{odbc_driver_complete => 1}") or die "Can't connect ";
	#print Dumper\$dsn;
	
	my $query_option=$i{query_option};
	my ($ok,$ref)=main_query_call_function(@_,dsn=> $dsn,query_option=> $query_option,
	read_call=>{coderef=>\&_read_query},
	insert_cal=>{coderef=>\&_insert_query},
	update_call=>{coderef=>\&_update_query},
	delete_call=>{coderef=>\&_delete_query});
	if($ok)
	{
		print "function: main_query_call_function execution completed\n";
	}
	else
	{
 		die"Something wrong\n";
	}
	
  return 1,$ref;
}

sub main_query_call_function
{
 my %i=@_;
 my $query_option=$i{query_option};
 my $read_call=$i{read_call};
 my $insert_cal=$i{insert_cal};
 my $update_call=$i{update_call};
 my $delete_call=$i{delete_call};
 my @call_array;
 my $ret={};
 
 if(defined $query_option and $query_option =~ /read|get/i)
 {
  push( @call_array,$read_call);
 }
 if(defined $query_option and $query_option =~ /insert|post/i)
 {
  push( @call_array,$insert_cal);
 }
 if(defined $query_option and $query_option =~ /update|patch/i)
 {
  push( @call_array,$update_call);
 }
 if(defined $query_option and $query_option =~ /remove|delete/i)
 {
  push( @call_array,$delete_call);
 }
 my $i=0;
  	foreach my $one_by_one(@call_array) 
  	{  
 		$ref=sub_fullname($one_by_one->{coderef});
 		print "Executing: $ref \n";
 
 		#$okk,$reff=&{$one_by_one->{coderef}}(@_);
    	# OR
 		my ($ok_ret,$reff_ret)= &$ref(@_);
 		push(@{$ret->{$i}},$reff_ret);
	 	if(!$ok_ret)
	 	{
	 		die "Issues observed while executing $ref \n";
	 	}
	 	$i++;
	}
	
return 1,$ret;
}

################# call function #################
#READ
sub _read_query
 {
 	my %i=@_;
 	my $dsn=$i{dsn};
 	my $tablename=$i{tablename};
 	print "tablename:".Dumper\$tablename;
 	print "DSN:".Dumper\$dsn;
 	
 	my $sql = "SELECT * FROM $tablename";
    my $sth = $dsn->prepare($sql);
	$sth->execute() || die $DBI::errstr;
	my $row = $sth->fetchall_hashref("mobile_number");
	print "***** DATABASE RETRIVE DATA *****\n".Dumper\$row;
	$sth->finish();
 	return 1,$row;
 } 

#INSERT
sub _insert_query
{
	my %i=@_;
 	my $dsn=$i{dsn};
 	my $tablename=$i{tablename};
 	my $ins_user_name = $i{ins_user_name};
 	my $ins_user_password = $i{ins_user_password};
 	my $ins_mobile_number = $i{ins_mobile_number};
 	print "***** DATABASE INSERT DATA *****\n".Dumper\$ins_user_name,\$ins_user_password,\$ins_mobile_number;
 	my $exe=$dsn->do( qq{INSERT INTO $tablename(user_name,user_password,mobile_number) VALUES ('$ins_user_name','$ins_user_password','$ins_mobile_number')});
 	return 1;
}

#UPDATE
sub _update_query
{
	my %i=@_;
 	my $dsn=$i{dsn};
 	my $tablename=$i{tablename};
 	my $exe=$dsn->do("UPDATE $tablename SET user_password ='abc' WHERE user_name= 'zxc'");
 	return 1;
}

#DELETE
sub _delete_query
{
	my %i=@_;
	my $del_mobile_number = $i{del_mobile_number};
 	my $dsn=$i{dsn};
 	my $tablename=$i{tablename};
    my $exe=$dsn->do("DELETE $tablename WHERE mobile_number = '$del_mobile_number'");
	return 1;
}


=b
	my $tablename=$i{tablename};
my $user = "sa";
my $pw = 'P@ssword';
#my $tablename = "kumar.dbo.login_perl";
my $dsn=DBI->connect("DBI:ODBC:Driver={SQL Server};Server=localhost;UID=$user;PWD=$pw;{odbc_driver_complete => 1}") or die "Can't connect ";
print Dumper\$dsn;

my $ok;
$ok=_read_query(dsn=>$dsn,tablename=>$tablename);
if(!$ok)
{
	die"died _read_query func\n";
}


#my $exe=$dsn->do("INSERT INTO $tablename(adminname,adminpassword) VALUES ('kumar','pass123')");

$ok=_insert_query(dsn=>$dsn,tablename=>$tablename);
if(!$ok)
{
	die"died _insert_query func\n";
}

print "********After insert*******\n";
$ok=_read_query(dsn=>$dsn,tablename=>$tablename);
if(!$ok)
{
	die"died _read_query func\n";
}
sleep(5);
$ok=_update_query(dsn=>$dsn,tablename=>$tablename);
if(!$ok)
{
	die"died _update_query func\n";
}
print "********After update*******\n";
$ok=_read_query(dsn=>$dsn,tablename=>$tablename);
if(!$ok)
{
	die"died _read_query func\n";
}

sleep(5);
$ok=_delete_query(dsn=>$dsn,tablename=>$tablename);
if(!$ok)
{
	die"died _insert_query func\n";
}
print "********After deete*******\n";
$ok=_read_query(dsn=>$dsn,tablename=>$tablename);
if(!$ok)
{
	die"died _read_query func\n";
}
$dsn->disconnect();
=cut


1;