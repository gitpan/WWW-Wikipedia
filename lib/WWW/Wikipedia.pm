package WWW::Wikipedia;

use strict;
use warnings;
use Carp qw( croak );
use CGI qw( escape );
use WWW::Wikipedia::Entry;

use base qw( LWP::UserAgent );

our $VERSION = .9;

use constant WIKIPEDIA_ENGLISH => 'http://www.wikipedia.org';

=head1 NAME

WWW::Wikipedia - Automated interface to the Wikipedia 

=head1 SYNOPSIS

  use WWW::Wikipedia;
  my $wiki = WWW::Wikipedia->new();

  ## search for 'perl' 
  my $result = $wiki->search( 'perl' );

  ## if the entry has some text print it out
  if ( $result->text() ) { 
      print $result->text();
  }

  ## list any related items we can look up 
  print join( "\n", $result->related() );

=head1 DESCRIPTION

WWW::Wikipedia provides an automated interface to the Wikipedia 
L<http://www.wikipedia.org>, which is a free, collaborative, online 
encyclopedia. This module allows you to search for a topic and return the 
resulting entry. It also gives you access to related topics which are also 
available via the Wikipedia for that entry.

=head1 METHODS

=head2 new()

The constructor, which takes no arguments.

    my $wiki = WWW::Wikipedia->new();

WWW::Wikipedia is a subclass of LWP::UserAgent. If you would
like to have more control over the user agent (control timeouts, proxies ...) 
you have full access.

    ## set HTTP request timeout
    my $wiki = WWW::Wikipedia->new();
    $wiki->timeout( 2 );

=cut

sub new { 
    my ( $class, %opts ) = @_;

    my $self =  LWP::UserAgent->new();
    $self->agent( 'WWW::Wikipedia' );
    $self->{ src } = WIKIPEDIA_ENGLISH;

    return bless $self, ref($class) || $class
}

=head2 search() 

Which performs the search and returns a WWW::Wikipedia::Entry object which 
you can query further. See WWW::Wikipedia::Entry docs for more info.

    $entry = $wiki->search( 'Perl' );
    print $entry->text();


=cut 

sub search {
    my ($self,$string) = @_;

    croak( "search() requires you pass in a string" ) if ! defined( $string );
    $string = escape( $string );
    my $src = $self->{ src };

    my $response = $self->get( "$src/wiki/$string?action=raw" );
    if ( $response->is_success() ) {
	my $entry = WWW::Wikipedia::Entry->new( $response->content(), $src );
	return( $entry );
    } else {
	croak( "uhoh, WWW::Wikipedia unable to contact ".$src );
    }

}

=head1 TODO

=over 4

=item * Clean up results

=item * Support for other language Wikipedias

=item * Handle failed searches by suggesting other entries?

=back

=head1 SEE ALSO

=over 4

=item * LWP::UserAgent

=back

=head1 AUTHOR

Ed Summers, E<lt>esummers@flr.follett.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Ed Summers

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;
