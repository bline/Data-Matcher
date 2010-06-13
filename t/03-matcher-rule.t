#!perl

use strict;
use warnings;

use Test::More 'no_plan';

use_ok( 'Data::Matcher::Rule' );

select((select(STDERR), $|=1)[0]);
# methods
can_ok( 'Data::Matcher::Rule', 'new' );
can_ok( 'Data::Matcher::Rule', 'parse' );
can_ok( 'Data::Matcher::Rule', 'check' );

# attributes
can_ok( 'Data::Matcher::Rule', 'disableFlagParsing' );
can_ok( 'Data::Matcher::Rule', 'keys' );
can_ok( 'Data::Matcher::Rule', 'regex' );
can_ok( 'Data::Matcher::Rule', 'mooseType' );
can_ok( 'Data::Matcher::Rule', 'substr' );
can_ok( 'Data::Matcher::Rule', 'only' );
can_ok( 'Data::Matcher::Rule', 'indexed' );
can_ok( 'Data::Matcher::Rule', 'all' );

isa_ok my $m = Data::Matcher::Rule->new, 'Data::Matcher::Rule', '->new constructs a new instance';
check_bool( $m, 'disableFlagParsing', 0 );
check_bool( $m, 'regex', 0 );
check_bool( $m, 'keys', 0 );
check_bool( $m, 'mooseType', 0 );
check_bool( $m, 'substr', 0 );
check_bool( $m, 'only', 0 );
check_bool( $m, 'indexed', 0 );
check_bool( $m, 'all', 0 );

subtest( 'simple array', sub {
    plan 'no_plan';
    $m->clear_rules;
    ok( !$m->count_rules, '->clear_rules resets rules' );
    isa_ok $m->parse( ["foo"] ), ref( $m ), "->parse returns same instance";
    ok( $m->keys, '->parse(ArrayRef) defaults keys attribute to on' );
    ok( $m->check( ["foo"] ), '->check simple array match' );
    ok( !$m->check( ["fo"] ), '->check simple array non-match' );
    ok( $m->check( [{}, qw/bar bax foo/] ), '->check multi-value array match' );
    ok( !$m->check( [{}, qw/bar bax boo/] ), '->check multi-value array non-match' );
    ok( $m->check( { "foo" => 1 } ), '->check simple hash match' );
    ok( !$m->check( { "fo" => 1 } ), '->check simple hash non-match' );
    ok( $m->check( { bar => 1, baz => {}, bat => [], "foo" => 1 } ), '->check multi value hash match' );
    ok( !$m->check( { bar => 1, baz => {}, bat => [], "oo" => "foo" } ), '->check multi value hash non-match' );
});

subtest( 'simple array keys disabled', sub {
    plan 'no_plan';
    $m->clear_rules;
    ok( !$m->count_rules, '->clear_rules resets rules' );
    isa_ok $m->parse( [ -keys => 0, "foo"] ), ref( $m ), "->parse returns same instance";
    ok( $m->check( ["foo"] ), '->check simple array match' );
    ok( !$m->check( ["fo"] ), '->check simple array non-match' );
    ok( $m->check( [{}, qw/bar bax foo/] ), '->check multi-value array match' );
    ok( !$m->check( [{}, qw/bar bax boo/] ), '->check multi-value array non-match' );
    ok( $m->check( { "bar" => "foo" } ), '->check simple hash match' );
    ok( !$m->check( { "bar" => "fo" } ), '->check simple hash non-match' );
    ok( $m->check( { baz => [], bat => {}, boo => "foo", "bar" => "foo" } ), '->check multi value hash match' );
    ok( !$m->check( { baz => [], bat => {}, boo => "1", foo => "bar" } ), '->check multi value hash non-match' );
});

subtest( 'simple hash', sub {
    plan 'no_plan';
    $m->clear_rules;
    ok( !$m->count_rules, '->clear_rules resets rules' );
    isa_ok $m->parse( { "foo" => 'bar' } ), ref( $m ), "->parse returns same instance";
    ok( !$m->keys, '->parse(HashRef) defaults keys attribute to off' );
    ok( $m->check( ["bar"] ), '->check simple array match' );
    ok( !$m->check( ["ba"] ), '->check simple array non-match' );
    ok( $m->check( [{}, qw/bar bax foo/] ), '->check multi-value array match' );
    ok( !$m->check( [{}, qw/ba bax foo boo/] ), '->check multi-value array non-match' );
    ok( $m->check( { "foo" => 'bar' } ), '->check simple hash match' );
    ok( !$m->check( { "foo" => 'ba' } ), '->check simple hash non-match' );
    ok( $m->check( { bar => 1, foo => 'bar', bat => [] } ), '->check multi value hash match' );
    ok( !$m->check( { bar => 1, baz => {}, bat => [], "oo" => "bar" } ), '->check multi value hash non-match' );
});

sub check_bool {
    my ( $obj, $name, $default ) = @_;
    my $orig = $obj->$name;
    is( $orig, $default, "->$name defaulted correctly" );
    for ( 0 .. 1 ) {
        $obj->$name( $_ );
        cmp_ok( $obj->$name, '==', $_, "->$name set to $_" );
    }
    ok( !eval { $obj->$name( "not bool" ) }, "->$name doesn't accept non-boolean" );
    $obj->$name( $orig );
}
