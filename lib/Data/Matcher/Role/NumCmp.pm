use strict;

use MooseX::Declare;
role Data::Matcher::Rule::NumCmp {
    use MooseX::Types::Moose qw( Num );
    use MooseX::Has::Sugar;
    requires qw( cmp lookup );

=attr C<match>

Number to perform numeric operation on.

=cut

    has 'match' => ( isa => Num, ro, required );

=method C<check>

Expects data to be matched on as the only argument. The data to match on is
looked up via C<lookup()>. If the looked up data does not look like a number
(via C<is_Num()>), this method returns false. The C<cmp()> method is called
with the number to check as the first argument and the number stored in
C<match> as the second argument.

=cut

    method check( Defined $data ) {
        my $number = $self->lookup( $data );
        return undef unless is_Num( $number );
        return $self->cmp( $number, $self->match );
    }
}

1;

