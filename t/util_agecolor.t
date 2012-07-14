#!/perl
use strict;

use Test::More;
use Test::Routine;
use Test::Routine::Util;

use YAML::XS;

use App::Wubot::Logger;
use App::Wubot::Util::AgeColor;

has agecolor => (
    is   => 'ro',
    lazy => 1,
    clearer => 'reset_agecolor',
    default => sub {
        return App::Wubot::Util::AgeColor->new();
    }
);

test "testing agecolor object construction" => sub {
    my ($self) = @_;

    $self->reset_agecolor;

    ok( $self->agecolor,
        "Checking that object was created successfully"
    );
};

test "_get_range_limits given age in seconds" => sub {
    my ($self) = @_;

    $self->reset_agecolor;

    ok( $self->agecolor->colormap( { 0 => '000000', 10 => '111111', 20 => '222222' } ),
        "Setting a custom colormap"
    );

    is_deeply( [ $self->agecolor->_get_range_limits( 0 ) ],
               [ '0', '10' ],
               "Checking _get_range_limits() with 0"
           );

    is_deeply( [ $self->agecolor->_get_range_limits( 1 ) ],
               [ '0', '10' ],
               "Checking _get_range_limits() with 1"
           );

    is_deeply( [ $self->agecolor->_get_range_limits( 5 ) ],
               [ '0', '10' ],
               "Checking _get_range_limits() with range in first bucket"
           );

    is_deeply( [ $self->agecolor->_get_range_limits( 10 ) ],
               [ '10', '20' ],
               "Checking _get_range_limits() with range at lower limit of middle bucket"
           );

    is_deeply( [ $self->agecolor->_get_range_limits( 15 ) ],
               [ '10', '20' ],
               "Checking _get_range_limits() with range at lower limit of middle bucket"
           );

    is_deeply( [ $self->agecolor->_get_range_limits( 20 ) ],
               [ '10', '20' ],
               "Checking _get_range_limits() with range at upper limit of last bucket"
           );
};

test "testing _get_rgb_colors method" => sub {
    my ($self) = @_;

    $self->reset_agecolor;

    is_deeply( [ $self->agecolor->_get_rgb_colors( '000000' ) ],
               [ 0, 0, 0 ],
               "Checking get_rgb_colors for 000000"
           );

    is_deeply( [ $self->agecolor->_get_rgb_colors( 'FFFFFF' ) ],
               [ 255, 255, 255 ],
               "Checking get_rgb_colors for FFFFFF"
           );
};

test "get_age_color" => sub {
    my ($self) = @_;

    $self->reset_agecolor;

    ok( $self->agecolor->colormap( { 0  => '000000',
                                     10 => '101010',
                                     20 => '202020',
                                     30 => '303030',
                                 } ),
        "Setting a custom colormap"
    );

    is_deeply( $self->agecolor->get_age_color( 0 ),
               '#000000',
               "Checking get_age_color() with age 0"
           );

    is_deeply( $self->agecolor->get_age_color( 5 ),
               '#080808',
               "Checking get_age_color() with age 5"
           );

    is_deeply( $self->agecolor->get_age_color( 7.5 ),
               '#0c0c0c',
               "Checking get_age_color() with age 7.5"
           );

    is_deeply( $self->agecolor->get_age_color( 10 ),
               '#101010',
               "Checking get_age_color() with age 10"
           );

    is_deeply( $self->agecolor->get_age_color( 15 ),
               '#181818',
               "Checking get_age_color() with age 15"
           );

    is_deeply( $self->agecolor->get_age_color( 20 ),
               '#202020',
               "Checking get_age_color() with age 20"
           );

    is_deeply( $self->agecolor->get_age_color( 25 ),
               '#282828',
               "Checking get_age_color() with age 25"
           );

    is_deeply( $self->agecolor->get_age_color( 30 ),
               '#303030',
               "Checking get_age_color() with age 30"
           );

    is_deeply( $self->agecolor->get_age_color( -5 ),
               '#000000',
               "Checking get_age_color() with age -5, below minimum of 0"
           );

    is_deeply( $self->agecolor->get_age_color( 35 ),
               '#303030',
               "Checking get_age_color() with age 35, above max of 30"
           );

};


test "get_age_color with scaling" => sub {
    my ($self) = @_;

    $self->reset_agecolor;

    ok( $self->agecolor->colormap( { 0  => '000000',
                                     10 => '101010',
                                     20 => '202020',
                                     30 => '303030',
                                 } ),
        "Setting a custom colormap"
    );

    is_deeply( $self->agecolor->get_age_color( 0 ),
               '#000000',
               "Checking get_age_color() with age 0"
           );

    is_deeply( $self->agecolor->get_age_color( 0, .5 ),
               '#000000',
               "Checking get_age_color() with age 0, scale .5"
           );

    is_deeply( $self->agecolor->get_age_color( 5, .5 ),
               '#040404',
               "Checking get_age_color() with age 5, scale .5"
           );

    is_deeply( $self->agecolor->get_age_color( 10, .5 ),
               '#080808',
               "Checking get_age_color() with age 10, scale .5"
           );

    is_deeply( $self->agecolor->get_age_color( 5, 3 ),
               '#181818',
               "Checking get_age_color() with age 5, scale 3"
           );

    is_deeply( $self->agecolor->get_age_color( 10, 2 ),
               '#202020',
               "Checking get_age_color() with age 10, scale 2"
           );

    is_deeply( $self->agecolor->get_age_color( 15, 2 ),
               '#303030',
               "Checking get_age_color() with age 15, scale 2"
           );

    is_deeply( $self->agecolor->get_age_color( -5, 4 ),
               '#000000',
               "Checking get_age_color() with age -5 scale 4, below minimum of 0"
           );

    is_deeply( $self->agecolor->get_age_color( -5, .5 ),
               '#000000',
               "Checking get_age_color() with age -5 scale .5, below minimum of 0"
           );

};

run_me;
done_testing;
