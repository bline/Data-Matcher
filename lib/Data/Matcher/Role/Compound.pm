use strict;
#ABSTRACT: role for compound rules

=head1 DESCRIPTION

Compound rules contain a list of other rules.

=cut

use MooseX::Declare;
role Data::Matcher::Role::Compound {
    use MooseX::Has::Sugar;
    use Data::Matcher::Types qw( DMRuleOp DMRuleList );

=attr C<op>

Sets the operand for matching. An enum, can be B<AND> or <OR>.

=cut

    has 'op' => ( isa => DMRuleOp, ro, coerce, default => "OR" );

=attr C<match>

This should be set to an array reference of rules. This will be coerced into an
array reference of C<DMRule> objects. Required.

=cut

    has 'match' => ( isa => DMRuleList, ro, required, coerce );

=method C<check>

Compound rules contain a list of other rules. Rules are then matched
on given the L<operator|/ATTRIBUTES/op> either C<AND> or C<OR>.

=cut

    method check( Defined $data ) {
        my $and = $self->op eq 'AND';
        my $check;
        for my $rule ( @{ $self->match } ) {
            $check = $rule->check( $data );
            last if $check xor $and;
        }
        return $check;
    }
}

1;

