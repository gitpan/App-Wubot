#!/perl
use strict;

use File::Temp qw/ tempdir /;
use Test::More;
use YAML::XS;

use App::Wubot::Wubotrc;

my $tempdir = tempdir( "/tmp/tmpdir-XXXXXXXXXX", CLEANUP => 1 );

my $path = "$tempdir/.wubotrc";

ok( my $wubotrc = App::Wubot::Wubotrc->new( { path => $path } ),
    "Creating a new .wubotrc object"
);

ok( ! -r $path,
    "Checking that .wubotrc does not exist yet"
);

ok( $wubotrc->config,
    "lazy loading wubot config object"
);

ok( -r $path,
    "Checking that .wubotrc was created"
);

system( "cat $path" );

is( $wubotrc->get_config( 'wubot_home' ),
    "$ENV{HOME}/wubot",
    "Checking default wubot_home path"
);

ok( my $config = YAML::XS::LoadFile( $path ),
    "Reading default .wubotrc"
);

is( $config->{wubot_home},
    "$ENV{HOME}/wubot",
    "Checking default wubot_home path"
);

YAML::XS::DumpFile( $path, { %{ $config }, wubot_home => $tempdir } );

ok( my $new_config = App::Wubot::Wubotrc->new( { path => $path } ),
    "Creating new config object after updating .wubotrc"
);

is( $new_config->config->{wubot_home},
    $tempdir,
    "Checking that updated wubot_home path was read from .wubotrc"
);

is( $new_config->get_config( 'wubot_home' ),
    $tempdir,
    "Checking default wubot_home path using get_config()"
);

done_testing;
