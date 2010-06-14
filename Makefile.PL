
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'simple matching on perl data structures and moose objects',
  'AUTHOR' => 'Scott Beck <scottbeck@gmail.com>',
  'BUILD_REQUIRES' => {
    'English' => '0',
    'Test::More' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'Data-Matcher',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Data::Matcher',
  'PREREQ_PM' => {
    'Carp' => '0',
    'Data::Dumper' => '0',
    'IO::Handle' => '1.28',
    'List::MoreUtils' => '0.22',
    'Moose' => '1.03',
    'Moose::Role' => '0',
    'Moose::Util::TypeConstraints' => '0',
    'MooseX::Declare' => '0.33',
    'MooseX::Has::Sugar' => '0.0405',
    'MooseX::MultiMethods' => '0.10',
    'MooseX::Types' => '0',
    'MooseX::Types::Moose' => '0.21',
    'MooseX::Types::Structured' => '0.21',
    'Tie::MooseObject' => '0.0001',
    'warnings::register' => '0'
  },
  'VERSION' => '0.0003',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



