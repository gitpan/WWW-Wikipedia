use Test::More tests => 3;

use strict;
use warnings;
use WWW::Wikipedia;
use LWP::UserAgent;

my $ua = LWP::UserAgent->new();
isa_ok( $ua, 'LWP::UserAgent' );
$ua->agent( 'Test' );

my $wiki = WWW::Wikipedia->new ( ua => $ua );
isa_ok( $wiki->{ ua }, 'LWP::UserAgent' );
is( $wiki->{ ua }->agent(), 'Test', 'custom user agent' );


