use strict;
#ABSTRACT: Base class for Data::Matcher rules

=head1 DESCRIPTION

This is the base class for all L<Data::Matcher> rules.

=cut

use MooseX::Declare;
class Data::Matcher::Rule {
    use MooseX::Types::Moose qw(Str);

=att C<with>

holds the type of rule this is.

=cut

    has 'with' => ( isa => Str, required, coerce );
}

1;

