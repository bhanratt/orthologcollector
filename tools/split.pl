#!/usr/bin/perl
use strict;
use Getopt::Long;
# qw(:config no_ignore_case no_auto_abbrev pass_through);
use Pod::Usage;
# BEGIN {
# use Ergatis::Logger;
# }

my %options = ();
my $results = GetOptions (\%options, 
                          'input_file|i=s',
                          'output_dir|o=s',
                          'output_file_prefix|f=s',
                          'output_list|s=s',
                          'output_subdir_size|u=s',
                          'output_subdir_prefix|p=s',
                          'seqs_per_file|n|e=s',
                          'compress_output|c=s',
                          'log|l=s',
                          'debug=s',
                          'help|h') || pod2usage();

# my $logfile = $options{'log'} || Ergatis::Logger::get_default_logfilename();
# my $logger = new Ergatis::Logger('LOG_FILE'=>$logfile,
#                                   'LOG_LEVEL'=>$options{'debug'});
# $logger = $logger->get_logger();


my $logfile = $options{'log'} || "log.file";
my $logger = new logger('LOG_FILE'=>$logfile,
                       'LOG_LEVEL'=>$options{'debug'});

## display documentation
if( $options{'help'} ){
    pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} );
}

## make sure everything passed was peachy
&check_parameters(\%options);

## open the list file if one was passed
my $listfh;
if (defined $options{output_list}) {
    open($listfh, ">$options{output_list}") || $logger->logdie("couldn't create $options{output_list} list file");
}

my $first = 1;
my $seq = '';
my $header;

my $sfh;

## load the sequence file
if ($options{'input_file'} =~ /\.(gz|gzip)$/) {
    open ($sfh, "<:gzip", $options{'input_file'})
      || $logger->logdie("can't open sequence file:\n$!");
} else {
    open ($sfh, "<$options{'input_file'}")
      || $logger->logdie("can't open sequence file:\n$!");
}

my $sub_dir = 1;
my $seq_file_count = 0;

## keep track of how many sequences are in the current output file
my $seqs_in_file = 0;
my $group_filename_prefix = 1;

## holds the output file handle
my $ofh;

while (<$sfh>) {
    ## if we find a header line ...
    if (/^\>(.*)/) {

        ## write the previous sequence before continuing with this one
        unless ($first) {
            &writeSequence(\$header, \$seq);
            
            ## reset the sequence
            $seq = '';
        }

        $first = 0;
        $header = $1;

    ## else we've found a sequence line
    } else {
        ## skip it if it is just whitespace
        next if (/^\s*$/);

        ## record this portion of the sequence
        $seq .= $_;
    }
}

## don't forget the last sequence
&writeSequence(\$header, \$seq);

exit;

sub check_parameters {
    my $options = shift;
    
    ## make sure input_file and output_dir were passed
    unless ( $options{input_file} && $options{output_dir} ) {
        $logger->logdie("You must pass both --input_file and --output_dir");
    }
    
    ## make sure input_file exists
    if (! -e $options{input_file} ) {
        if ( -e "$options{input_file}.gz" ) {
            $options{input_file} .= '.gz';
        } else {
            $logger->logdie("the input file passed ($options{input_file}) cannot be read or does not exist");
        }
    }
    
    ## make sure the output_dir exists
    if (! -e "$options{output_dir}") {
        $logger->logdie("the output directory passed could not be read or does not exist");
    }
    
    ## seqs_per_file, if passed, must be at least one
    if (defined $options{seqs_per_file} && $options{seqs_per_file} < 1) {
        $logger->logdie("seq_per_file setting cannot be less than one");
    }
    
    ## handle some defaults
    $options{output_subdir_size}   = 0  unless ($options{output_subdir_size});
    $options{output_subdir_prefix} = '' unless ($options{output_subdir_prefix});
    $options{seqs_per_file}        = 1  unless ($options{seqs_per_file});
    $options{output_file_prefix} = '' unless ($options{output_file_prefix});
}

sub writeSequence {
    my ($header, $seq) = @_;
    
    ## the id used to write the output file will be the first thing
    ##  in the header up to the first whitespace.  get that.
    $$header =~ /^(\S+)/ || $logger->logdie( "can't pull out an id on header $$header" );
    my $id = $1;
    
    ## because it is going to be the filename, we're going to take out the characters that are bad form to use
    ## legal characters = a-z A-Z 0-9 - . _
    $id =~ s/[^a-z0-9\-_.]/_/gi;
    
    my $dirpath;
    
    ## if we're writing more than one sequence to a file, change the id from
    ##  fasta header to the current group file name
    if ($options{seqs_per_file} > 1) {
        $id = $group_filename_prefix;
        
        ## did the user ask for a file prefix?
        if ( $options{output_file_prefix} ) {
            $id = $options{output_file_prefix} . $id;
        }
    }

    
    ## the path depends on whether we are using output subdirectories
    if ($options{output_subdir_size}) {
        $dirpath = "$options{'output_dir'}/$options{output_subdir_prefix}$sub_dir";
    } else {
        $dirpath = "$options{'output_dir'}";
    }
    
    ## did the user ask for a file prefix?
    my $filepath = "$dirpath/$id.split";
    
    ## take any // out of the filepath
    $filepath =~ s|/+|/|g;
    
    ## write the sequence
    $logger->debug("Writing sequence to $filepath") if ($logger->is_debug());
    
    ## open a new output file if we need to
    ##  if we're writing multiple sequences per file, we only open a new
    ##  one when $seqs_in_file = 0 (first sequence)
    if ($seqs_in_file == 0) {
        
        ## if the directory we want to write to doesn't exist yet, create it
        mkdir($dirpath) unless (-e $dirpath);
   
        
        if ($options{'compress_output'}) {    
            open ($ofh, ">:gzip", $filepath.".gz")
              || $logger->logdie("can't create '$filepath.gz':\n$!");
        } else {
            open ($ofh, ">$filepath") || $logger->logdie("can't create '$filepath':\n$!");
        
        }
        $seq_file_count++;
        
        ## add the file we just wrote to the list, if we were asked to
        if (defined $options{output_list}) {
            print $listfh "$filepath\n";
        }
    }

    ## if we're doing output subdirs and hit our size limit, increment to the next dir
    if ($options{output_subdir_size} && $options{output_subdir_size} == $seq_file_count) {
        $seq_file_count = 0;
        $sub_dir++;
    }

    ## write the sequence
    print $ofh ">$$header\n$$seq\n";
    $seqs_in_file++;
    
    ## if we hit the limit of how many we want in each file, set the next file name and 
    ##  reset the count of seqs within the file
    if ($options{seqs_per_file} == $seqs_in_file) {
        $seqs_in_file = 0;
        $group_filename_prefix++;
    }
}


package logger;

sub new {
  my $packname= shift;
  my %args= @_;
  my $self= \%args;
  bless($self,$packname);
  return $self;
}

sub get_logger {
  my $self= shift;
  return $self;
}

sub logdie {
  my $self= shift;
  die @_;
}

sub debug {
  my $self= shift;
  warn @_;
}

sub is_debug {
  shift->{LOG_LEVEL} || 0;
}


1;
