package App::Wubot::Reactor::WebFetch;
use Moose;

our $VERSION = '0.5.0'; # VERSION

use App::Wubot::Logger;
use App::Wubot::Util::WebFetcher;

has 'fetcher' => ( is  => 'ro',
                   isa => 'App::Wubot::Util::WebFetcher',
                   lazy => 1,
                   default => sub {
                       return App::Wubot::Util::WebFetcher->new();
                   },
               );

has 'logger'  => ( is => 'ro',
                   isa => 'Log::Log4perl::Logger',
                   lazy => 1,
                   default => sub {
                       return Log::Log4perl::get_logger( __PACKAGE__ );
                   },
               );


sub react {
    my ( $self, $message, $config ) = @_;

    my $url;
    if ( $config->{url} ) {
        $url = $config->{url};
    }
    elsif ( $config->{url_field} ) {
        if ( $message->{ $config->{url_field} } ) {
            $url = $message->{ $config->{url_field} };
        }
        else {
            $self->logger->error( "Waring: url field not found on message: $config->{url_field}" );
            return $message;
        }
    }
    else {
        $self->logger->error( "WebFetch Reactor ERROR:: neither url nor url_field defined in config" );
        return $message;
    }

    $self->logger->debug( "Fetching content from $url" );

    my $content;
    eval {                          # try
        $content = $self->fetcher->fetch( $url, $config );
        1;
    } or do {                       # catch
        my $error = $@;
        $self->logger->error( "WebFetch reactor: Request failure: $url: $error" );
        return $message;
    };

    if ( $config->{field} ) {
        $message->{ $config->{field} } = $content;
        utf8::decode( $message->{ $config->{field} } );
    }
    else {
        $self->logger->error( "WebFetch Reactor ERROR: 'field' not defined in config!" );
        return $message;
    }

    return $message;

}

__PACKAGE__->meta->make_immutable;

1;

__END__


=head1 NAME

App::Wubot::Reactor::WebFetch - fetch data from a URL


=head1 VERSION

version 0.5.0

=head1 SYNOPSIS

    - name: fetch 'body' field from the 'link' field
      plugin: WebFetch
      config:
        field: body
        url_field: link

=head1 DESCRIPTION

A reactor plugin that can fetch data from a URL and store the
retrieved content on a field on the message.

This plugin is great for fetching the complete article for the body of
an RSS feed when the feed only provides a summary of the article.

The 'url' may be defined in the config, or else a 'url_field' may be
configured so that the link can be pulled from the message.  The
retrieved content is stored on the message in the configured 'field'.

If an error occurs, the error will be logged at 'error' level.

The retrieved content will be utf8 decoded.

=head1 SUBROUTINES/METHODS

=over 8

=item react( $message, $config )

The standard reactor plugin react() method.

=back
