package App::Wubot;
use Moose;

our $VERSION = '0.5.0'; # VERSION

#_* Libraries

use Carp;

#_* POD

=head1 NAME

App::Wubot - personal distributed reactive automation


=head1 VERSION

version 0.5.0

=head1 DESCRIPTION

This project is still in the alpha stage of development!  Data
handling is reliable, but the user interface is still rough.

For an overview of wubot, please see L<App::Wubot::Guide::Overview>.

For more information, see the L<App::Wubot::Guide>.

=cut

#_* End

__PACKAGE__->meta->make_immutable;

1;

__END__
