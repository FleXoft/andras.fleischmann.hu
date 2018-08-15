#!/usr/bin/perl

use strict;
use warnings;

use Pod::Usage;

use Getopt::Long;
my $directory    = 'photos/andras';       # directory
my $rows         = 4;                     # row#
my $verbose;                              #
my $filelist;                             # jpgfilelist (jpg|title|author)
my $exclude;                              # exclude
my $outdir       = "_includes";           # output directory
my $filetag      = "";                    #
my $imgproperty  = "";                    # extra link property 
my $globaltitle  = "Fleischmann András";  #
my $globalauthor = "Fleischmann György";  #
my $debug;                                #
my $help;
my $man;

GetOptions ( "rows=i"         => \$rows,
             "directory=s"    => \$directory,
             "verbose"        => \$verbose,
             "filelist=s"     => \$filelist,
             "exclude=s"      => \$exclude,
             "outdir=s"       => \$outdir,
             "filetag=s"      => \$filetag,
             "imgproperty=s"  => \$imgproperty,
             "title=s"        => \$globaltitle,
             "author=s"       => \$globalauthor,
             "debug"          => \$debug,
             "help"           => \$help,
             "man"            => \$man )   
or die( "Error in command line arguments\n" );

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
    - imgproperty 
    - title
    - author
    - debug
    - help
    - man 

=head1 OPTIONS

=over 4

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Detailed manual page.

=item B<-debug>

Debug option to get debug messages.

=item B<-verbose>

Enable verbose outputs.

=item B<-directory>

Specify the source directory to scan *.jpg files.

=item B<-rows>

Specify the # of rows you want to create. Default: 4

=item B<-filelist>

Specify a file wich contains the files with full path to process.

=item B<-exclude>

Exclude this file matching this pattern.

=item B<-outdir>

Specify the output directory.

=item B<-filetag>

Specify an extra tag for the links and file names.

=item B<-imgproperty>

Specify an extra HTML img property for the links.

=item B<-title>

Specify a global title property of the images.

=item B<-author>

Specify a global author property of the images.

=back

=cut

=head1 DESCRIPTION

B<This program> will generate array.html, rowx.html file to help implement Responsive JavaScript Image Gallery package.

http://photoswipe.com/

=cut

=head1 EXAMPLES

Examples of this script:

./PhotoSwipeGenerator.pl --directory photos/2017-11-05-Ulloi --filetag _ulloi --outdir _includes

=cut

print "Verbose output option is enabled!\n" if $verbose;

pod2usage( q( -verbose ) => 1 ) if $help;
pod2usage( -exitval => 0, -verbose => 2 ) if $man;

# isFileReadable ( filename )
sub isFileReadable ( $ ) {
  if ( ! -r "$_[0]" ) {
    print "!!! \"$_[0]\" not readable!\n";
    return 1;
  }
  return 0;
}

# readFile2Variable ( filename )
sub readFile2Variable ( $ ) {
  open FILEHNDLR,"$_[0]";
  my $return = join( '' , <FILEHNDLR> );
  close FILEHNDLR;
  return $return;
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
  #next if isFileReadable ( "$originalFilename" );

  my $filename = $originalFilename;
  $filename =~ s/_ORIGINAL\.jpg/\.jpg/;
  next if isFileReadable ( "$filename" );

  # create a link
	my $picHTML = "<a href=\"javascript:openPhotoSwipe(); gallery.goTo( $counter );\"><img title=\"$globaltitle\" $imgproperty src=\"".$filename."\"></a>\n";

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
  print ARRAYS "title : '$globaltitle',\n";
  print ARRAYS "author: '$globalauthor'\n"; 
  print ARRAYS "}";

  print "\r$counter" if $verbose;

	$counter++;
}
print "\n" if $verbose;

print ARRAYS "];\n";