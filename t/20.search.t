use Test::More tests=>3;

use WWW::Wikipedia;

my $wiki = WWW::Wikipedia->new();
isa_ok( $wiki, 'WWW::Wikipedia' );

my $entry = $wiki->search( 'perl' );
isa_ok( $entry, 'WWW::Wikipedia::Entry' );

ok( length($entry->text()) > 0, 'text()' );
