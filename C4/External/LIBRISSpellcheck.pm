package C4::External::LIBRISSpellcheck;
# Copyright (C) 2015 Eivin Giske Skaaren
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use LWP::UserAgent;
use XML::Simple qw(XMLin);
use C4::Context;

sub get_suggestion {
    my ($self, $query) = @_;
    my $key = C4::Context->preference('LIBRISKey');    

    my $response = LWP::UserAgent->new->get("http://api.libris.kb.se/bibspell/spell?query={$query}&key=$key");
    my $xml = XMLin($response->content);

    my @result;
    if ($xml->{suggestion}->{term}) {
        if (ref($xml->{suggestion}->{term}) eq 'ARRAY') {
            for (@{$xml->{suggestion}->{term}}) {
                if (/^HASH\(\d+/) {
                    push @result, $_->{content};
                } else {
                    push @result, $_;
                }
            }
        } else {
            return $xml->{suggestion}->{term};
        }
        return join(' ', @result);
    } else {
        return "No suggestion from LIBRIS.";
    }
}

1;
__END__

=head1 NAME

C4::External::LIBRISSpellcheck - For connectiong to the LIBRIS spell checker API

=head2 FUNCTIONS

This module provides facilities for using the LIBRIS spell checker API

=over

=item get_suggestion(query)

Sends in the search query and gets an XML with a suggestion

=back

=cut

=head1 NOTES

=cut

=head1 AUTHOR

Eivin Giske Skaaren <eskaaren@yahoo.no>

=cut
