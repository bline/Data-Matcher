#!perl

use strict;
use warnings;

use Test::More;

plan tests => 3;
use_ok( 'Data::Matcher' );
use_ok( 'Data::Matcher::Rule' );
use_ok( 'Moose::Meta::Attribute::Custom::Trait::CanConfigure' );



