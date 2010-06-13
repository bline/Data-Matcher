use strict;
#ABSTRACT: trait for attributes which can be set via option parsing.

package Data::Matcher::Meta::Attribute::Trait::CanConfigure;
BEGIN {
  $Data::Matcher::Meta::Attribute::Trait::CanConfigure::VERSION = '0.0002';
}
    use Moose::Role;
    use MooseX::Has::Sugar;
    use MooseX::Types::Moose qw( Bool );

    has 'is_dm_global' => ( isa => Bool, default => 0, rw );
    has 'is_dm_local' => ( isa => Bool, default => 1, rw );

1;


=pod

=head1 NAME

Data::Matcher::Meta::Attribute::Trait::CanConfigure - trait for attributes which can be set via option parsing.

=head1 VERSION

version 0.0002

=head1 DESCRIPTION

This module sets up traits for configurable attributes that can be either
local or global. Global attributes are ones that are setup during the initial
parsing of matching rules. Local attributes are attributes that
can be set while matching data. This can be very useful to change how the data
is matched. See L<Data::Matcher/Rules> for more details.

=head1 AUTHOR

  Scott Beck <scottbeck@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Scott Beck.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__


