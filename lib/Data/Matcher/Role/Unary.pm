use strict;
#ABSTRACT: unary rules contain one other rule

=head1 DESCRIPTION

Role for unary operater rules.

=cut

use MooseX::Declare;
role Data::Matcher::Role::Unary {
    use MooseX::Has::Sugar;
    use Data::Matcher::Types qw( DMRule );

=attr C<match>

Should be set to a C<DMRule> object. Will be coerced. See
L<Data::Matcher::Types/TYPES/DMRule>.

=cut

    has 'match' => ( isa => DMRule, ro, required, coerce );

}

1;


