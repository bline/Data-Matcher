use strict;
#ABSTRACT: internal trait
package Moose::Meta::Attribute::Custom::Trait::CanConfigure;
BEGIN {
  $Moose::Meta::Attribute::Custom::Trait::CanConfigure::VERSION = '0.0003';
}
sub register_implementation {'Data::Matcher::Meta::Attribute::Trait::CanConfigure'}

1;



=pod

=head1 NAME

Moose::Meta::Attribute::Custom::Trait::CanConfigure - internal trait

=head1 VERSION

version 0.0003

=head1 DESCRIPTION

This module tells Moose about L<Data::Matcher::Meta::Attribute::Trait::CanConfigure>

Nothing to look at here.. move along.

=for Pod::Coverage     register_implementation

=head1 AUTHOR

  Scott Beck <scottbeck@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Scott Beck.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__


