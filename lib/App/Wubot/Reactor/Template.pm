package App::Wubot::Reactor::Template;
use Moose;

our $VERSION = '0.5.0'; # VERSION

use Text::Template;

use App::Wubot::Logger;

has 'logger'  => ( is => 'ro',
                   isa => 'Log::Log4perl::Logger',
                   lazy => 1,
                   default => sub {
                       return Log::Log4perl::get_logger( __PACKAGE__ );
                   },
               );


sub react {
    my ( $self, $message, $config ) = @_;

    my $template_contents;

    if ( $config->{source_field} ) {
        return $message unless $message->{ $config->{source_field} };
        $template_contents = $message->{ $config->{source_field} };
    }
    elsif ( $config->{template} ) {
        $template_contents = $config->{template};
    }
    elsif ( $config->{template_file} ) {
        return $message unless $config->{template_file};

        open(my $fh, "<", $config->{template_file})
            or die "Couldn't open $config->{template_file} for reading: $!\n";
        local undef $/;
        $template_contents = <$fh>;
        close $fh or die "Error closing file: $!\n";

    }
    else {
        $self->logger->error( "ERROR: Template reactor: no template specified" );
        return $message;
    }

    my $template = Text::Template->new(TYPE => 'STRING', SOURCE => $template_contents );

    unless ( $config->{target_field} ) {
        $self->logger->error( "ERROR: template reactor: no target_field specified" );
        return $message;
    }

    $message->{ $config->{target_field} } = $template->fill_in( HASH => $message );

    return $message;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

App::Wubot::Reactor::Template - build a field using existing message fields as a template

=head1 VERSION

version 0.5.0

=head1 SYNOPSIS

  - name: build a subject that references the username field
    plugin: Template
    config:
      template: 'Got username: {$username}'
      target_field: subject


=head1 DESCRIPTION

TODO: More to come...


=head1 SUBROUTINES/METHODS

=over 8

=item react( $message, $config )

The standard reactor plugin react() method.

=back
