use strict;
use warnings;
use Test::More qw( no_plan );

use_ok( 'WWW::Wikipedia::Entry' );
my $wikitext = getWikiText();

my $entry = WWW::Wikipedia::Entry->new( $wikitext, 'nowhere' );
isa_ok( $entry, 'WWW::Wikipedia::Entry' );

is( $entry->text(), "'Perl', also 'Practical Extraction and Report Language' (a backronym, see below), is a programming language released by Larry Wall on December 18, 1987 that borrows features from C, sed, awk, shell scripting (sh), and (to a lesser extent) from many other programming languages.", 'text()' ); 

is( $entry->headings(), 13, 'headings()' );

my @categories = $entry->categories();
is( $categories[0], "Programming languages", 'categories()' );

is( $entry->related(), 91, 'related()' );

## fetches some wikitext from disk
sub getWikiText {
    open( TEXT, 't/perl.raw' );
    my $text = join( "\n", <TEXT> );
    close( TEXT );
    return( $text );
}

