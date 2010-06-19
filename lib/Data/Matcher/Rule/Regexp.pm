use strict;
#ABSTRACT: perform string C<eq> on specified data

=head1 SYNOPSIS

    my $rule = Data::Matcher::RuleFactory->create(
        Regexp => {
            match => '^foo.*',
            on    => '/path/spec/to/data'
        }
    );

    if ( $rule->check( $data ) ) {
        # matched!
    }

=head1 DESCRIPTION

Perform matching with string C<eq>. Data is looked up via L<Data::DPath>.
Consumes L<Data::Matcher::Role::SPath>.

=cut

use MooseX::Declare;
class Data::Matcher::Rule::Regexp extends Data::Matcher::Rule {
    use MooseX::Types::Moose qw(Str RegexpRef );
    with
        'Data::Matcher::Role::SPath',
        'Data::Matcher::Role::StrCmp';

=attr C<match>

Regular expression to perform match with. Will always be treated as a C<regex>.
Can be set to a C<Str> or C<RegexpRef>.

=cut

    has '+match' => ( isa => Str|RegexpRef );

=method C<cmp>

This method does the string comparison. See C<Data::Matcher::Role::StrCmp>.

=cut

    method cmp( Str $string, Str|RegexpRef $regexp ) {
        return $string =~ /$regexp/;
    }

=head1 SEE ALSO

=for :list
* L<Data::Matcher::Role::SPath>
* L<Data::Matcher::Role::StrCmp>

=cut

}

1;


