use strict;
#ABSTRACT: compound rules contain a list of other rules for logical matching

=head1 SYNOPSIS

    my $rule = Data::Matcher::RuleFactory->create(
        Not => {
            match => \%rule
        }
    );

    if ( $rule->check ) {
        # matched!
    }

=head1 DESCRIPTION

Negates the rule specified in C<match>. Consumes L<Data::Matcher::Role::Unary>

=cut

use MooseX::Declare;
class Data::Matcher::Rule::Compound extends Data::Matcher::Rule {
    with 'Data::Matcher::Role::Unary';

=method C<check>

Returns the negation of a call to C<check> on the rule in
L<match()|/ATTRIBUTES/match>. Expects data to match on as the only argument.

=cut

    method check( Defined $data ) {
        return not( $self->match->check( $data ) );
    }
}

1;

