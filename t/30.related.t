use Test::More tests=>3;

use strict;
use WWW::Wikipedia;

my $wiki = WWW::Wikipedia->new();
isa_ok( $wiki, 'WWW::Wikipedia' );

my $entry = $wiki->search( 'perl' );
isa_ok( $entry, 'WWW::Wikipedia::Entry' );

my @entries = $entry->related();
ok( scalar( @entries ) > 0, 'related()' );

print join( "\n", @entries );
