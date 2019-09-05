package MUTHUKUMAR_DB_AUTOLAOD;
#===============================
# Author: Muthukumar Subramanian
# v2018.03.03.01 - Dynamically autoload module
use Data::Dumper;
use Sub::Identify ':all';
#use File::Basename;
#use Cwd qw(getcwd);
use strict;
use warnings;
 		use constant {
    		user => 'user_lib',
    		DB => 'MUTHUKUMAR_DB',
    	};
 
		 my %module_map = (
  		  abcd => user,
  		  calc => user,
  		  database_req => DB,
  		  _read_query => DB
			);
    # Global variable
	my %hash_pass;
    my $catch_module;
    my $dir;
    
	sub main_autoload_callback
	{
    	my %i = @_;
        my ($ok_ac,$ref_ac)= autoload_callback(@_,
       _directory =>{coderef =>\&dir_open_read},
       );
       if($ok_ac)
		{
			print "function: autoload_callback execution completed\n";
		}
		else
		{
 			die"Something wrong in fuction autoload_callback\n";
		}
  		 return 1,$ref_ac;
	}
	sub autoload_callback
	{
 		my %i=@_;
 		my $_directory =$i{_directory};
		my ($ok_ret,$reff_ret,@call_array);
 		if(defined $_directory)
 		{
  			 push( @call_array,$_directory);
 		}

  		foreach my $one_by_one(@call_array) 
  		{  
 			my $ref=sub_fullname($one_by_one->{coderef});
 			print "Executing: $ref \n";
 			#($okk,$reff)=&{$one_by_one->{coderef}}(@_);
    		# OR
    		{
    			no strict 'refs';
 			($ok_ret,$reff_ret)= &$ref(@_);
	 		if(!$ok_ret)
	 		{
	 			die "Issues observed while executing $ref \n";
	 		}
    		}
		}
		return 1,$reff_ret;
	}

		sub dir_open_read
		{
			my %i =@_;
   			 # Display all the C source files in /tmp directory.
    	 	 #my $dir = "C:\\Users\\subramam\\Documents\\";
    	 	 
    	 	 my $lib_dir_access = (defined $i{_HASH}->{lib_dir_access})? $i{_HASH}->{lib_dir_access} : die "Argument required\n";
    	 	 if($lib_dir_access)
    	 	 {
    	 	 	$dir ="C:\\Strawberry\\perl\\vendor\\lib\\";
    	 	 }
    	 	 else
    	 	 {
				$dir = "C:\\Users\\muthukumar\\Documents\\";
    	 	 }
    		
    		opendir(D, "$dir") || die "Can't open directory $dir: $!\n";
    		my @list = readdir(D);
    		closedir(D);
    		my @lib_array =();
    		my $run;

    		foreach my $func_name (@list) 
    		{
        		if(defined $func_name and $func_name =~ /.*.pm/g )
        		{
	    			$func_name =~ s /.pm//;
	  				#print "INSIDE_file\n".Dumper(\$func_name);
	   				push(@lib_array,$func_name);
        		}    
    		}
    		 my ($ok_ret,$ref_ret) = AUTOLOAD(@_,lib_array => \@lib_array);
    		 if(!$ok_ret)
	 		 {
	 			die "Issues observed while executing AUTOLOAD \n";
	 		 }
    		return 1,$ref_ret;
		}
 
    sub AUTOLOAD 
    {
        my %i = @_;
        my $method = $i{_HASH}->{method};
        my $lib_array = $i{lib_array};
   	    #my $module;# = $module_map{user_lib};
   	    foreach my $hash_module (keys %module_map)
		{
			print "hash_module:".Dumper\$hash_module;
    	foreach my $mm (@$lib_array)
    	{
     	 	 $catch_module = $mm if($mm eq $module_map{$hash_module});
   		}
		}
		my $ul_muthu = 'MUTHUKUMAR_DB_AUTOLAOD';
		print "hash_module:".Dumper\$ul_muthu;
		 my $func_name ="$ul_muthu::AUTOLOAD"; 
    # Remove the leading ul_fos which is part of $func_name
    $func_name =~ s/MUTHUKUMAR_DB_AUTOLAOD:://;

    # Get the module that needs to be loaded in order to execute the function
    my $catch_module = $module_map{$func_name};
    
    	# If the users forgot to define the module for this function, die with an easy
   	    # to understand error message
    	if (!$catch_module)
    	 {
       		 die "Attemping to call function func_name that isn't defined in the module_map";
   	 	 }

    	# Dynamically load the necessary module for this function call
    	require "$dir$catch_module.pm";
    
    	# Create a string to call the function
    	my $run = $catch_module . '::' . "$method";

    	# This code is blocked so that I can temporarily turn off strict 'refs'
    	# so that I can call a subroutine as a ref without errors
   	 	{
        	no strict 'refs';
        	return &$run(@_);
   	 	}
}  

1; 