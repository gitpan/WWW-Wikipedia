use Test::More tests => 2;

use strict;
use warnings;

use_ok( 'WWW::Wikipedia' );

my $wiki = WWW::Wikipedia->new();
isa_ok( $wiki, 'LWP::UserAgent' );


