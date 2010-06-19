use strict;

#ABSTRACT: declared types for Data::Matcher

=head1 DESCRIPTION

This module declares and exports the types used in CatalystX::ACL.

=head1 TYPES

=cut

use MooseX::Declare;
class Data::Matcher::Types {
    use Moose::Util::TypeConstraints;
    use MooseX::Types::Moose qw( HashRef Str ArrayRef );
    use MooseX::Types -declare => [qw/
        DMRule
        DMRuleList
        DMRuleOp
        DMDataPath
    /];

=head2 C<DMRule>

Class type for L<Data::Matcher::Rule> types. Creates new rule objects with
L<Data::Matcher::RuleFactory> calling C<create> with the key C<with> as the
type to create.

=cut

    class_type DMRule, { class => 'Data::Matcher::Rule' };
    coerce DMRule,
        from HashRef,
        via { Data::Matcher::RuleFactory->create( $_[0]->{with}, $_[0] ) };

=head2 C<DMRuleList>

Array reference of L<DMRule|/TYPES/DMRule> objects with coercion.

=cut

    subtype DMRuleList, as ArrayRef[DMRule];
    coerce DMRuleList,
        from ArrayRef[HashRef],
        via { [ map { to_DMRule( $_ ) } @{ $_[0] } ] };

=head2 C<DMRuleOp>

An enumeration which can be either C<AND> or C<OR>. Coercion uppercases.

=cut

    enum DMRuleOp, qw( AND OR );
    coerce DMRuleOp,
        from Str,
        via { uc $_[0] };

}

1;

