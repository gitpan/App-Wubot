package App::Wubot::Plugin::Stdin;
use Moose;

our $VERSION = '0.5.0'; # VERSION

use App::Wubot::Logger;

with 'App::Wubot::Plugin::Roles::Cache';
with 'App::Wubot::Plugin::Roles::Plugin';

sub check {
    my ( $self, $inputs ) = @_;

    my @lines;

    while ( my $line = <STDIN> ) {
        chomp $line;
        push @lines, { line => $line };
    }

    return { react => \@lines };
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

App::Wubot::Plugin::Stdin - a plugin for reading from stdin

=head1 VERSION

version 0.5.0

=head1 DESCRIPTION

This plugin is designed for using wubot as a command-line utility.
More information coming soon.


=head1 SUBROUTINES/METHODS

=over 8

=item check( $inputs )

Read everything available from STDIN into memory, and send a message
for each line.


=back
