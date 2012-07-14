package App::Wubot::Util::AgeColor;
use Moose;

our $VERSION = '0.5.0'; # VERSION

use POSIX;
use YAML::XS;

use App::Wubot::Util::Colors;
use App::Wubot::Logger;

has 'color' => ( is => 'rw',
                 isa => 'App::Wubot::Util::Colors',
                 lazy => 1,
                 default => sub {
                     return App::Wubot::Util::Colors->new();
                 }
             );

has 'colormap' => ( is => 'rw',
                    isa => 'HashRef',
                    lazy => 1,
                    default => sub {
                        my $self = shift;
                        return { -600           => $self->color->get_color( 'deeppink' ),
                                 60*60          => $self->color->get_color( 'purple' ),
                                 60*60*24       => $self->color->get_color( 'darkblue' ),
                                 60*60*24*2     => $self->color->get_color( 'cyan' ),
                                 60*60*24*7     => $self->color->get_color( 'green' ),
                                 60*60*24*14    => $self->color->get_color( 'yellow' ),
                                 60*60*24*30    => $self->color->get_color( 'orange' ),
                                 60*60*24*365   => $self->color->get_color( 'black' ),
                             };
                    },
                );

has 'logger'  => ( is => 'ro',
                   isa => 'Log::Log4perl::Logger',
                   lazy => 1,
                   default => sub {
                       return Log::Log4perl::get_logger( __PACKAGE__ );
                   },
               );

sub get_age_color {
    my ( $self, $seconds, $scale ) = @_;

    unless ( $scale ) {
        $scale = 1;
    }

    my ( $start, $end ) = $self->_get_range_limits( $seconds );
    $self->logger->debug( "Getting color range for $seconds [ $start .. $end ]" );

    my ( $start_r, $start_g, $start_b ) = $self->_get_rgb_colors( $self->colormap->{$start} );
    my ( $end_r,   $end_g,   $end_b   ) = $self->_get_rgb_colors( $self->colormap->{$end}   );

    my $r = $self->_range_map( $seconds, $start, $end, $start_r, $end_r ) * $scale;
    my $g = $self->_range_map( $seconds, $start, $end, $start_g, $end_g ) * $scale;
    my $b = $self->_range_map( $seconds, $start, $end, $start_b, $end_b ) * $scale;

    return $self->_get_hex_color( $r, $g, $b );
}

sub _get_range_limits {
    my ( $self, $seconds ) = @_;

    my $found = 0;

    my @keys = sort { $a <=> $b } keys %{ $self->colormap };

    for my $idx ( reverse( 0 .. $#keys ) ) {
        if ( $seconds >= $keys[ $idx ] ) {
            $found = $idx;
            last;
        }
    }

    my $found_upper = $found + 1;
    if ( $found_upper > $#keys ) {
        $found--;
        $found_upper--;
    }

    my $lower = $keys[$found];
    my $upper = $keys[$found_upper];

    return ( $lower, $upper );
}

sub _get_hex_color {
    my ( $self, $r, $g, $b ) = @_;

    #print "GET HEX COLOR: $r $g $b\n";

    my $color = "#";

    for my $col ( $r, $g, $b ) {
        if ( $col > 255 ) { $col = 255 }
        $color .= sprintf( "%02x", $col );
    }

    $self->logger->debug( "Hex color: $color" );

    return $color;
}

sub _get_rgb_colors {
    my ( $self, $hexcolor ) = @_;

    unless ( $hexcolor =~ m|(\w\w)(\w\w)(\w\w)$| ) {
        self->logger->logdie( "ERROR: unable to parse hex color $hexcolor" );
    }

    my @hex;
    push @hex, hex( $1 );
    push @hex, hex( $2 );
    push @hex, hex( $3 );

    return @hex;
}

sub _range_map {
    my ( $self, $value, $low1, $high1, $low2, $high2 ) = @_;

    my $orig_value = $value;

    # ensure value is within low1 and high1
    if    ( $value < $low1  ) { $value = $low1  }
    elsif ( $value > $high1 ) { $value = $high1 }

    my $ratio = ( $high2 - $low2 ) / ( $high1 - $low1 );

    $value -= $low1;

    $value *= $ratio;

    $value += $low2;

    #print "MAP: $orig_value => $value [ $low1 .. $high1 ] [ $low2 .. $high2 ]\n";

    return $value;
}

1;

__END__


=head1 NAME

   App::Wubot::Util::AgeColor - define colors based on the age of items


=head1 VERSION

version 0.5.0

=head1 SYNOPSIS

  use App::Wubot::Util::AgeColor;

  # the 'colormap' defines the colors for specific ages in seconds
  my $colormap = { 0            => '6c003f',
                   60*60*24     => '440066',
                   60*60*24*7   => '002b66',
                   60*60*24*30  => '004a00',
                   60*60*24*365 => '804c00',
               };

  my $colorer = App::Wubot::Util::AgeColor->new( { colormap => $colormap } );

  # get the age color for something that just happened right now, 6c003f
  print $colorer->get_age_color( 0 ), "\n";

  # get the age color for 1 day old, #440066
  print $colorer->get_age_color( 60*60*24 ), "\n";

  # get the age color for 12 hours old, #580052
  print $colorer->get_age_color( 60*60*12 ), "\n";

  # get a smooth gradient of colors between 6c003f and 440066
  for my $hours ( 0 .. 24  ) {
      print $colorer->get_age_color( $hours * 3600 ), "\n";

  }


=head1 DESCRIPTION

This library is used to colorize an item or field based on its age in
seconds.  This helps to very quickly assess the age of an item in the
web interface by looking at the color.

A steady stream of items with evenly spaced ages will create a smooth
gradient of color.

=head1 App::Wubot



=head1 SUBROUTINES/METHODS

=over 8

=item $obj->get_age_color( $seconds )

Return a hex color based on the specified age in seconds.

=back
