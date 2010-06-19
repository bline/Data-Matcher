use strict;

use MooseX::Declare;
role Data::Matcher::Rule::StrCmp {
    use MooseX::Types::Moose qw( Str );
    use MooseX::Has::Sugar;
    requires qw( cmp lookup );

=attr C<match>

String to perform string operation on.

=cut

    has 'match' => ( isa => Str, ro, required );

=method C<check>

Expects data to be matched on as the only argument. The data to match on is
looked up via C<lookup()>. If the looked up data does not look like a string
(via C<is_Str()>), this method returns false. The C<cmp()> method is called
with the string to check as the first argument and the string stored in
C<match> as the second argument.

=cut

    method check( Defined $data ) {
        my $string = $self->lookup( $data );
        return undef unless is_Str( $string );
        return $self->cmp( $string, $self->match );
    }
}

1;


