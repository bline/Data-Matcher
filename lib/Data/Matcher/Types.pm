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

=head1 NAME

Data::Matcher::Types - sets up basic types for Data::Matcher

=head1 DESCRIPTION

Sets up types for Data::Matcher.

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

=back
    
=back

=head1 AUTHOR

Scott Beck E<lt>scottbeck@gmail.comE<gt>


=head1 COPYRIGHT

Copyright 2011 by Scott A Beck E<lt>scottbeck@gmail.comE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://www.perl.com/perl/misc/Artistic.html>

=cut

