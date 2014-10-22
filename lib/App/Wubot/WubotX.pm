package App::Wubot::WubotX;
use Moose;

our $VERSION = '0.4.0'; # VERSION

use YAML::XS;

use App::Wubot::Logger;

has 'root' => ( is => 'ro',
                isa => 'Str',
                lazy => 1,
                default => sub {
                    return join( "/", $ENV{HOME}, "wubot", "WubotX" );
                },
            );

has 'plugins' => ( is => 'ro',
                   isa => 'ArrayRef[Str]',
                   lazy => 1,
                   default => sub {
                       return $_[0]->get_plugins();
                   },
               );

has 'logger'  => ( is => 'ro',
                   isa => 'Log::Log4perl::Logger',
                   lazy => 1,
                   default => sub {
                       return Log::Log4perl::get_logger( __PACKAGE__ );
                   },
               );

=head1 NAME

App::Wubot::WubotX - WubotX extensions manager


=head1 VERSION

version 0.4.0

=head1 SYNOPSIS

    use App::Wubot::WubotX;
    my $wubotx = App::Wubot::WubotX->new();
    $wubotx->get_plugins();

=head1 DESCRIPTION

This library should be used by any tools that use one or more WubotX
extensions.  This is still in an early phase of development.

=head1 SUBROUTINES/METHODS

=over 8

=item $obj->get_plugins()

Search for all plugin directories in ~/wubot/WubotX.  All directories
that are found are added to @INC.

=cut


sub get_plugins {
    my ( $self ) = @_;

    my @plugins;

    my $directory = $self->root;

    my $dir_h;
    opendir( $dir_h, $directory ) or die "Can't opendir $directory: $!";
    while ( defined( my $entry = readdir( $dir_h ) ) ) {
        next unless $entry;
        next if $entry =~ m|^\.|;

        my $plugin_path = join( "/", $directory, $entry );
        if ( -d $plugin_path ) {
            $self->logger->warn( "WubotX: loading: $entry" );
            push @plugins, $entry;
        }

        my $lib_path = join( "/", $plugin_path, "lib" );
        if ( -d $lib_path ) {
            $self->logger->debug( "WubotX: adding lib path: $lib_path" );
            push @INC, $lib_path;
        }
    }

    closedir( $dir_h );

    return \@plugins;
}


=item $obj->get_webui()

Loads the webui.yaml files from the various plugin directories.

=cut

sub get_webui {
    my ( $self ) = @_;

    my $webui_config;

    for my $plugin ( @{ $self->plugins } ) {

        my $path = join( "/", $self->root, $plugin, "webui.yaml" );

        next unless -r $path;

        my $config = YAML::XS::LoadFile( $path );

        for my $key ( keys %{ $config } ) {
            $webui_config->{ $plugin }->{ $key } = $config->{ $key };
        }
    }

    $self->logger->debug( YAML::XS::Dump $webui_config );

    return $webui_config;
}

=item $obj->link_templates()

Find templates in the plugin directory, and symlink them into the
Mojolicious 'templates' directory.

=cut

sub link_templates {
    my ( $self ) = @_;

  PLUGIN:
    for my $plugin ( @{ $self->plugins } ) {

        my @templates;

        my $directory = join( "/", $self->root, $plugin, "templates" );
        next PLUGIN unless -d $directory;

        my $dir_h;
        opendir( $dir_h, $directory ) or die "Can't opendir $directory: $!";
        while ( defined( my $entry = readdir( $dir_h ) ) ) {
            next unless $entry;
            next if $entry =~ m|^\.|;

            push @templates, $entry;
        }
        closedir( $dir_h );

        for my $template ( @templates ) {

            # skip template if it already exists in the global templates directory
            next if -r "templates/$template";

            # hard-link the template
            $self->logger->error( "Linking template from plugin $plugin: $template" );
            system( "ln", "$directory/$template", "templates/" );
        }

    }
}

1;

__END__

=back
