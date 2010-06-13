#!perl

use strict;
use warnings;

use Test::More tests => 3;

BEGIN { use_ok( 'Data::Matcher' ) }

ok( defined &matcher, 'exported matcher by default' );
ok( !eval { matcher( 'foo' ) }, 'matcher invalid arguments' );
