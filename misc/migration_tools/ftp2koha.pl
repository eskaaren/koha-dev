#!/usr/bin/perl 

# Copyright 2015 Magnus Enger Libriotech

=head1 NAME

ftp2koha.pl - Download MARC records from an FTP site and load them into Koha.

=head1 SYNOPSIS

 perl ftp2koha.pl --config my_config.yml -v

=cut

use Net::FTP;
use MARC::File::USMARC;
use MARC::File::XML;
use YAML::Syck;
use Getopt::Long;
use Data::Dumper;
use DateTime;
use Pod::Usage;
use Modern::Perl;

my $dt = DateTime->now;

# Get options
my ( $config_file, $filename, $test, $verbose, $debug ) = get_options();

=pod

=head1 CONFIGURATION

Most of the configuration of this script is done with a configuration file. See
the F<sample_config.yml> file provided with this script for an example, and 
read the comments in that file for details on how to configure it. 

=cut

# Check that the config file exists
if ( !-e $config_file ) {
    print "The file $config_file does not exist...\n";
    exit;
}
say "Using config from $config_file" if $verbose;
my $config = LoadFile( $config_file );

##  Get the file

# Figure out the filename and the local path for saving it
if ( $filename eq '' ) {
    # Construct the filename from the ftp_file config variable
    $filename = DateTime->now->subtract( hours => $config->{'subtract_hours'} )->strftime( $config->{'ftp_file'} );
}
my $local_path = $config->{'local_dir'} . $filename;
say "Going to download $filename to $local_path" if $verbose;

# Do the actual download
=pod
my $ftp = Net::FTP->new(
    $config->{'ftp_host'},
    'Debug' => $config->{'ftp_debug'}
) or die "Cannot connect to $config->{'ftp_host'}: $@";
$ftp->binary();
$ftp->login( $config->{'ftp_user'}, $config->{'ftp_pass'} ) or die "Cannot login ", $ftp->message;
$ftp->cwd( $config->{'ftp_path'} ) or die "Cannot change working directory ", $ftp->message;
$ftp->get( $filename, $local_path ) or die "Get failed ", $ftp->message;
$ftp->quit;
say "Download done" if $verbose;
=cut
# Check that the file now exists locally
if ( ! -f $local_path ) {
    die "$local_path does not exist!";
} else {
    say "Local file $local_path exists" if $verbose;
}

## Massage the MARC data

say "Starting to massage MARC records" if $verbose;
my $records_count = 0;
my $records = MARC::File::USMARC->in( $local_path );
my $output_file = $local_path . '.marcxml';
my $xmloutfile = MARC::File::XML->out( $output_file );
while ( my $record = $records->next() ) {

    my $field952 = MARC::Field->new( 952, ' ', ' ',
        'a' => $config->{'952a'}, # Homebranch
        'b' => $config->{'952b'}, # Holdingbranch
        'y' => $config->{'952y'}, # Item type
    );
    $record->insert_fields_ordered( $field952 );
    $xmloutfile->write($record);
    $records_count++;
    say "$records_count: " . $record->title if $verbose;

}
$xmloutfile->close();
say "Done ($records_count records)" if $verbose;

## Import the file into Koha

my $bulkmarcimport_verbose = $verbose ? '-v' : '';
my $cmd = "sudo koha-shell -c \"perl $config->{'bulkmarcimport_path'} -b $bulkmarcimport_verbose -m=MARCXML -file $output_file\" $config->{'koha_site'}";
if ( $verbose ) {
    say $cmd;
    say `$cmd` unless $test; # Do not perform the actual import if we have --test
    say "Import done";
} else {
    `$cmd`;
}

## Optional cleanup

if ( $config->{'cleanup'} ) {
    unlink $local_path;
    say "$local_path deleted" if $verbose;
    unlink $output_file;
    say "$output_file deleted" if $verbose;
}

say "*** This was a test run, no records were imported ***" if $test;

=head1 OPTIONS

=over 4

=item B<-c, --config_file>

Path to config file.

=item B<-f, --filename>

Provide a specific filename to look for on the FTP server. This will override 
the filename created from the B<ftp_file> config variable.

This is useful if you need to download files that are older than the current 
date, or if the remote file always has the same name, regardless of the date.

=item B<-t, --test>

Perform all steps, except the actual import of records. Also turns on verbose 
mode.

=item B<-v --verbose>

More verbose output.

=item B<-d --debug>

Even more verbose output.

=item B<-h, -?, --help>

Prints this help message and exits.

=back
                                                               
=cut

sub get_options {

    # Options
    my $config_file = '';
    my $filename    = '';
    my $test        = '';
    my $verbose     = '';
    my $debug       = '';
    my $help        = '';

    GetOptions (
        'c|config=s'   => \$config_file,
        'f|filename=s' => \$filename,
        't|test'       => \$test,
        'v|verbose'    => \$verbose,
        'd|debug'      => \$debug,
        'h|?|help'     => \$help
    );

    pod2usage( -exitval => 0 ) if $help;
    pod2usage( -msg => "\nMissing Argument: -c, --config required\n", -exitval => 1 ) if !$config_file;
    
    # Test mode should always be verbose
    $verbose = 1 if $test;

    return ( $config_file, $filename, $test, $verbose, $debug );

}

=head1 AUTHOR

Magnus Enger, magnus [at] libriotech.no

=head1 LICENSE

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
