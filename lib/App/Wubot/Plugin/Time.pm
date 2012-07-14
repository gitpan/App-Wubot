package App::Wubot::Plugin::Time;
use Moose;

our $VERSION = '0.5.0'; # VERSION

use POSIX qw(strftime);
use Net::Time qw(inet_time);

use App::Wubot::Logger;

with 'App::Wubot::Plugin::Roles::Cache';
with 'App::Wubot::Plugin::Roles::Plugin';

sub check {
    my ( $self, $inputs ) = @_;

    my $inet_time = inet_time( $inputs->{config}->{server} );
    $self->logger->debug( "Internet time: ", scalar localtime $inet_time );

    unless ( $inet_time ) {
        $self->logger->logdie( "ERROR: unable to retrieve time from $inputs->{config}->{server}" );
    }

    my $time = time;
    $self->logger->debug( "Current system time: ", scalar localtime $time );

    my $diff = $time - $inet_time;
    $self->logger->debug( "Time difference: $diff" );

    my $message;

    my $subject = "system time is off by around $diff seconds";

    if ( abs( $diff ) > $inputs->{config}->{critical} ) {
        $self->logger->error( "critical: $subject" );
        $message = { subject => $subject,
                     status  => 'CRITICAL',
                     diff    => $diff,
                 };
    }
    elsif ( abs( $diff ) > $inputs->{config}->{warning} ) {
        $self->logger->warn( "warning: $subject" );
        $message = { subject => $subject,
                     status  => 'WARNING',
                     diff    => $diff,
                 };
    }
    else {
        $self->logger->debug( "ok: $subject" );
        $message = { status  => 'OK',
                     diff    => $diff,
                 };
    }

    return { react => $message, cache => $inputs->{cache} };
}

__PACKAGE__->meta->make_immutable;

1;

__END__


=head1 NAME

App::Wubot::Plugin::Time - check that system time is accurate


=head1 VERSION

version 0.5.0

=head1 SYNOPSIS


=head1 DESCRIPTION

See:

  http://tf.nist.gov/tf-cgi/servers.cgi

=head1 SUBROUTINES/METHODS

=over 8

=item check( $inputs )

The standard monitor check() method.

=back
