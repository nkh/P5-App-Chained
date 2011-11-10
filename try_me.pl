
package App::Chained::Test ;

use strict ;
use warnings ;
use Carp ;
use English qw( -no_match_vars ) ;

use lib qw(lib) ;
use parent 'App::Chained' ;

our $VERSION = '0.02' ;

=head1 Doc

blah blah

=cut


sub run
{
my ($invocant, @setup_data) = @_ ;

my $class = ref($invocant) || $invocant ;
confess 'Invalid constructor call!' unless defined $class ;

my %options = (A => 'default', B => undef) ;

my $chained_app = 
	App::Chained->new
		(
		INTERACTION => {WARN => sub {warn @_}},
		
		help => \&App::Chained::get_help_from_pod, 
		version =>  $VERSION,
		apropos => undef,
		faq => undef,
		
		getopt_data => 	
			[
				['A=s' => \$options{A}, 'test from hash', 'long description'],
				['B' => \$options{B}, 'test from hash', 'long description'],
				['CCC|C=s' => \my $option, 'description', 'long description'],
			],
		
		sub_apps =>
			{
			check =>
				{
				description => 'does a check',
				run =>
					sub
					{
					my ($self, $command, $arguments) =  @_ ;
					system 'ra_check.pl ' . join(' ', @{$arguments}) ;
					},
					
				help => sub {system "ra_check.pl --help"},
				apropos => [qw(verify check error test)],
				#~ bash completion => from 'options' or a sub in the script
				},
			
			'check_2' =>
				{
				description => undef,
				run => # todo provide a default wrapper
					sub 
					{
					my ($self, $command, $arguments) =  @_ ;
					
					eval 'use My::Module ; My::Module::Run($arguments)' ;
					$self->{INTERACTION}{DIE}("Error: Module '$self->{parsed_command}' run returned:\n\n" . $@)	if($@) ;
					} ,
					
				apropos => [qw(check)],
				#~ bash completion => from 'options' or a sub in the script
				},
			
			'run' =>
				{
				description => 'run test',
				run => sub {print "run command run was here!\n"}, 
				help => sub{print "run command help was here!\n"},
				apropos => [qw(run)],
				#~ bash completion => from 'options' or a sub in the script
				},
			
			'run_error' =>
				{
				description => 'run test but fails',
				run => undef, # this is the error
				
				#~ bash completion => from 'options' or a sub in the script
				},
			},
			
		@setup_data,
		) ;

bless $chained_app, $class ;

$chained_app->parse_command_line() ;

# pass option  A and B to our sub command
#~ push @{$chained_app->{command_options}}, ('--A' => $options{A} ) if defined $options{A} ;
#~ push @{$chained_app->{command_options}}, ('--B_changed_to_X' => $options{B} ) if defined $options{B} ;

#~ use Data::TreeDumper ;
#~ print DumpTree $chained_app->{command_options}, 'options' ;

# run the command if we so want
$chained_app->SUPER::run() ;
}

#---------------------------------------------------------------------------------

package main ;

App::Chained::Test->run(command_line_arguments => \@ARGV) ;

