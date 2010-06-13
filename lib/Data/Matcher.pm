use strict;
package Data::Matcher; # for Pod::Weaver
# ABSTRACT: simple matching on perl data structures and moose objects

use MooseX::Declare 0.33;
class Data::Matcher {
    use Moose 1.03;
    use Carp qw/croak/;

    Moose::Exporter->setup_import_methods(
        as_is => [ qw/ matcher / ]
    );

    sub matcher {
        unless ( @_ == 2 ) {
            croak 'Usage: matcher $options, $data';
        }
        my ( $options, $data ) = @_;
        return Data::Matcher::Rule->new
                                  ->parse( $options )
                                  ->match( $data );
    }
}

1;

__END__

=head1 SYNOPSIS

    use Data::Matcher;

    # Usage: matcher \%rules|\@rules, $data;

    # keys foo bar and baz are in %data;
    matcher [ -keys => 1, -all => 1, qw(foo bar baz) ], \%data;

    # substring of keys foo bar and baz are in %data;
    matcher [ -keys => 1, -substr => 1, -and => 1, qw(foo bar baz) ], \%data;

    # substring of values foo bar and baz are in %data;
    matcher [ -noKeys => 1, -noExact => 1, -all => 1, qw(foo bar baz) ], \%data;

    # a key foo that has a value "bar"
    matcher { foo => "bar" }, \%data;

    # -regex => 1,  treats the keys and the values as regular expressions
    matcher { -regex => 1, "foo.*" => "bar?" }, \%data;
    # -regex was added for config storage (makes it serializable)

    # ensures $data is an array reference where the first value matches the
    # regex qw/^foo?$/
    matcher [ -typeConstraint => 'ArrayRef',  -indexed => 1, qr/^foo?$/ ], $data;

    my $match = matcher {
        -all => 1,
        foo => qr/foo|bar/,
        bar => 2,
        baz => [ -all => 1, -typeConstraint => 'ArrayRef', qw( foo bar bat ) ],
        bat => {
            -flags => [qw/regex all only/],
            'hey|hi' => qr/(?:wo)?man/,
            '(?:yo)\s+wut' => qr/up.*/
        }
    }, {
        foo => "bar",
        bar => 2,
        baz => [ "bat", "bar", "foo" ],
        bat => {
            hey => "man",
            wut => "up",
        }
    };

    # OOP interface

    # defaults to 'and' for matching. Can be changed in rules
    my $rule = new Data::Matcher::Rule( 'and' => 1 );

    # parses rule. sets global flags. initialized subrule objects
    $rule->parse([ -indexed, qw(foo bar baz) ]);

    my $match1 = $rule->match( $data1 );
    my $match2 = $rule->match( $data2 );
    ...

    # clear rules
    $rule->clear_rules;
    # Note: parse() adds rules

    # add a rule
    $rule->parse( qr/[a-z]+/ );
    # do more matching
    my $match3 = $rule->match( $data3 );


=head1 DESCRIPTION

This module gives you an interface to search perl data structures. It also
understand IO::Handle types and Moose objects.

=head2 Rules

The rules passed to C<matcher()> can be either an array reference, hash
reference, regexp reference or string. If you specify a regexp or string, they
will be converted to an array reference.

The type of data you specify is used in deciding matching heuristics. Here is a
chart that covers the behavior:

 +-----------------------------------------------------------------------------+
 | Flag       | Rule   | Data    | Explination                                 |
 +------------+--------+---------+---------------------------------------------+
 | -keys      | Array  | Hash    | Matches values of Rule to keys of Data      |
 | -noKeys    | Array  | Hash    | Matches values of Rule to values of Data    |
 | -keys      | Array  | Array   | No effect                                   |
 | -noKeys    | Array  | Array   | No effect                                   |
 | -keys      | Hash   | Hash    | Matches keys of Rule to keys of Data        |
 | -noKeys    | Hash   | Hash    | Matches keys and values of both hashes      |
 | -keys      | Hash   | Array   | Matches keys of Rule against Array values   |
 | -noKeys    | Hash   | Array   | Matches values of Rule against Array values |
 | -indexed   | Hash   | Array   | No effect                                   |
 | -noIndexed | Hash   | Array   | No effect                                   |
 | -indexed   | Hash   | Hash    | No effect                                   |
 | -noIndexed | Hash   | Hash    | No effect                                   |
 | -indexed   | Array  | Array   | Matches Rule to Data array in index order   |
 | -noIndexed | Array  | Array   | Matches Rule to Data in any order           |
 +-----------------------------------------------------------------------------+


=head2 Sub-Rules

Any array or hash references found will be converted into Data::Matcher::Rule
objects. For example:

    # this will match an array with values ( foo and bar and ( baz or bat ) )
    # it will also match a hash with keys ( foo and bar and ( baz or bat ) )
    matcher [
        -all => 1, qw(foo bar),
        [ -all => 0, qw(baz bat) ]
    ], $data;
    # Notes
    #   1. The second -all above is not needed as Data::Matcher::Rule defaults to 0
    #   2. To prevent the above from matching a hash as well as an array use:
    #      -typeConstraint => 'ArrayRef'


    matcher {
        -typeConstraint => 'HashRef',
        -all => 1,
        foo => 1,
        bar => [
            -typeConstraint => 'ArrayRef',
            -all => 1,
            qw(bar bat)
        ]
    }, $data; 

=head1 Flags

There are two methods to enable/disable flags in the parsing options. The first
way is with C<-flags> and C<-noFlags>. These allow you to pass in an array ref
of flags to enable/disble.

=over

=item C<< -flags => [qw(list of flags to enable)] >>

    # turns on the flags 'keys' and 'only'
    matcher [ -flags => [ qw( keys only ) ], qw(stuff) ], $data;

=item C<< -noFlags => [qw(list of flags to disable)] >>

    # turns off the flags 'index' and 'all'
    matcher [ -noFlags => [ qw( index all ), qw(stuff) ], $data

=back

The other method is passing in the flags one at a time. Flags always start
with a dash. The value in that case will be a boolean.

    # turns on the flags 'keys' and 'only'
    matcher [ -keys => 1, -only => 1, qw(stuff) ], $data;

    # turns off the flags 'index' and 'all'
    matcher [ -indexed => 0, -all => 1, qw(stuff) ], $data


=head2 List Flags

These flags control how lists are matched.

=over

=item C<< -indexed => 0|1 >> default 0

This flag is only valid when matching against an array and will be ignored if
set while matching a hash.

This flag causes the matcher to perform tests in order, starting from index
zero in the matching array and in the data array. Flags are not counted when
finding the index, only rules that can match. This does not enforce any limits
on the number of elements in the data we are matching, see C<-only> for that.
For example:

    #  Will not match
    matcher [ -indexed => 1, qw(foo bar baz) ], [ qw( bar baz foo ) ];

    #  Will match
    matcher [ qw(foo bar baz) ], [ qw( bar baz foo ) ];

    #  Will match
    matcher [ -indexed => 1, qw(foo bar baz) ], [ qw( foo bar baz ) ];

    #  Will match
    matcher [ -indexed => 1, qw(foo bar baz) ], [ qw( foo bar baz bat ) ];

    #  Will not match, bat is index 0, foo is matching on index 0
    matcher [ -indexed => 1, qw(foo bar baz) ], [ qw( bat foo bar baz ) ];


=item C<< -all => 0|1 >> default 0

This flag turns matching into an I<AND> process. All rules must match, including
sub-rules and type constraints. For example:

    # matches (order isn't important, see -indexed for that)
    matcher [ -all => 1, qw(you there) ], [ qw(there you are) ];

    # no match, both 'you' and 'these' must match
    matcher [ -all => 1, qw(you there) ], [ qw(you) ];

Also aliased:

=over

=item C<< -any => 0|1 >>

turns on -all when true

=item C<< -and => 0|1 >>

turns on -all when true

=item C<< -or => 0|1 >>

turns off -all when true

=back


=item C<< -only => 0|1 >> default 0

This flag adds an additional test after matching. It ensure that the number
of elements in the array are the same as the number of tests we've performed.
For example:

    # will not match
    matcher [ -only => 1, qw(foo bar) ], [ qw(foo bar baz) ];

    # will match
    matcher [ -only => 0, qw(foo bar) ], [ qw(bar) ]; # only need one match

Also aliased:

=over

=item C<< -noOnly => 0|1 >>

=back


=item C<< -keys => 0|1 >>

For array matching a hash, this check the keys of the hash
 
=over

=item C<< -noKeys => 0|1 >>

turns off C<-keys> when true

=item C<< -values => 0|1 >>

turns off C<-keys> when true

=item C<< -noValues => 0|1 >>

turns on C<-keys> when true

=back

=back

=head2 String Flags

These flags determine what type of match is attempted when Data::Matcher
encounters a string in matching rules.

NB: These flags change how both keys and values are treated if you specified a
hash as matching rules.

=over

=item C<< substr => 0|1 >>

All strings encountered in rules will be matched using C<substr()>.

    # Will match foobly
    matcher [ -substr => 1, 'foo' ], $data;

=item C<< mooseType => 0|1 >>

All strings encountered in rules will be coerced into L<Moose::Meta::Constraint> objects.
If the rule can not be coerced and C<use warnings;> is set, a warning will be issued.

    # checks if $data has an array ref in it.
    matcher [ -mooseType => 1, "ArrayRef" ], $data;

=item C<< regex => 0|1 >>

All strings encountered is rules are treated as regular expressions.

    # match anything starting with foo
    matcher [ -regex => 1, "^foo.*" ], $data;

=back

=head2 Global Flags

These are flags that, when present, are set for the whole instance instead of
just the context they are in. In other words, it's the same as setting them on
the object it's self before calling C<$obj-E<gt>parse()>. For example the
following are equivalent:

    Data::Matcher::Rule->new( typeConstraint => 'HashRef' )
                       ->parse( { foo => 1 } )
                       ->match( $data )

    Data::Matcher::Rule->new
                       ->parse( { -typeConstraint => 'HashRef', foo => 1 } )
                       ->match( $data )

=over

=item C<< -typeConstraint => DMTypeConstraint >>

This allows you to check the type of data being matched on for the current
Rule. If set to a string, this will be coerced into a
L<Moose::Meta::TypeConstraint> via L<Moose::Util::TypeConstraints/"Type
Constraint Constructors">.

=back

=head2 Moose

From the Moose documentation I<Moose is an extension of the Perl 5 object
system>. Moose is involved in Data::Matcher in three ways.

Moose objects can be matched upon. They are treated like a hash. Keys are the
attribute accessor names and values are the return of calling the accessor.
Attributes are called as late as possible using L<Tie::MooseObject> internally.

Moose type constraints can be passed in for matching options. You can also tell
Data::Matcher to treat all strings as Moose type constraints in the current
context. This is a parsing option you can enable and disable it from within the
matching options with C<-mooseType =E<gt> 1|0>. See L<Data::Matcher/"String
Options">, L<Moose::Util::TypeConstraints> and L<Moose::Meta::TypeConstraint>.

=head1 EXPORTS

=over

=item C<matcher($rules, $data)>

Expects matching rules as the first argument and the data to match against
as the second.

=back

=cut

