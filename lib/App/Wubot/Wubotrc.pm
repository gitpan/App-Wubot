package App::Wubot::Wubotrc;
use Moose;

our $VERSION = '0.5.0'; # VERSION

use File::Path;
use Sys::Hostname qw();
use YAML::XS;

has 'hostname' => ( is => 'ro',
                    isa => 'Str',
                    lazy => 1,
                    default => sub {
                        my $hostname = Sys::Hostname::hostname();
                        $hostname =~ s|\..*$||;
                        return $hostname;
                    },
                );

has 'path' => ( is => 'ro',
                        isa => 'Str',
                        lazy => 1,
                        default => sub {
                            return join( "/", $ENV{HOME}, ".wubotrc" );
                        },
                    );

has 'config' => ( is => 'rw',
                   isa => 'HashRef',
                   lazy => 1,
                   default => sub {
                       my $self = shift;
                       return $self->_get_wubotrc();
                   },
               );

has 'defaults' => ( is => 'ro',
                    isa => 'HashRef',
                    lazy => 1,
                    default => sub {
                        my $self = shift;
                        my $defaults;
                        for my $param ( $self->_get_defaults() ) {
                            $defaults->{ $param->{key} } = $param->{value};
                        }
                        return $defaults;
                    },
                );

sub _get_defaults {
    my ( $self ) = @_;

    my $home = $ENV{HOME};
    my $hostname = $self->hostname;

    my @defaults = (
        { key   => 'wubot_project',
          value => "$home/projects/wubot",
          desc  => 'location where wubot github project is checked out',
      },
        { key   => 'wubot_home',
          value => "$home/wubot",
          desc  => 'default wubot root path',
      },
        { key   => 'wubotx_home',
          value => "$home/wubot/WubotX",
          desc  => 'location where WubotX github project is checked out'
      },
        { key   => 'log_home',
          value => "$home/wubot/log",
          desc  => 'location of the log files',
      },
        { key   => 'cache_home',
          value => "$home/wubot/cache",
          desc  => 'location of cache files, one per plugin instance',
      },
        { key   => 'config_home',
          value => "$home/wubot/config",
          desc  => 'location of the wubot config files',
      },
        { key   => 'reactor_queue',
          value => "$home/wubot/reactor",
          desc  => 'where monitor queues messages and reactor picks them up',
      },
        { key   => 'reactor_config',
          value => "$home/wubot/config/reactor.yaml.$hostname",
          desc  => 'location of the wubot-reactor config file',
      },
        { key   => 'custom_colors',
          value => "$home/wubot/config/colors.yaml",
          desc  => 'custom colors for the web ui',
      },
        { key   => 'web_config',
          value => "$home/wubot/config/webui.yaml",
          desc  => 'main configuration file for the web interface',
      },
    );

    return @defaults;
}

sub _get_wubotrc {
    my ( $self ) = @_;

    my $path = $self->path;

    unless ( -r $path ) {
        warn( "creating $path with default values\n" );
        $self->_create_wubotrc();
    }

    return YAML::XS::LoadFile( $path );
}

sub _create_wubotrc {
    my ( $self ) = @_;

    my $path = $self->path;

    open(my $fh, ">", $path)
        or die "Couldn't open $path for writing: $!\n";

    for my $param ( $self->_get_defaults() ) {
        print $fh
            "#\n",
            "# $param->{desc}\n",
            "#\n",
            "$param->{key}: $param->{value}\n\n";
    }


    close $fh or die "Error closing file: $!\n";

    return 1;
}

sub get_config {
    my ( $self, $param ) = @_;

    my $value;

    if ( $self->config->{ $param } ) {
        $value = $self->config->{ $param };
    }
    elsif ( $self->defaults->{ $param } ) {
        $value = $self->defaults->{ $param };
    }
    else {
        die( "ERROR: get_config called for '$param': not defined in .wubotrc and no default value available" );
    }

    if ( $param =~ m|_home| ) {
        unless ( -d $value ) {
            warn( "Creating directory: $value\n" );
            mkpath( $value );
        }
    }

    return $value;
}


1;

__END__


=head1 NAME

App::Wubot::Wubotrc - read ~/.wubotrc


=head1 VERSION

version 0.5.0

=head1 SYNOPSIS

    use App::Wubot::Wubotrc;

    my $wubotrc = App::Wubot::Wubotrc->new();

    my $wubot_home = $wubotrc->get_config( 'wubot_home' );

=head1 DESCRIPTION

Read your ~/.wubotrc and determine paths for wubot resources.

If you have no ~/.wubotrc, then a default one will automatically be
created for you.

=head1 SUBROUTINES/METHODS

=over 8

=item get_config( $param )

Read the specified config setting from ~/.wubotrc.

=back
