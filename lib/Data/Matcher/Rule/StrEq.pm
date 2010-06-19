use strict;
#ABSTRACT: perform string C<eq> on specified data

=head1 SYNOPSIS

    my $rule = Data::Matcher::RuleFactory->create(
        StrEq => {
            match => 'this string exactly',
            on    => '/path/spec/to/data'
        }
    );

    if ( $rule->check( $data ) ) {
        # matched!
    }

=head1 DESCRIPTION

Perform matching with string C<eq>. Data is looked up via L<Data::DPath>.
Consumes L<Data::Matcher::Role::SPath> and L<Data::Matcher::Role::StrCmp>.

=cut

use MooseX::Declare;
class Data::Matcher::Rule::StrEq extends Data::Matcher::Rule {
    with
        'Data::Matcher::Role::SPath',
        'Data::Matcher::Role::StrCmp';

=method C<cmp>

This method does the string comparison. See C<Data::Matcher::Role::StrCmp>.

=cut

    method cmp( Str $string, Str $check ) {
        return $string eq $check;
    }

=head1 SEE ALSO

=for :list
* L<Data::Matcher::Role::SPath>
* L<Data::Matcher::Role::StrCmp>

=cut

}

1;


