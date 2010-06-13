use strict;
package Data::Matcher::Rule; # for Pod::Weaver
#ABSTRACT: main code for Data-Matcher, does matching based on rules given 

use MooseX::Declare 0.33;
class Data::Matcher::Rule {
    use warnings::register;
    use MooseX::Has::Sugar 0.0405;
    use MooseX::MultiMethods 0.10;
    use Moose::Util::TypeConstraints qw( subtype );
    use MooseX::Types::Structured 0.21 qw( Dict );
    use MooseX::Types::Moose 0.21 qw( Str Bool Ref CodeRef ArrayRef HashRef RegexpRef );
    use Data::Matcher::Types  qw( DMTypeConstraint DMIOHandle DMRule DMRuleOption );
    use List::MoreUtils 0.22 qw( all any );
    use IO::Handle 1.28 qw(SEEK_SET);
    use Tie::MooseObject 0.0001;

#    has 'parent' => (
#        isa => 'Data::Matcher::Rule',
#        weak_ref, required, ro
#    );

    has '_rules' => (
        traits => ['Array'],
        isa => ArrayRef[Dict[ type => Str, code => CodeRef]],
        default => sub { [] },
        handles => {
            append_rule => 'push',
            count_rules => 'count',
            get_rule => 'get',
            set_rule => 'set',
            clear_rules => 'clear',
            all_rules => 'elements'
        },
        ro
    );

    has '_hash_type' => (
        isa => Bool,
        default => 0,
        rw
    );

    has 'typeConstraint' => (
        isa => DMTypeConstraint,
        traits => [qw/CanConfigure/],
        is_dm_global => 1,
        coerce => 1,
        rw
    );

    has 'disableFlagParsing' => (
        isa => Bool,
        traits => [qw/Bool CanConfigure/],
        default => 0,
        handles => {
            enableFlagParsing => [ set => 1 ],
        },
        rw
    );

    has 'all' => (
        isa => Bool,
        traits => [qw/Bool CanConfigure/],
        default => 0,
        handles => {
            any => [ set => 0 ],
            and => [ set => 1 ],
            or  => [ set => 0 ]
        },
        rw
    );
    has 'indexed' => (
        isa => Bool,
        traits => [qw/Bool CanConfigure/],
        default => 0,
        handles => {
             unIndexed => [ set => 0 ],
        },
        rw
    );
    has 'only' => (
        isa => Bool,
        traits => [qw/Bool CanConfigure/],
        default => 0,
        handles => {
            noOnly    => [ set => 0 ],
        },
        rw
    );
    has 'keys' => (
        isa => Bool,
        traits => [qw/Bool CanConfigure/],
        default => 0,
        handles => {
            values => [ set => 0 ],
            noValues => [ set => 1 ],
            noKeys => [ set => 0 ],
        },
        rw
    );

    has 'substr' => (
        isa => Bool,
        traits => [qw/Bool CanConfigure/],
        default => 0,
        handles => {
            exact => [ set => 0 ],
            noExact => [ set => 1 ],
            noSubstr => [ set => 0 ],
        },
        rw
    );

    has 'mooseType' => (
        isa => Bool,
        traits => ['Bool'],
        default => 0,
        handles => {
            noMooseType => [ set => 0 ],
        },
        rw
    );

    has 'regex' => (
        isa => Bool,
        traits => [qw/Bool CanConfigure/],
        default => 0,
        handles => {
            noRegex => [ set => 0 ]
        },
        rw
    );

    method _check_set_flag( Str $flag, Any $value ) {
        my @flags = ( $flag );
        if ( $flag eq 'flags' or $flag eq 'noFlags' and ref( $value ) eq 'ARRAY' ) {
            @flags = @$value;
            $value = $flag eq 'flags';
        }
        my $match = 0;
        for my $flag ( @flags ) {
            if ( $self->_is_flag_global( $flag ) ) {
                $self->$flag( $value );
                $match = 1;
            }
            elsif ( $self->_is_flag_local( $flag ) ) {
                $self->append_rule( { type => 'flag', code => sub {
                    #my ($pkg, $file, $line) = caller; warn "set $flag => $value at $file $line.\n";
                    $self->$flag( $value )
                } } );
                $match = 1;
            }
            else {
                warnings::warnif( "Invalid flag $flag" );
            }
        }
        return $match;
    }
    method _is_flag_global( Str $name ) {
        return grep {
               $_->name eq $name 
            && $_->can( 'associated_attribute' )
            && $_->associated_attribute->can( 'is_dm_global' )
            && $_->associated_attribute->is_dm_global
        } $self->meta->get_all_methods;
    }
    method _is_flag_local( Str $name ) {
        return grep {
               $_->name eq $name 
            && $_->can( 'associated_attribute' )
            && $_->associated_attribute->can( 'is_dm_local' )
            && $_->associated_attribute->is_dm_local
        } $self->meta->get_all_methods;
    }

    around check( $arg ) {
        if ( $self->typeConstraint ) {
            return 0 unless $self->typeConstraint->check( $arg );
        }
        $self->$orig( $arg );
    }

    multi method check( Object $data ) {
        my $meta = Class::MOP::Class->initialize( ref $data );
        warn ">>>>>>>>>>>>>>>>>>>>>>>> HERE <<<<<<<<<<<<<<<<<<<<<<";
        if ( any { $_->has_read_method } $meta->get_all_attributes ) {
        warn ">>>>>>>>>>>>>>>>>>>>>>>> HERE <<<<<<<<<<<<<<<<<<<<<<";
            my %object;
            tie %object, 'Tie::MooseObject', $data, ro;
            use Data::Dumper;
            warn "]]]]]]]]]]]]]]]] Matching on: ", Dumper( \%object ), "\n";
            return $self->check( \%object );
        }
        warn ">>>>>>>>>>>>>>>>>>>>>>>> HERE <<<<<<<<<<<<<<<<<<<<<<";
        my $to_string = $data->can( 'toString' ) || $data->can( 'to_string' ) || $data->can( 'value' );
        if ( $to_string ) {
        warn ">>>>>>>>>>>>>>>>>>>>>>>> HERE <<<<<<<<<<<<<<<<<<<<<<";
            return $self->check( [ $data->$to_string() ] );
        }
        warn ">>>>>>>>>>>>>>>>>>>>>>>> HERE <<<<<<<<<<<<<<<<<<<<<<";
        warnings::warnif("Can not find a way to handle " . ref($data));
        return 0;
    }

    multi method check( DMIOHandle $io ) {
        my $seek;
        $io->$seek( 0, SEEK_SET ) if $seek = $io->can( 'seek' );
        while ( defined( my $line = $io->getline ) ) {
            return 1 if $self->check( [ $line ] );
        }
        $io->$seek( 0, SEEK_SET ) if $seek;
        return 0;
    }

    multi method check( ArrayRef $data ) {
        my $opt = $self->_rules;
        my $num_tests = 0;
        my $match;
        for ( my $i = 0; $i < @$opt; ++$i ) {
            my $cur = $opt->[$i];
            my $nxt = $opt->[$i + 1];
            if ( $cur->{type} eq 'flag' ) {
                $cur->{code}->();
            }
            elsif ( $cur->{type} eq 'match' ) {
                if ( !$self->_hash_type || $self->keys ) {
                    if ( $self->indexed ) {
                        $match = $cur->{code}->( $data->[ $num_tests ] );
                    }
                    else {
                        $match = any { $cur->{code}->( $_ ) } @$data;
                    }
                    $num_tests++;
                }
                else {
                    $match = any { $nxt->{code}->( $_ ) } @$data;
                    $num_tests++;
                }
                if ( $self->and and !$match ) {
                    last;
                }
                elsif ( $self->or and $match ) {
                    last;
                }
            }
            else {
                die "Invalid match type $cur->{type}";
            }
            ++$i if $self->_hash_type;
        }

        if ( $match and $self->only and $num_tests != keys %$data ) {
            $match = 0;
        }
        return $match;
    }

    multi method check( HashRef $data ) {
        my $opt = $self->_rules;
        my $num_tests = 0;
        my $match;
        for ( my $i = 0; $i < @$opt; ++$i ) {
            my $cur = $opt->[$i];
            my $nxt = $opt->[$i + 1];
            warn "** working on $i: $cur";
            if ( $cur->{type} eq 'flag' ) {
                warn "** is flag";
                $cur->{code}->();
            }
            elsif ( $cur->{type} eq 'match' ) {
                warn "** is match";
                if ( $self->keys ) {
                    $num_tests++;
                    warn "** has keys set";
                    $match = any { warn "** testing $_"; $cur->{code}->( $_ ) } keys %$data;
                }
                elsif ( $self->_hash_type ) {
                    warn "** _hash_type";
                    $num_tests++;
                    $match = any {
                        warn "** testing $_ => $data->{$_}";
                        $cur->{code}->( $_ ) && $nxt->{code}->( $data->{$_} )
                    } keys %$data;
                }
                else {
                    warn "** not hash or keys";
                    $num_tests++;
                    $match = any { warn "** testing $_"; $cur->{code}->( $_ ) } values %$data;
                }
                if ( $self->and and !$match ) {
                    warn "** last for no match and";
                    last;
                }
                elsif ( $self->or and $match ) {
                    warn "** last for match or";
                    last;
                }
            }
            else {
                die "Invalid match type $cur->{type}";
            }
            ++$i if $self->_hash_type;
        }

        warn "** finished loop";
        if ( $match and $self->only and $num_tests != keys %$data ) {
            warn "** setting match to 0 for only test";
            $match = 0;
        }
        return $match;
    }

    multi method _parse_rule( RegexpRef $rule ) {
        $self->append_rule( { type => 'match', code => sub { $_[0] =~ $rule } } );
    }
    multi method _parse_rule( Str $rule ) {
        $self->append_rule( { type => 'match', code => sub {
            if ( $self->substr ) {
                return substr( $_[0], $rule );
            }
            elsif ( $self->regex ) {
                return $_[0] =~ /$rule/;
            }
            elsif ( $self->mooseType ) {
                my $type = eval { subtype( @_ ) };
                warnings::warnif( "$@" ) if $@;
                return $type->check( $_[0] ) if $type;
            }
            return $_[0] eq $rule;
        } } );
        return $self;
    }
    multi method _parse_rule( ArrayRef|HashRef $rule ) {
        $self->append_rule( { type => 'match', code => sub {
            ref( $self )->new
                        ->parse( $rule )
                        ->check(@_)
        } } );
        return $self;
    }

    multi method _parse_rule( DMTypeConstraint|DMRule $rule ) {
        $self->append_rule( { type => 'match', code => sub { $rule->check(@_) } } );
        return $self;
    }

    multi method _parse_rule( CodeRef $rule ) {
        $self->append_rule( { type => 'match', code => $rule } );
        return $self;
    }

    method parse( DMRuleOption $rules ) {
        my $opts;
        if ( is_HashRef( $rules ) ) {
            $self->keys( 0 );
            $self->_hash_type( 1 );
            $opts = [ %$rules ];
        }
        elsif ( is_ArrayRef( $rules ) ) {
            $self->keys( 1 );
            $opts = [ @$rules ];
        }
        else {
            $self->keys( 1 );
            $opts = [ $rules ];
        }
        for ( my $i = 0; $i < @$opts; ++$i ) {
            my ( $k, $v ) = @{$opts}[$i, $i+1];
            if ( !is_Ref( $k ) and $k =~ /^-(\w+)/ ) {
                my $flag = $1;
                if ( $self->_check_set_flag( $flag, $v ) ) {
                    $i++;
                }
                else {
                    $self->_parse_rule( $k );
                    $self->_parse_rule( $v ) if $i != $#$opts;
                    $i++ if $self->_hash_type;
                }
            }
            else {
                $self->_parse_rule( $k );
                $self->_parse_rule( $v ) if $i != $#$opts;
                $i++ if $self->_hash_type;
            }
        }
        return $self;
    }
}

1;

__END__

=head1 DESCRIPTION

This is the workhorse of L<Data::Matcher>. All matching work is done in this
module. If you need to add special handling for certain data types or certain
objects you will subclass this module.

=cut
