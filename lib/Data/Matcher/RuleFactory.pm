package Data::Matcher::RuleFactory;
use namespace::autoclean;
use MooseX::AbstractFactory;
implementation_does qw/Data::Matcher::RuleFactory::Requires/;
implementation_class_via sub {
    my $impl = shift;
    $impl = $impl =~ /^\+(.+)/ ? $1 : 'Data::Matcher::Rule::' . $impl;
    return $impl;
};

1;


