use Test::More tests => 6;

use WWW::Wikipedia;

my $wiki;

# test default language
$wiki = WWW::Wikipedia->new();
isa_ok( $wiki, 'WWW::Wikipedia' );

my $entry = $wiki->search( 'perl' );
isa_ok( $entry, 'WWW::Wikipedia::Entry' );

ok( length($entry->text()) > 0, 'text()' );

# test language 'es'
$wiki = WWW::Wikipedia->new( language => 'es' );
isa_ok( $wiki, 'WWW::Wikipedia' );

$entry = $wiki->search( 'perl' );
isa_ok( $entry, 'WWW::Wikipedia::Entry' );

ok( length($entry->fulltext()) > 0, 'fulltext()' );