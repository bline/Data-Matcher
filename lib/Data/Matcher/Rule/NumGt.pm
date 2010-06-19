use strict;
#ABSTRACT: perform numeric E<gt> on specified data

=head1 SYNOPSIS

    my $rule = Data::Matcher::RuleFactory->create(
        NumGt => {
            match => 10, # greater than 10
            on    => '/path/spec/to/data'
        }
    );

    if ( $rule->check( $data ) ) {
        # matched!
    }

=head1 DESCRIPTION

Perform matching with numeric E<gt>. Data is looked up via L<Data::DPath>.
Consumes L<Data::Matcher::Role::SPath> and L<Data::Matcher::Role::NumCmp>.

=cut

use MooseX::Declare;
class Data::Matcher::Rule::NumGt extends Data::Matcher::Rule {
    with
        'Data::Matcher::Role::SPath',
        'Data::Matcher::Role::NumCmp';

=method C<cmp>

This method does the numeric comparison. See C<Data::Matcher::Role::NumCmp>.

=cut

    method cmp( Num $number, Num $check ) {
        return $number > $check;
    }

=head1 SEE ALSO

=for :list
* L<Data::Matcher::Role::SPath>
* L<Data::Matcher::Role::NumCmp>

=cut

}

1;


