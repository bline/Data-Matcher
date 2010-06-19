use strict;
#ABSTRACT: role for rules which are using L<Data::SPath> for data lookups

=head1 DESCRIPTION

This role is consumed by L<Data::Matcher::Rule> classes which make use of
L<Data::SPath> for data lookups.

=cut

use MooseX::Declare;
role Data::Matcher::Role::SPath {
    use MooseX::Has::Sugar;
    use Data::SPath qw/ spath /;

=attr C<on>

This should be a L<Data::SPath> path specification.

=cut
    has 'on' => ( isa => Str, ro, required ); 

=method C<lookup>

Expects data to perform lookups on at the only argument.

=cut

    method lookup( Defined $data ) {
        my $match = eval { spath $data, $self->on };
        warn "$@" if $@;
        return $match;
    }

}

1;

