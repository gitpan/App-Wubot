package App::Wubot::Reactor::HashLookup;
use Moose;

our $VERSION = '0.5.0'; # VERSION

use App::Wubot::Logger;

sub react {
    my ( $self, $message, $config ) = @_;

    my $key = $message->{ $config->{source_field} };

    return $message unless $key;

    if ( exists $config->{lookup}->{ $key } ) {
        $message->{ $config->{target_field} } = $config->{lookup}->{ $key };
    }

    return $message;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

App::Wubot::Reactor::HashLookup - map the value of one field to a value for another using a lookup table

=head1 VERSION

version 0.5.0

=head1 SYNOPSIS

      - name: look up nicknames for friends
        plugin: HashLookup
        config:
          source_field: username
          target_field: nickname
          lookup:
            lebowski: dude
            someguy: nickname
            john.smith: john


=head1 DESCRIPTION

Look up the value for a target field in a configured hash using the
value of another field as the key.

=head1 SUBROUTINES/METHODS

=over 8

=item react( $message, $config )

The standard reactor plugin react() method.

=back
