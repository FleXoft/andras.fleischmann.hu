#!/usr/bin/perl

use strict;
use warnings;

#open( PICS,   "<pics.txt" ) or die "$!";
open( ROW1,   ">row1.html" ) or die "$!";
open( ROW2,   ">row2.html" ) or die "$!";
open( ROW3,   ">row3.html" ) or die "$!";
open( ROW4,   ">row4.html" ) or die "$!";
open( ARRAYS, ">arrays.html" ) or die "$!";

print "Generating...\n";

my $counter = 0;

print ARRAYS "\tvar items = [\n";

foreach ( `ls -1t photos/andras/ | grep -v _ORIGINAL` ) {
	chomp;

	my $modulo = $counter % 4;

	my $filename = $_;
	my $picHTML = "\t<a href=\"javascript:openPhotoSwipe(); gallery.goTo($counter);\"><img src=\"".$filename."\"></a>\n";
	
	my $originalFilename = $filename;
	$originalFilename =~ s/.jpg/_ORIGINAL.jpg/;

	# switch / case for rows
    if    ( $modulo == 0 ) { print ROW1 $picHTML; }
    elsif ( $modulo == 1 ) { print ROW2 $picHTML; }
    elsif ( $modulo == 2 ) { print ROW3 $picHTML; }
    elsif ( $modulo == 3 ) { print ROW4 $picHTML; }
    
    # and arrays
    if ( $counter != 0 ) { print ARRAYS ",\n"; }

    print ARRAYS "\t{\n";
    print ARRAYS "\t\tsrc   : 'photos/andras/HipstamaticPhoto-551114471.203205_ORIGINAL.jpg',\n";
    print ARRAYS "\t\tw     : 2448,\n";
    print ARRAYS "\t\th     : 2448,\n";
    print ARRAYS "\t\ttitle : 'Fleischmann András',\n";
    print ARRAYS "\t\tauthor: 'Fleischmann György'\n"; 
    print ARRAYS "\t}";

	$counter++;
}

print ARRAYS "\t];\n";