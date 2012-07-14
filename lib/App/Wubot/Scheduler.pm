package App::Wubot::Scheduler;
use Moose;

our $VERSION = '0.5.0'; # VERSION

use Log::Log4perl;

has 'timers' => ( is => 'ro',
                  isa => 'HashRef[Str]',
                  lazy => 1,
                  default => sub {
                      return {};
                  }
              );

has 'callbacks' => ( is => 'ro',
                     isa => 'HashRef[Str]',
                     lazy => 1,
                     default => sub {
                         return {};
                     },
                 );

has 'intervals' => ( is => 'ro',
                     isa => 'HashRef[Str]',
                     lazy => 1,
                     default => sub {
                         return {};
                     },
                 );

has 'logger'  => ( is => 'ro',
                   isa => 'Log::Log4perl::Logger',
                   lazy => 1,
                   default => sub {
                       return Log::Log4perl::get_logger( __PACKAGE__ );
                   },
               );


sub schedule {
    my ( $self, $plugin, $cb, $after, $interval ) = @_;

    unless ( $plugin   ) { $self->logger->logcroak( "missing required param 'plugin'" ) }
    unless ( $cb       ) { $self->logger->logcroak( "missing required param 'cb'" ) }
    unless ( defined $after    ) { $self->logger->logcroak( "missing required param 'after'" ) }

    unless ( $interval ) { $interval = 60 }
    $self->intervals->{ $plugin } = $interval;

    $self->callbacks->{ $plugin }
        = sub { $self->logger->debug( "running scheduled event for $plugin: ",
                                      $self->intervals->{ $plugin }
                                  );
                $cb->( $plugin );
            };


    $self->timers->{ $plugin }
        = AnyEvent->timer( after    => $after,
                           interval => $interval,
                           cb       => $self->callbacks->{ $plugin },
                       );
}

sub reschedule {
    my ( $self, $plugin, $after ) = @_;

    unless ( $plugin   ) { $self->logger->logcroak( "missing required param 'plugin'" ) }
    unless ( defined $after    ) { $self->logger->logcroak( "missing required param 'after'" ) }

    $self->logger->debug( "Rescheduling $plugin in $after seconds" );

    undef $self->timers->{ $plugin };
    delete $self->timers->{ $plugin };

    $self->timers->{ $plugin }
        = AnyEvent->timer( after    => $after,
                           interval => $self->intervals->{ $plugin },
                           cb       => $self->callbacks->{ $plugin },
                       );

}

1;

__END__

=head1 NAME

App::Wubot::Scheduler - schedule events using AnyEvent timers


=head1 VERSION

version 0.5.0

=head1 SYNOPSIS

    use App::Wubot::Scheduler;

    my $scheduler = App::Wubot::Scheduler->new();

    my $id = 'foo';

    # scheduled 'foo' task, runs the method every 5 seconds
    $scheduler->schedule( $id,
                          sub { print "RUNNING $id!\n" },
                          5
                        );

    # reschedule 'foo' to run every 10 seconds.  cancels the previous
    # 5 second timer.
    $scheduler->reschedule( $id,
                            10
                          );


=head1 DESCRIPTION

Schedule recurring timers.

=head1 SUBROUTINES/METHODS

=over 8

=item $obj->schedule( $id, $callback, $after, $interval )

Schedule the callback to run after $after seconds, and then run every
$interval seconds.

If $interval is not specified, it will default to $after.

The $id is required.  The purpose of $id is to give a name to your
timer, so that later you can change the schedule using the $id.

=item $obj->reschedule( $id, $after )

Given the $id of a previously scheduled timer, cancel the existing
schedule, and schedule the callback to get called next in $after
seconds.

Note that the 'interval' will remain unchanged--this will only change
the next time the callback gets run.

=back
