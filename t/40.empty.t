use Test::More tests=>2;

use strict;
use warnings;
use WWW::Wikipedia;

my $wiki = WWW::Wikipedia->new();
isa_ok( $wiki, 'WWW::Wikipedia' );
my $entry = $wiki->search ( 'lsdfiefimnvlmisek' );
is( $entry, undef, 'search() returns undef on failure' );
