use strict;
package Data::Matcher::Types; # for Pod::Weaver
#ABSTRACT: sets up basic types for Data::Matcher

use MooseX::Declare;

class Data::Matcher::Types {
    use MooseX::Types::Moose qw(ArrayRef HashRef Str RegexpRef);
    use Moose::Util::TypeConstraints;
    use MooseX::Types -declare => [ qw/ DMRule DMRuleOption DMTypeConstraint DMIOHandle / ];

    class_type DMRule, { class => 'Data::Matcher::Rule' };
    class_type DMTypeConstraint, { class => 'Moose::Meta::TypeConstraint' };
    coerce DMTypeConstraint,
        from Str,
            via { subtype $_ };
    subtype DMRuleOption, as ArrayRef|HashRef|Str|RegexpRef|DMTypeConstraint|DMRule;
    class_type DMIOHandle, { class => 'IO::Handle' };

}

1;

__END__

=head1 TYPES

=over

=item C<DMRuleOption> - ArrayRef|HashRef|Str|RegexpRef|DMTypeConstraint|DMRule

Is you are using the object interface, this is the option you pass to
C<$obj-E<gt>parse()>. If you are using the functional interface, this is the
type of the first argument to C<matcher()>.  L<Data::Matcher>.

=over

=item C<DMRule> - Data::Matcher::Rule object

Rules can contain other rules.

=item C<DMTypeConstraint> - Moose::Meta::TypeConstraint object

Rules can contain Moose type constraints.

=item C<DMIOHandle> - IO::Handle object

=back
 
=back

