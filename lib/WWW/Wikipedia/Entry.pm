package WWW::Wikipedia::Entry;

use strict;
use warnings;

=head1 NAME

WWW::Wikipedia::Entry - A class for representing a Wikipedia Entry

=head1 SYNOPSIS

    my $wiki = WWW::Wikipedia->new();
    my $entry = $wiki->search( 'Perl' );
    print $entry->text();

=head1 DESCRIPTION

WWW::Wikipedia::Entry objects are usually created using the search() method
on a WWW::Wikipedia object to search for a term. Once you've got an entry
object you can then extract pieces of information from the entry using 
the following methods.

=head1 METHODS

=head2 new()

You probably won't use this one, it's the constructor that is called 
behind the scenes with the correct arguments by WWW::Wikipedia::search().

=cut

sub new {
    my ( $class, $raw, $src ) = @_;
    return if length($raw) == 0;
    my $self = bless { 
        raw         => $raw, 
        src         => $src,
        text        => '',
        fulltext    => '',
        cursor      => 0,
        related     => [],
        categories  => [],
        headings    => [],
        }, ref($class) || $class;
    $self->_parse();
    $self->{fulltext} =~ s/^\n//mg; ## remove empty lines
    $self->{text} =~ s/\n//g; ## remove all newlines
    return( $self );
}

=head1 text()

The brief text for the entry. This will provide the first paragraph of 
text; basically everything up to the first heading. Ordinarily this will
be what you want to use.

If text() returns nothing then you probably are looking at a disambiguation
entry, and should use related() to lookup more specific entries.

=cut

sub text {
    return( shift->{text} );
}

=head1 fulltext()

Returns the full text for the entry, which can be extensive.

=cut

sub fulltext {
    my $self = shift;
    return $self->{fulltext};
}

=head1 related()

Returns a list of terms in the wikipedia that are mentioned in the 
entry text.

=cut

sub related {
    return( @{ shift->{ related } } );
}

=head1 categories()

Returns a list of categories which the entry is part of. So Perl is part
of the Programming languages category.

=cut

sub categories {
    return( @{ shift->{ categories } } );
}

=head1 headings()

Returns a list of headings used in the entry.

=cut

sub headings {
    return( @{ shift->{headings} } );
}

=head1 raw()

Returns the raw wikitext for the entry.

=cut

sub raw {
    my $self = shift;
    return $self->{ raw };
}


## messy internal routine for barebones parsing of wikitext

sub _parse {
    my $self = shift;
    my $raw = $self->{ raw };
    for ( $self->{cursor}=0; $self->{cursor}<length($raw); 
        $self->{cursor}++ ) {

        pos( $raw ) = $self->{cursor};

        ## [[ ... ]]
        if ( $raw =~ /\G\[\[ *(.*?) *\]\]/ ) { 
            my $directive = $1;
            $self->{cursor} += length($&)-1;
            if ( $directive =~ /\:/ ) {
                my ( $type, $text ) = split /:/, $directive;
                if ( lc( $type ) eq 'category' ) {
                    push( @{ $self->{categories} }, $text );
                }
            } elsif ( $directive =~ /\|/ ) {
                my ( $lookup, $name ) = split /\|/, $directive;
                $self->{fulltext} .= $name;
                push( @{ $self->{related} }, $lookup ) if $lookup !~ /^#/;
            } else {
                $self->{fulltext} .= $directive;
                push( @{ $self->{related} }, $directive );
            }
        }

        ## === heading 2 ===
        elsif ( $raw =~ /\G=== *(.*?) *===/ ) {
            ### don't bother storing these headings
            $self->{fulltext} .= $1;
            $self->{cursor} += length($&)-1;
            next;
        }

        ## == heading 1 == 
        elsif ( $raw =~ /\G== *(.*?) *==/ ) { 
            push( @{ $self->{headings} }, $1 );
            $self->{text} = $self->{fulltext} if ! $self->{seenHeading};
            $self->{seenHeading} = 1;
            $self->{fulltext} .= $1;
            $self->{cursor} += length($&)-1;
            next;
        }

        ## '' italics ''
        elsif ( $raw =~ /\G'' *(.*?) *''/ ) {
            $self->{fulltext} .= $1;
            $self->{cursor} += length($&)-1;
            next;
        }

        ## {{ disambig }}
        elsif ( $raw =~ /\G{{ *(.*?) *}}/ ) { 
            ## ignore for now
            $self->{cursor} += length($&)-1;
            next;
        }

        else {
            $self->{fulltext} .= substr( $raw, $self->{cursor}, 1 );
        }
    }
}

=head1 AUTHORS

=over 4

=item * Ed Summers <ehs@pobox.com>

=back

=cut

1;
