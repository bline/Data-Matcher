use strict;
#ABSTRACT: trait for attributes which can be set via option parsing.

package Data::Matcher::Meta::Attribute::Trait::CanConfigure;
    use Moose::Role;
    use MooseX::Has::Sugar;
    use MooseX::Types::Moose qw( Bool );

    has 'is_dm_global' => ( isa => Bool, default => 0, rw );
    has 'is_dm_local' => ( isa => Bool, default => 1, rw );

1;
__END__

=head1 DESCRIPTION

This module sets up traits for configurable attributes that can be either
local or global. Global attributes are ones that are setup during the initial
parsing of matching rules. Local attributes are attributes that
can be set while matching data. This can be very useful to change how the data
is matched. See L<Data::Matcher/Rules> for more details.

=cut

