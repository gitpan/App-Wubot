package App::Wubot::Util::TimeLength;
use Moose;

our $VERSION = '0.5.0'; # VERSION

use POSIX;
use YAML::XS;

use App::Wubot::Logger;

=head1 NAME

App::Wubot::Util::TimeLength - utilities for dealing with time durations


=head1 VERSION

version 0.5.0

=head1 SYNOPSIS

    use App::Wubot::Util::TimeLength;

    my $timelength = App::Wubot::Util::TimeLength->new();

    # returns '1h1m'
    $timelength->get_human_readable( 3601 );

    # returns 1.5
    $timelength->get_hours( 60*60*1.5 );

    # returns 3601
    $timelength->get_seconds( '1h1s' );

    # rounds 1.5 days, 1 minute, and 10 seconds to nearest hour: 1d12h
    $timelength->get_human_readable( 60*60*24*1.5+70 )

    # use a space delimiter
    my $timelength = App::Wubot::Util::TimeLength->new( space => 1 ),

    # returns '1h 1s' with space delimiter
    $timelength->get_human_readable( 3601 );


=head1 DESCRIPTION

This class provides some utilities for dealing with time durations.
It supports the 'compact' form used by L<Convert::Age>, but with a few
variations.

For the sake of simplicity, one month is always treated as 30 days,
and one year is always represented as 365 days.

=cut

has 'space' => ( is => 'ro', isa => 'Bool', default => 0 );

my $constants = { s => 1,
                  S => 1,
                  m => 60,
                  h => 60*60,
                  H => 60*60,
                  d => 60*60*24,
                  D => 60*60*24,
                  w => 60*60*24*7,
                  W => 60*60*24*7,
                  M => 60*60*24*30,
                  y => 60*60*24*365,
                  Y => 60*60*24*365,
              };

=head1 SUBROUTINES/METHODS

=over 8

=item $obj->get_seconds( $time );

When given a date in the 'compact' form (e.g. '1h1m' or '1h 1m'),
returns the number of seconds.

=cut

sub get_seconds {
    my ( $self, $time ) = @_;

    my $seconds = 0;

    return $seconds unless $time;

    $time =~ s|^\+||;

    # space-separate time fields for easier split
    $time =~ s|([a-zA-Z])|$1 |;

    for my $part ( split /\s+/, $time ) {

        if ( $part =~ m|^(\-?[\d\.]+)(\w)$| && $constants->{$2} ) {
            $seconds += $1 * $constants->{$2};
        }
        elsif ( $part =~ m|^(\-?\d+)$| ) {
            $seconds += $1;
        }
        elsif ( $part =~ m|^(\w)$| && $constants->{$1} ) {
            # empty = 0 more seconds
        }
        else {
            die "ERROR: unable to parse time: $part";
        }
    }

    return $seconds;

}

=item $obj->get_human_readable( $seconds );

Given a number of seconds, return the time in 'compact' form.  For
example, '3601' seconds returns '1h1s'.

Time lengths are rounded to the most significant two fields.  For
example, 1 day, 1 hour, 1 minute, and 1 second would be rounded to
1d1h.  Obviously this method is not intended for precise time
calculations, but rather for human-friendly ones.  Please don't try to
convert a number of seconds to the human-readable format, and then
convert that back to a number of seconds, as it will likely be
different due to rounding!!! If you do not want to have times rounded,
use L<Convert::Age>.

If the 'space' option was set at construction time, then a space
delimiter will be used in the resulting string, e.g. '1h 1m'.

=cut

sub get_human_readable {
    my ( $self, $time ) = @_;

    my $seconds = $self->get_seconds( $time );
    my $orig_seconds = $seconds;
    my $abs_seconds  = abs( $seconds );

    return '0s' unless $seconds;

    my $sign = "";
    if ( $seconds < 0 ) {
        $sign = "-";
        $seconds = -1 * $seconds;
    }

    my @string;

  TIME:
    for my $time ( qw( y M w d h m s ) ) {

        if ( $time eq "s" || $time eq "S" ) {
            next TIME if $abs_seconds > $constants->{h};
        }
        elsif ( $time eq "m" ) {
            next TIME if $abs_seconds > $constants->{d};
        }
        elsif ( $time eq "h" || $time eq "H" ) {
            next TIME if $abs_seconds > $constants->{w};
        }
        elsif ( $time eq "d" || $time eq "D" ) {
            next TIME if $abs_seconds > $constants->{M};
        }
        elsif ( $time eq "w" || $time eq "W" ) {
            next TIME if $abs_seconds > $constants->{y};
        }

        my $num_seconds = $constants->{ $time };

        if ( $seconds >= $num_seconds ) {

            my $rounded = int( $seconds / $num_seconds );

            push @string, "$rounded$time";

            $seconds -= int( $num_seconds * $rounded );
        }

        last TIME unless $seconds;
    }

    my $join = "";
    if ( $self->space ) {
        $join = " ";
    }

    return $sign . join( $join, @string );
}

=item $obj->get_hours( $seconds )

Given a number of seconds, return the number of hours rounded to a
single digit.

=cut

sub get_hours {
    my ( $self, $seconds ) = @_;

    my $num_seconds = $constants->{h};

    return int( $seconds / $num_seconds * 10 ) / 10;

}

__PACKAGE__->meta->make_immutable;

1;

__END__

=back

=head1 SEE ALSO

L<Convert::Age>
