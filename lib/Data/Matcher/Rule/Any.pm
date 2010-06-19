use strict;
#ABSTRACT: matches is any subrule matches

=head1 SYNOPSIS

    my $rule = Data::Matcher::RuleFactory->create(
        Any => {
            match => \@rules
        }
    );

    if ( $rule->check ) {
        # matched!
    }

=head1 DESCRIPTION

Rule to check is all of the subrules match. Consumes
L<Data::Matcher::Role::Compound>.

=cut

use MooseX::Declare;
class Data::Matcher::Rule::Any extends Data::Matcher::Rule {
    with 'Data::Matcher::Role::Compound';
    has '+op' => ( init_arg => undef, default => 'AND' );

1;

