# Author: Muthukumar Subramanian
# v2018.01.26.01 - Developed user_verification_db
# v2018.02.03.01 - Developed user_operation_db
use Data::Dumper;
use strict;
use warnings;
use Getopt::ArgParse;
use File::Basename;
use Data::Dumper;
#use DBD::mysql;
use Log::Logger;
use File::Log;
use Log::Any;
use Getopt::ArgParse;
use POSIX qw(strftime);
#use List::Uniq ':all';
use Time::Piece;
use MUTHUKUMAR_DB;

my $int1=0;
my ($num2,$mm,$num,$ap,$print,$ok,$ref_hash,$range,$out);
    eval
    {
     my ($ok_ver,$ref_ver,$ref_mob,$ok_reg,$ref_reg,$ok_op,$ref_op);
      print("======= Welcome Guest =======\n======= New user(select 1) or Old user(select 2)? =======\n");
      chomp($mm=<STDIN>);
      if(defined $mm and $mm ne '')
      {
        if($mm==1)
        {
         	 print "New user please register your details\n";
         	($ok_reg,$ref_reg)=registration(@_);
         	if(!$ok_reg)
         	{
         		 die "Error observed while register";
         	}
       }
       elsif($mm==2)
       {
       	 	print "Old user continue your work/job\n";
       		($ok_ver,$ref_ver,$ref_mob)=user_verification_db(@_);
       		if( !$ok_ver )
      		{
        	 	die "Error observed while verify the user credentials on the database";
      	    }
       		else
      		{
       			print "User can read/get or insert/post or update/patch or remove/delete\n";
       			($ok_op,$ref_op)=user_operation_db(@_, _username=> $ref_ver,_user_mob => $ref_mob);
       			if( !$ok_op )
      			{
        	 	die "Error observed while verify the user operations on the database";
      	    	}
       		}
      }
      elsif($mm >2 || $mm ==0 || $mm == -1)
      {
    	die"User given entry is invalid\n";
      }
    }
    else
    {
      die"User must give your option\n";
    }
   };
if($@)
{
  print "Error observed while register/login:\n$@\n";
}


#################### DB user verification ##################
my %database_hash;
sub user_verification_db
{
 my %i=@_;
 my $login_success=0;
 my ($reg,$user_password,$user_name,$mobile_number,$user_nameget);
   	   print("Enter Your User Name: [Alphabet character only allowed, minimum 3 characters to maximum 20 chracters] \n");
       chomp($user_name=<STDIN>);
       if( $user_name =~ m/^[a-zA-Z]{3,20}$/)
       {
        print("Valid User Name:$user_name\n\n");
       }
       else
       {
         print("Entered User Name Is Invalid (You can give use this format:: [Alphabet character only allowed, minimum 3 characters to maximum 20 chracters] \n");
         my $reg=1;
         do {
            print("Try Again User Name \n");
            chomp($user_name=<STDIN>);
            if($user_name =~ m/^[a-zA-Z]{3,20}$/)
            {
              print("Valid User Name:$user_name\n\n");
            $reg=5; 
            }
            if($reg==2)
            {
              print("This is your last attempt\n");
            }
            $reg++;
           } while($reg<4);
       }
  		
		print("Enter password: [Alphabet character and numbers are allowed, minimum 3 character and maximum 20 chracter]\n");
       chomp($user_password=<STDIN>);
       if( $user_password =~ m/^(\w+){3,20}$/)
       {
          print("Valid password:$user_password\n\n");
       }
       else
       {
         print("Entered password is invalid (You can give use this format:: [Alphabet character and numbers are allowed, minimum 3 character and maximum 20 chracter] \n");
         my $reg=1;
         do {
            print("Try again password\n");
            chomp($user_password=<STDIN>);
            if($user_password =~ m/^(\w+){3,20}$/)
            {
              print("Valid password:$user_password\n\n");
              $reg=5; 
            }
            if($reg==2)
            {
              print("This is your last attempt\n");
            }
            $reg++;
           } while($reg<4);
       }
				
       print("Enter your Mobile Number: country code(2 digit) and Number(10 digit) [xx-xxxxxxxxxx]\n");
       chomp($mobile_number=<STDIN>);
       if( $mobile_number =~ m[^(\d{2})-(\d{10})$])
       {
         print("Valid Mobile Number:$mobile_number\n\n");
       }
       else
       {
          print("Entered Mobile Number Is Invalid (You can use this format:: country code(2 digit) and Number(10 digit) [xx-xxxxxxxxxx]) \n");
          my $reg_num=1;
           do {
              print("Try Again Mobile Number \n");
              chomp($mobile_number=<STDIN>);
              if($mobile_number =~ m[^(\d{2})-(\d{10})$])
              {
                print("Valid Mobile Number:$mobile_number\n\n");
               $reg_num=5; 
              }
              if($reg_num==2)
              {
                print("This is your last attempt\n");
              }
              $reg_num++;
             } while($reg_num<4);
       }
	
	    my $tablename = "user_verification.dbo.user_verification";
   		my $query_option ='read';
   		my $enable_ret=1;
   		my @db_array=();
        my ($ok_db,$ref_db)=MUTHUKUMAR_DB::database_req(tablename=>$tablename,query_option=> $query_option);
        if(!$ok_db)
   		{
    		die"Issues observed while calling user_verification_db::MUTHUKUMAR_DB::database_req function";
    	} 
		my ($ok_db_ret,$ref_db_ret)= db_execute_retrive(@_, ref_db => $ref_db,_user_mob => $mobile_number, enable_ret => $enable_ret);
		if(!$ok_db_ret)
   		 {
    		die"Issues observed while calling user_verification_db::db_execute_retrive function";
    	}
		@db_array=@$ref_db_ret;    
	 	if(@db_array)
	 	{
			if($db_array[0] eq $user_name and $db_array[1] eq $user_password and $db_array[2] eq $mobile_number)
   	 		{
   	 			print "LOGIN SUCCESSFUL for user : $user_name\n";
   	 			$login_success = 1;
   	 			$user_nameget->{user_name}=$user_name;
   	 		}
   	 		elsif($db_array[0] eq $user_name and $db_array[1] eq $user_password)
   	 		{
   	 			print "$user_name and $user_password : entrys are correct\n";
   	 		}
   	 		elsif($db_array[1] eq $user_password and $db_array[2] eq $mobile_number)
   	 		{
   	 			print "$user_password and $mobile_number : entrys are correct\n";
   	 		}
   	 		elsif($db_array[0] eq $user_name and $db_array[2] eq $mobile_number)
   	 		{
   	 			print "$user_name and $mobile_number : entrys are correct\n";
   	 		}
   	 		elsif($db_array[0] eq $user_name)
   	 		{
   	 			print "$user_name : entry only correct\n"
   	 		}
   	 		elsif($db_array[1] eq $user_password)
   	 		{
   	 			print "$user_password : entry only correct\n"
   	 		}
   	 		elsif($db_array[2] eq $mobile_number)
   	 		{
   	 			print "$mobile_number : entry only correct\n"
   	 		}
   	 		else
   	 		{
   	 			print "LOGIN FAILED for $user_name\n";
   	 		}
	 	}
	 	else
	 	{
	 		print "warn\t Database entries are not matched with user given datas\n";
	 	} 
 return $login_success,$user_nameget,$mobile_number;
}


sub user_operation_db
{
	 my %i=@_;
	 my $username= $i{_username};
	 my $user_mob = $i{_user_mob};
	 my (%db_operation,$ok_opt,$ref_opt);
	 my $operation_select=undef;
	 my $string =0;
	 my $inc=0;
	 print("======= User : $username->{user_name} choose your operations =======\n");
	 print("======= SELECT-1 READ\tSELECT-2 INSERT\tSELECT-3 UPDATE\tSELECT-4 DELETE\tSELECT-5 EXIT =======\n");
	%db_operation=(
		'1'=>'read',
		'2'=>'insert',
		'3'=>'update',
		'4'=>'delete',
		'5'=>'exit',
		);
 	 		do
 	 		 {
 	 			($ok,$mm)=STDIN(string => $string);
 	 			if(!$ok)
 	 			{
 	 				die"Issues observed while getting user input";
 	 			}
 	 			$operation_select=$db_operation{$mm};
 	 			($ok_opt,$ref_opt) = db_executable(operation_select => $operation_select, _user_mob => $user_mob);
 	 			if(!$ok_opt)
 	 			{
 	 				die"Issues observed while calling db_executable function";
 	 			}
 	 		}
 	 		until(defined $mm and $mm >= 5 or (defined $mm and $mm ==0 || $mm == -1 ) );
	return 1;
}


	
sub db_executable
{
	my %i=@_;
	my $tablename = "user_verification.dbo.user_verification";
	my $operation_select = $i{operation_select};
	my $enable_ret_db_executable=0;
	my $string =1;
	my ($ins_user_name,$ins_user_password, $ins_mobile_number,
	$upd_user_name,$upd_user_password, $upd_mobile_number,
	$del_user_name,$del_user_password, $del_mobile_number,
	);
	if($operation_select =~ /insert|post/i)
	{
		print "Please enter $operation_select datas\n";
		print "Enter $operation_select user_name\n";
		($ok,$ins_user_name)=STDIN(string => $string);
 	 	if(!$ok)
 	 	{
 	 		die"Issues observed while getting user input";
 	 	}
 	 	print "Enter $operation_select user_password\n";
 	 	($ok,$ins_user_password)=STDIN(string => $string);
 	 	if(!$ok)
 	 	{
 	 		die"Issues observed while getting user input";
 	 	}
 	 	print "Enter $operation_select mobile_number\n";
 	 	($ok,$ins_mobile_number)=STDIN(string => $string);
 	 	if(!$ok)
 	 	{
 	 		die"Issues observed while getting user input";
 	 	}
	}
	if($operation_select =~ /update|patch/i)
	{
		print "Please enter $operation_select datas\n";
		($ok,$upd_user_name)=STDIN(string => $string);
 	 	if(!$ok)
 	 	{
 	 		die"Issues observed while getting user input";
 	 	}
 	 	($ok,$upd_user_password)=STDIN(string => $string);
 	 	if(!$ok)
 	 	{
 	 		die"Issues observed while getting user input";
 	 	}
 	 	($ok,$upd_mobile_number)=STDIN(string => $string);
 	 	if(!$ok)
 	 	{
 	 		die"Issues observed while getting user input";
 	 	}
	}
	if($operation_select =~ /remove|delete/i)
	{
		print "Please enter $operation_select datas\n";
# future plan 
=b		
		($ok,$del_user_name)=STDIN();
 	 	if(!$ok)
 	 	{
 	 		die"Issues observed while getting user input";
 	 	}
 	 	($ok,$del_user_password)=STDIN();
 	 	if(!$ok)
 	 	{
 	 		die"Issues observed while getting user input";
 	 	}
=cut 	 	 	 	
 	 	($ok,$del_mobile_number)=STDIN(string => $string);
 	 	if(!$ok)
 	 	{
 	 		die"Issues observed while getting user input";
 	 	}
	}
	
	
    my ($ok_db,$ref_db)=MUTHUKUMAR_DB::database_req(tablename=>$tablename,query_option=> $operation_select,
    ins_user_name => $ins_user_name,ins_user_password => $ins_user_password,ins_mobile_number => $ins_mobile_number,
    upd_user_name => $upd_user_name,upd_user_password => $upd_user_password,upd_mobile_number => $upd_mobile_number,
    del_user_name => $del_user_name,del_user_password => $del_user_password, del_mobile_number => $del_mobile_number,
    );
    if(!$ok_db)
    {
    	die"Issues observed while calling db_executable::MUTHUKUMAR_DB::database_req function";
    } 
    if($operation_select !~ /read|get|exit/i)
    {
    	print "Query execution after database data:";
    	$operation_select = 'read';
    	($ok_db,$ref_db)=MUTHUKUMAR_DB::database_req(tablename=>$tablename,query_option=> $operation_select);
    	if(!$ok_db)
    	{
    		die"Issues observed while calling db_executable::MUTHUKUMAR_DB::database_req function";
    	} 
    }
      
	my ($ok_db_ret,$ref_db_ret)= db_execute_retrive(@_, ref_db => $ref_db, enable_ret => $enable_ret_db_executable );
	if(!$ok_db_ret)
    {
    	die"Issues observed while calling db_execute_retrive function";
    }
    
     print "db_array".Dumper(\$ref_db_ret);
	return 1;
}

sub db_execute_retrive
{
	    my %i=@_;
	    my $ref_db = $i{ref_db};
	    my $user_mob = $i{_user_mob};
	    my @db_array=();
		my $enable_ret=$i{enable_ret};
	foreach my $each_key(keys %$ref_db)
	{
	foreach my $each_key_val( @{$ref_db->{$each_key}})
	{
		foreach my $each_key_hash (keys %$each_key_val)
		{
		if($enable_ret)	
		{
			if(defined $each_key_hash and $each_key_hash eq $user_mob)
			{	
				foreach my $each_db_key(keys %{$each_key_val->{$each_key_hash}})
				{
					if(defined $each_db_key and $each_db_key eq 'user_name')
					{
						($db_array[0]="$each_key_val->{$each_key_hash}->{$each_db_key}");
					}
					if(defined $each_db_key and $each_db_key eq 'user_password')
					{
						($db_array[1]="$each_key_val->{$each_key_hash}->{$each_db_key}");
					}	
					if(defined $each_db_key and $each_db_key eq 'mobile_number')
					{
		  				($db_array[2]="$each_key_val->{$each_key_hash}->{$each_db_key}");
					}
				}
			}
		}
		else
		{
			if(defined $each_key_hash )
			{	
				foreach my $each_db_key(keys %{$each_key_val->{$each_key_hash}})
				{
					if(defined $each_db_key and $each_db_key eq 'user_name')
					{
						push(@db_array,"$each_key_val->{$each_key_hash}->{$each_db_key}");
					}
					if(defined $each_db_key and $each_db_key eq 'user_password')
					{
						push(@db_array,"$each_key_val->{$each_key_hash}->{$each_db_key}");
					}	
					if(defined $each_db_key and $each_db_key eq 'mobile_number')
					{
		  				push(@db_array,"$each_key_val->{$each_key_hash}->{$each_db_key}");
					}
				}
			}
		}
		}
	}
	}
       
        return 1,\@db_array;
}

sub STDIN
	{
		my %i=@_;
		my $string = $i{string}; 
		my $mm;
		chomp($mm=<STDIN>);
		if(defined $mm and $mm ne '')
		{ 
			if($string)
			{
				if($mm =~ /skip/i)
				{
					return 1,undef;
				}
			return 1,$mm;
			}
			else
			{
				if($mm >5 || $mm ==0 || $mm == -1)
      			{
    				die"User given entry is invalid";
      			}
      			else
				{
					if($mm =~ /skip/i)
					{
						return 1,undef;
					}
				return 1,$mm;
				}
			}
		}
		return 0,undef;
	}


sub userverification
{
	 my %i=@_;
	 my $reg;
	print("=======How Many Details=======\n");
	chomp($mm=<STDIN>);
	if(defined $mm and $mm ne '')
	{
	if($mm>0)
	{
   while($int1<$mm)
   {
       print("Enter Your Name: [Alphabet character only allowed, minimum 3 characters to maximum 20 chracters] \n");
       chomp($num=<STDIN>);
       if( $num =~ m/^[a-zA-Z]{3,20}$/)
       {
        print("Valid Name:$num\n\n");
       }
       else
       {
         print("Entered Name Is Invalid (You can give use this format:: [Alphabet character only allowed, minimum 3 characters to maximum 20 chracters] \n");
         my $reg=1;
         do {
            print("Try Again Name \n");
            chomp($num=<STDIN>);
            if($num =~ m/^[a-zA-Z]{3,20}$/)
            {
              print("Valid Name:$num\n\n");
            $reg=5; 
            }
            if($reg==2)
            {
              print("This is your last attempt\n");
            }
            $reg++;
           } while($reg<4);
       }

       print("Enter your mobile number: country code(2 digit) and Number(10 digit) [xx-xxxxxxxxxx]\n");
       chomp($num2=<STDIN>);
       if( $num2 =~ m[^(\d{2})-(\d{10})$])
       {
         print("Valid Number:$num2\n\n");
       }
       else
       {
          print("Entered Number Is Invalid (You can use this format:: country code(2 digit) and Number(10 digit) [xx-xxxxxxxxxx]) \n");
          my $reg_num=1;
           do {
              print("Try Again Number \n");
              chomp($num2=<STDIN>);
              if($num2 =~ m[^(\d{2})-(\d{10})$])
              {
                print("Valid Number:$num2\n\n");
               $reg_num=5; 
              }
              if($reg_num==2)
              {
                print("This is your last attempt\n");
              }
              $reg_num++;
             } while($reg_num<4);
       }
       my %hashdata=($num=>$num2);
       my @name=keys%hashdata;
       my @mobile_number=values%hashdata;  #mobile number
       my $i=0;
      foreach my $var(@mobile_number)
      {      
      if(defined $var and $var ne ''and $var=~ m[^(\d{2})-(\d{10})$])
      {
         print("======= Welcome $name[$i]=======\n\n");
         print(">>>Phone Number is $var<<<\n\n\n");	  #@array2=split('-',$var);
         $var=~m[-];
        if($`==91)  
        { 
          print("$`-$' | indian|\n\n");
          if(exists($hashdata{'muthu'}))
          {
            print("$name[0] exists\n");
          }
          elsif ($hashdata{'john'})
          {
            print("$name[0] exists\n");
          }
          elsif ($hashdata{'prem'})
          {
            print("$name[0] exists\n");
          }
          else
          {
            print("Name Does Not Exists\n");
          }
       }
       else
       {
         print("$var","|not indian|\n");
       }
      } #if end
      else
      {
        die"User details empty";
      }
      $i++;
     } #mobile array foreach end
      $int1++;
    } #while end
       print("===========End===========\n");
   } #if end
   }
   else
   {
     print("'Error' You should Enter Least one data\n");
   }

 return 1;
}

sub registration
{
  my %i=@_;
  my ($fname,$sname,$uname,$dob,$email,$password,$cpassword);
  print("Enter first name: [Alphabet character only allowed, minimum 3 character to maximum 20 chracter]\n");
  try_again_registration:chomp($fname=<STDIN>);
  if( $fname =~ m/^[a-zA-Z]{3,20}$/)
       {
        print("Valid first name:$fname\n\n");
       }
       else
       {
         print("Entered first name is invalid: (You can give use this format:: [Alphabet character only allowed, minimum 3 character to maximum 20 chracter] \n");
         my $reg=1;
         do {
            print("Try again first name \n");
            chomp($fname=<STDIN>);
            if($fname =~ m/^[a-zA-Z]{3,20}$/)
            {
              print("Valid first name:$fname\n\n");
              $reg=5;
            }
            if($reg==2)
            {
              print("This is your last attempt\n");
            }
            $reg++;
           } while($reg<4);
       }
  print("Enter second name: [Alphabet character only allowed, minimum 1 character to maximum 20 chracter] \n");
  chomp($sname=<STDIN>);
  if( $sname =~ m/^[a-zA-Z]{1,20}$/)
       {
        print("Valid second name:$sname\n\n");
       }
       else
       {
         print("Entered second name is invalid (You can give use this format:: [Alphabet character only allowed, minimum 3 character to maximum 20 chracter] \n");
         my $reg=1;
         do {
            print("Try again second name \n");
            chomp($sname=<STDIN>);
            if($sname =~ m/^[a-zA-Z]{1,20}$/)
            {
              print("Valid second name:$sname\n\n");
              $reg=5; 
            }
            if($reg==2)
            {
              print("This is your last attempt\n");
            }
            $reg++;
           } while($reg<4);
       }
  print("Enter user name: [Alphabet character and numbers are allowed, minimum 3 character and maximum 20 chracter]\n");
   chomp($sname=<STDIN>);
  if( $sname =~ m/^(\w+){3,20}$/)
       {
        print("Valid user name:$sname\n\n");
       }
       else
       {
         print("Entered user name is invalid (You can give use this format:: [Alphabet character and numbers are allowed, minimum 3 character and maximum 20 chracter] \n");
         my $reg=1;
         do {
            print("Try again user name\n");
            chomp($sname=<STDIN>);
            if($sname =~ m/^(\w+){3,20}$/)
            {
              print("Valid user name:$sname\n\n");
              $reg=5; 
            }
            if($reg==2)
            {
              print("This is your last attempt\n");
            }
            $reg++;
           } while($reg<4);
       }
     
  print("Enter your date of birth: Example- [dd/mm/yyyy] or [dd-mm-yyyy] or [dd.mm.yyyy]\n");
  print ("NOTE:- Date of birth is not equal to today or future date!!!\n");
  my $current_timedate=strftime "%d/%m/%Y",localtime; 
  my $current_time=strftime "%H:%M:%S",localtime;
  print("Current time:$current_time\n");
  chomp($dob=<STDIN>);
       my $date_split_final='/';
       my $dateformat;
       my $original_date;
       my $original_date_match;
       if( $dob =~ m/^(?=\d)(?:(?!(?:(?:0?[5-9]|1[0-4])(?:\.|-|\/)10(?:\.|-|\/)(?:1582))|(?:(?:0?[3-9]|1[0-3])(?:\.|-|\/)0?9(?:\.|-|\/)(?:1752)))(31(?!(?:\.|-|\/)(?:0?[2469]|11))|30(?!(?:\.|-|\/)0?2)|(?:29(?:(?!(?:\.|-|\/)0?2(?:\.|-|\/))|(?=\D0?2\D(?:(?!000[04]|(?:(?:1[^0-6]|[2468][^048]|[3579][^26])00))(?:(?:(?:\d\d)(?:[02468][048]|[13579][26])(?!\x20BC))|(?:00(?:42|3[0369]|2[147]|1[258]|09)\x20BC))))))|2[0-8]|1\d|0?[1-9])([-.\/])(1[012]|(?:0?[1-9]))\2((?=(?:00(?:4[0-5]|[0-3]?\d)\x20BC)|(?:\d{4}(?:$|(?=\x20\d)\x20)))\d{4}(?:\x20BC)?)(?:$|(?=\x20\d)\x20))?((?:(?:0?[1-9]|1[012])(?::[0-5]\d){0,2}(?:\x20[aApP][mM]))|(?:[01]\d|2[0-3])(?::[0-5]\d){1,2})?$/)
       {
         $original_date=$dob;
       my @original_date_array=split (/[\.\-\/]/,$original_date);
       $original_date= "$original_date_array[0]$date_split_final$original_date_array[1]$date_split_final$original_date_array[2]";
        $dateformat = "%d$date_split_final%m$date_split_final%Y";
        $current_timedate = Time::Piece->strptime($current_timedate, $dateformat);
        $original_date_match = Time::Piece->strptime($original_date, $dateformat);
          if ($original_date_match < $current_timedate) 
          {
            print "$original_date is valid date of birth\n";
          } 
          else
          {
            die"Issues observed while comparing current date and user registration date";
          }
        }
        else  
        {
          print("Entered date of birth is invalid: (You can give use this format:: [dd/mm/yyyy] or [dd-mm-yyyy] or [dd.mm.yyyy] \n");
         my $reg=1;
         do {
            print("Try again date of birth\n");
            chomp($dob=<STDIN>);
       if( $dob =~ m/^(?=\d)(?:(?!(?:(?:0?[5-9]|1[0-4])(?:\.|-|\/)10(?:\.|-|\/)(?:1582))|(?:(?:0?[3-9]|1[0-3])(?:\.|-|\/)0?9(?:\.|-|\/)(?:1752)))(31(?!(?:\.|-|\/)(?:0?[2469]|11))|30(?!(?:\.|-|\/)0?2)|(?:29(?:(?!(?:\.|-|\/)0?2(?:\.|-|\/))|(?=\D0?2\D(?:(?!000[04]|(?:(?:1[^0-6]|[2468][^048]|[3579][^26])00))(?:(?:(?:\d\d)(?:[02468][048]|[13579][26])(?!\x20BC))|(?:00(?:42|3[0369]|2[147]|1[258]|09)\x20BC))))))|2[0-8]|1\d|0?[1-9])([-.\/])(1[012]|(?:0?[1-9]))\2((?=(?:00(?:4[0-5]|[0-3]?\d)\x20BC)|(?:\d{4}(?:$|(?=\x20\d)\x20)))\d{4}(?:\x20BC)?)(?:$|(?=\x20\d)\x20))?((?:(?:0?[1-9]|1[012])(?::[0-5]\d){0,2}(?:\x20[aApP][mM]))|(?:[01]\d|2[0-3])(?::[0-5]\d){1,2})?$/)
       {
        $original_date=$dob;
        my @original_date_array=split (/[\.\-\/]/,$original_date);
        $original_date= "$original_date_array[0]$date_split_final$original_date_array[1]$date_split_final$original_date_array[2]";
        $dateformat = "%d$date_split_final%m$date_split_final%Y";
        $current_timedate = Time::Piece->strptime($current_timedate, $dateformat);
        $original_date_match = Time::Piece->strptime($original_date, $dateformat);
          if ($original_date_match < $current_timedate) 
          {
            print "$original_date is valid date of birth\n";
          } 
          else
          {
            die"Issues observed while comparing current date and user registration date";
          }
              $reg=5; 
            }
            if($reg==2)
            {
              print("This is your last attempt\n");
            }
            $reg++;
           } while($reg<4);
        }
 
  print("Enter email-id: [Alphabet character,numbers and special characters [ '-' and/or '.' ] are allowed] Example: abcd_5.kum\@gmail.com\n");
    chomp($email=<STDIN>);
    # Pattern for Email validation 
    my $pattern= '^([a-zA-Z][\w\_\.]{3,15})\@([a-zA-Z0-9.-]+)\.([a-zA-Z]{2,4})$'; 
    # To find the length of Username from the emailid (i.e. aliencoders@aliencoders.com  The value before @ is username) 
    my @firstval=split('@',$email); 
    my $len=length($firstval[0]); 
    my $else_enable=0; 
    if($email=~m /$pattern/) 
    { 
      my $domain = $2; 
      # Matching and displaying the result accordingly 
      if($len>15 || $len<3) 
      { 
        print "Invalid email id.\nLength of Username is $len which is either >15 or <3 !!!"; 
        $else_enable=1;    
      } 
      if($domain=~ /^\-|\-$/) 
      { 
        print "Domain name can't start or end with -\n";
        $else_enable=1; 
      } 
      if($domain=~ /^\d+/)
      { 
        print "Domain Name can't start with Digit\n";
        $else_enable=1; 
      } 
      if(length($domain)>63 || length($domain) <2) 
      { 
        print "According to domain rule Domain length should lie between 3 and 63\n";
        $else_enable=1; 
      }     
    } 
    else 
    { 
      print "invalid email format\n"; 
      $else_enable=1;
    }
    if(!$else_enable)
    {
      print "Its a valid Email ID: $email\n"; 
    }
    else
    {
         print("Entered email id is invalid: (You can give use this format:: [Alphabet character,numbers and special characters [ '-' and/or '.' ] are allowed] Example: abcd_5.kum\@gmail.com\n");
         my $reg=1;
         my $pattern= '^([a-zA-Z][\w\_\.]{3,15})\@([a-zA-Z0-9.-]+)\.([a-zA-Z]{2,4})$';
         my $else_enable=0; 
         do {
          print("Try again email id\n");
          chomp($email=<STDIN>);
          # Pattern for Email validation 
            if($email=~m /$pattern/) 
            { 
            my $domain = $2; 
            # To find the length of Username from the emailid (i.e. aliencoders@aliencoders.com  The value before @ is username) 
            my @firstval=split('@',$email); 
            my $len=length($firstval[0]); 
            # Matching and displaying the result accordingly 
            if($len>15 || $len<3) 
            { 
              print "Invalid email id.\nLength of Username is $len which is either >15 or <3 !!!"; 
              $else_enable=1;    
            } 
            if($domain=~ /^\-|\-$/) 
            { 
                print "Domain name can't start or end with -\n";
                $else_enable=1; 
            } 
            if($domain=~ /^\d+/)
            { 
                print "Domain Name can't start with Digit\n";
                $else_enable=1; 
            } 
            if(length($domain)>63 || length($domain) <2) 
            { 
                print "According to domain rule Domain length should lie between 3 and 63\n";
                $else_enable=1; 
             }
             print "Its a valid Email ID: $email\n";
              $reg=5;     
            } 
            if($reg==2)
            {
              print("This is your last attempt\n");
            }
            $reg++;
           } while($reg<4); 
    }
 
  my $enable_confirm=0;
  do{
      if($enable_confirm == 1)
      {
        print("Try again password and confirm password\n");
        print("This is your last attempt\n");
       }
       print("Enter password: [Alphabet character and numbers are allowed, minimum 3 character and maximum 20 chracter]\n");
       chomp($password=<STDIN>);
       if( $password =~ m/^(\w+){3,20}$/)
       {
          print("Valid password:$password\n\n");
       }
       else
       {
         print("Entered password is invalid (You can give use this format:: [Alphabet character and numbers are allowed, minimum 3 character and maximum 20 chracter] \n");
         my $reg=1;
         do {
            print("Try again password\n");
            chomp($password=<STDIN>);
            if($password =~ m/^(\w+){3,20}$/)
            {
              print("Valid password:$password\n\n");
              $reg=5; 
            }
            if($reg==2)
            {
              print("This is your last attempt\n");
            }
            $reg++;
           } while($reg<4);
       }
       
       print("Enter confirm password: [Alphabet character and numbers are allowed, minimum 3 character and maximum 20 chracter]\n");
       chomp($cpassword=<STDIN>);
       if($cpassword =~ m/^(\w+){3,20}$/)
       {
          print("Valid confirm password:$cpassword\n\n");
       }
       else
       {
         print("Entered confirm password is invalid (You can give use this format:: [Alphabet character and numbers are allowed, minimum 3 character and maximum 20 chracter] \n");
         my $reg=1;
         do {
            print("Try again confirm password\n");
            chomp($cpassword=<STDIN>);
            if($cpassword =~ m/^(\w+){3,20}$/)
            {
              print("Valid confirm password:$cpassword\n\n");
              $reg=5; 
            }
            if($reg==2)
            {
              print("This is your last attempt\n");
            }
            $reg++;
           } while($reg<4);
       }
       print "mmm".Dumper(\$password,\$cpassword);
       if(defined $password and defined $cpassword )
       {
       		if(($password ne '' and $cpassword ne '' ) and ($password eq $cpassword))
       		{
         		print("Verified password and confirm password is equal \n\n");
				$enable_confirm=2;
       		}
       		else
       		{
         	die"password and confirm password is not equal !!!\n";
       		}
       }
       else
       {
         die"password and confirm password is not equal !!!\n";
       }
        $enable_confirm ++;
        }while($enable_confirm<2);
       print "====================Thank you==================\n";
       
 return 1; 
}

sub _option
{
 my %i=@_;
 my $fkey=$i{Option};
 #print "$fkey\n";

 return $fkey;
}

sub _user_name
{
 my %i=@_;
 my $fkey=$i{User_name};
 #print "$fkey\n";
 return $fkey;
}

sub _password
{
 my %i=@_;
my $fkey=$i{Password};
 #print "$fkey\n";
 return $fkey;
}