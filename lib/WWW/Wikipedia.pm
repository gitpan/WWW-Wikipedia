package WWW::Wikipedia;

use strict;
use warnings;
use LWP::UserAgent;
use Carp qw( croak );
use CGI qw( escape );
use HTML::Parser;

our $VERSION = .1;

use constant WIKIPEDIA_ENGLISH => 'http://www.wikipedia.org/w/wiki.phtml';

=head1 NAME

WWW::Wikipedia - Automated interface to the Wikipedia 

=head1 SYNOPSIS

  use WWW::Wikipedia;
  my $wiki = WWW::Wikipedia->new();

  ## search for 'perl' 
  my $result = $wiki->search( 'perl' );

  ## if we got some content print it out
  if ( $result->text() ) { 
      print $result->content();
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

=cut

sub new { 
    my $class = shift;
    my $ua = LWP::UserAgent->new();
    $ua->agent( 'WWW::Wikipedia' );
    return(  
	bless { 
	    ua	    => $ua,
	    src	    => WIKIPEDIA_ENGLISH
	}, ref($class) || $class
    );
}

=head2 search() 

Which performs the search and returns a WWW::Wikipedia::Entry object which 
you can query further.

    $entry = $wiki->search( 'Perl' );

=cut 

sub search {
    my ($self,$string) = @_;

    croak( "search() requires you pass in a string" ) if ! defined( $string );
    $string = escape( $string );
    my $ua = $self->{ ua };
    my $src = $self->{ src };

    my $response = $ua->get( "$src?search=$string&go=Go" );
    if ( $response->is_success() ) {
	my $entry = WWW::Wikipedia::Entry->new( $response->content(), $src );
	return( $entry );
    } else {
	croak( "uhoh, WWW::Wikipedia unable to contact ".$src );
    }

}

=head2 text()

After you have performed a search you use text() to retrieve the content of 
the entry. If your search failed you will be returned C<undef>.

    $entry = $wiki->search( 'Perl' );
    print "Perl is: ",$entry->text();

=head2 related()

related() returns a list of wiki items that are related to the entry in 
question. You can use these terms as possible new searches. If there are
no realted items you get back an empty list.

    $entry = $wiki->search( 'Perl' );
    foreach ( $wiki->related() ) { 
	print "$_\n";
    }

    ## which prints out this:

    1987
    2002
    Acronym
    Artistic License
    Awk
    Backronym
    C programming language
    CPAN
    Common Gateway Interface
    Free software movement
    Functional programming
    GPL
    Java programming language
    Larry Wall
    Microsoft Windows
    Obfuscated code
    Object Oriented Programming
    Operating system
    Parrot virtual machine
    Poetry
    Procedural programming
    Programming language
    Regular expression
    Scripting programming languages
    Sed
    Sh
    Syntax
    Unicode
    Unix
    Unix-like
    Virtual machine
    Wikipedia

=head1 TODO

=over 4

=item * Clean up results of content()

=item * Support for other language Wikipedias

=item * Handle failed searches by suggesting other entries?

=back

=head1 SEE ALSO

=over 4

=item * HTML::Parser

=item * LWP::UserAgent

=back

=head1 AUTHOR

Ed Summers, E<lt>esummers@flr.follett.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Ed Summers

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

package WWW::Wikipedia::Entry;

use HTML::Parser;

sub new {
    my ( $class, $html, $src ) = @_;
    if ( $html =~ /no page with this exact title exists/i ) { 
	return( undef ); 
    }
    return( bless { html => $html, src => $src }, ref($class) || $class );
}

sub text {
    my $self = shift;
    $self->_parse if !exists( $self->{ text } );
    return $self->{ text };
}

sub related {
    my $self = shift;
    if ( ! exists( $self->{ related_entries } ) ) {
	$self->_parse if ! exists( $self->{ related_urls } );
	my ( $src ) = ( $self->{ src } =~ m[(http://.*?)/] );
	$src = "$src/wiki/";
	my %found = ();
	foreach ( @{ $self->{ related_urls } } ) {
	    if ( $_ =~ /$src(.*)/ ) {
		my $entry = $1;
		$entry =~ s/_/ /g;
		$found{ $entry } = 1;
	    }
	}
	$self->{ related_entries } = [ sort keys(%found) ];
    }
    return @{ $self->{ related_entries } };
}

sub _parse {
    my $self = shift;
    my $parser = HTML::Parser->new();
    $parser->unbroken_text();
    $parser->handler( start => \&_start, "self, tagname, attr, text" );
    $parser->handler( end => \&_end, "self, tagname, text" );
    $parser->handler( text => \&_text, "self, dtext, is_cdata" );
    $parser->{ WIKI_FOUND_ARTICLE } = 0;
    $parser->{ WIKI_DIVCOUNT } = 0;
    $parser->{ WIKI_INSIDE_RELATED } = 0;
    $parser->{ text } = '';
    $parser->{ related_urls } = [];
    $parser->parse( $self->{ html } ); 
    $parser->{ text } =~ s/(\r\n)+/$1/gm;
    $parser->{ text } =~ s/\n+/\n/gm;
    $self->{ text } = $parser->{ text };
    $self->{ related_urls } = $parser->{ related_urls };
}

sub _start {
    my ( $self, $tagname, $attr, $attrseq, $text ) = @_;
    if ( $tagname eq 'div' ) { 
	$self->{ WIKI_DIVCOUNT }++;
	if ( $attr->{ id } eq 'article' ) { 
	    $self->{ WIKI_FOUND_ARTICLE } = $self->{ WIKI_DIVCOUNT };
	}
    } elsif ( $tagname eq 'a' and $self->{ WIKI_FOUND_ARTICLE } ) {
	push( @{ $self->{ related_urls } }, $attr->{ href } );
    }
}

sub _end {
    my ( $self, $tagname, $text ) = @_;
    return() if $tagname ne 'div';
    if ( $self->{ WIKI_FOUND_ARTICLE } 
	and $self->{ WIKI_FOUND_ARTICLE } eq $self->{ WIKI_DIVCOUNT } ) {
	$self->{ WIKI_FOUND_ARTICLE } = 0;
    }
    $self->{ WIKI_INSIDE_RELATED } = 0;
    $self->{ WIKI_DIVCOUNT }--;
}

sub _text {
    my ( $self, $text, $is_cdata ) = @_;
    if ( $self->{ WIKI_FOUND_ARTICLE } ) {
	$self->{ text } .= $text; 
    }
}

1;
