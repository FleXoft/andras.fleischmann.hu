#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
my $directory = 'photos/andras';  # directory
my $rows      = 4;                # row#
my $verbose;                      #
my $filelist;                     # jpgfilelist (jpg|title|author)
my $exclude;                      # exclude
my $outdir = "_includes";         # output directory
my $filetag = "";                 #
my $debug;                        #
my $help;
GetOptions ( "rows=i"       => \$rows,
             "directory=s"  => \$directory,
             "verbose"      => \$verbose,
             "filelist=s"   => \$filelist,
             "exclude=s"    => \$exclude,
             "outdir=s"     => \$outdir,
             "filetag=s"        => \$filetag,
             "debug"        => \$debug,
             "help"         => \$help )   
or die( "Error in command line arguments\n" );

use Pod::Usage;

=head1 NAME

PhotoSwipeGenerator.pl

=head1 SYNOPSIS
  
  PhotoSwipeGenerator.pl [options] 

  Options:
    - directory
    - rows
    - verbose
    - filelist
    - exclude
    - outdir
    - filetag 
    - debug
    - help

=head1 OPTIONS

=over 4

=item B<-help>

Print a brief help message and exits.

=item B<-debug>

Debug option.

=back

=head1 DESCRIPTION

B<This program> will create...

=cut

pod2usage( q( -verbose ) => 2 ) if $help;

print "$verbose\n" if $verbose;

# isFileReadable ( filename )
sub isFileReadable ( $ ) {
  if ( ! -r "$_[0]" ) {
    print "!!! \"$_[0]\" not readable!\n";
    return 1;
  }
  return 0;
}

#open( PICS,   "<pics.txt" ) or die "$!";
open ( ROW01,  "> $outdir/row1$filetag.html" ) or die "$!";
open ( ROW02,  "> $outdir/row2$filetag.html" ) or die "$!";
open ( ROW03,  "> $outdir/row3$filetag.html" ) or die "$!";
open ( ROW04,  "> $outdir/row4$filetag.html" ) or die "$!";
open ( ARRAYS, "> $outdir/array$filetag.html" ) or die "$!";

print "Generating...\n";

my $counter = 0;

print ARRAYS "var items = [\n";

foreach ( `ls -1dt "$directory"/*.jpg | grep _ORIGINAL` ) {
	chomp;

  # skip if file is missing
  my $originalFilename = $_;
  #$originalFilename =~ s/.jpg/_ORIGINAL.jpg/;
  next if isFileReadable ( "$originalFilename" );

  my $filename = $originalFilename;
  $filename =~ s/_ORIGINAL\.jpg/\.jpg/;
  next if isFileReadable ( "$filename" );

  # create a link
	my $picHTML = "<a href=\"javascript:openPhotoSwipe(); gallery.goTo( $counter );\"><img src=\"".$filename."\"></a>\n";

  my $modulo = $counter % 4;
	
	# switch / case for separate rows
  if    ( $modulo == 0 ) { print ROW01 $picHTML; }
  elsif ( $modulo == 1 ) { print ROW02 $picHTML; }
  elsif ( $modulo == 2 ) { print ROW03 $picHTML; }
  elsif ( $modulo == 3 ) { print ROW04 $picHTML; }

  # and a JavaScript array for PhotoSwipe
  if ( $counter != 0 ) { print ARRAYS ",\n"; }

  my ( $w, $h ) = split ( /x/, `magick identify -format "%wx%h" "$originalFilename"` ); # get pic width x height

  print ARRAYS "{\n";
  print ARRAYS "src   : '$originalFilename',\n";
  print ARRAYS "w     : $w,\n";
  print ARRAYS "h     : $h,\n";
  print ARRAYS "title : 'Fleischmann András',\n";
  print ARRAYS "author: 'Fleischmann György'\n"; 
  print ARRAYS "}";

  print "\r$counter" if $verbose;

	$counter++;
}
print "\n" if $verbose;

print ARRAYS "];\n";