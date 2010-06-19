use strict;
#ABSTRACT: matches only if all subrules match

=head1 SYNOPSIS

    my $rule = Data::Matcher::RuleFactory->create(
        All => {
            match => \@rules
        }
    );

    if ( $rule->check ) {
        # matched!
    }

=head1 DESCRIPTION

Rule to check is any of the subrules match. Consumes
L<Data::Matcher::Role::Compound>.

=cut

use MooseX::Declare;
class Data::Matcher::Rule::Any extends Data::Matcher::Rule {
    with 'Data::Matcher::Role::Compound';
    has '+op' => ( init_arg => undef, default => 'OR' );

1;

