
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "personal distributed reactive automation",
  "AUTHOR" => "Alex White <VVu\@geekfarm.org>",
  "BUILD_REQUIRES" => {
    "English" => 0,
    "File::Temp" => 0,
    "Test::Differences" => 0,
    "Test::Exception" => 0,
    "Test::MockObject" => 0,
    "Test::Mojo" => 0,
    "Test::More" => "0.88",
    "Test::Requires" => 0,
    "Test::Routine" => 0,
    "Test::Routine::Util" => 0,
    "utf8" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "App-Wubot",
  "EXE_FILES" => [
    "bin/wubot-check",
    "bin/wubot-check2",
    "bin/wubot-monitor",
    "bin/wubot-reactor",
    "bin/wubot-webui"
  ],
  "LICENSE" => "bsd",
  "NAME" => "App::Wubot",
  "PREREQ_PM" => {
    "AnyEvent" => 0,
    "AnyEvent::Watchdog" => 0,
    "AnyEvent::Watchdog::Util" => 0,
    "Benchmark" => 0,
    "Capture::Tiny" => 0,
    "Carp" => 0,
    "Class::Load" => 0,
    "DBD::SQLite" => 0,
    "DBI" => 0,
    "Date::Manip" => 0,
    "Devel::StackTrace" => 0,
    "Digest::MD5" => 0,
    "Encode" => 0,
    "Fcntl" => 0,
    "File::Basename" => 0,
    "File::Path" => 0,
    "File::Spec" => 0,
    "FindBin" => 0,
    "Getopt::Long" => 0,
    "HTML::Strip" => 0,
    "HTML::TableExtract" => 0,
    "HTTP::Cookies" => 0,
    "HTTP::Message" => 0,
    "LWP::Simple" => 0,
    "LWP::UserAgent" => 0,
    "Log::Log4perl" => 0,
    "Mojo::Base" => 0,
    "Moose" => 0,
    "Moose::Role" => 0,
    "POSIX" => 0,
    "SQL::Abstract" => 0,
    "Scalar::Util" => 0,
    "Sys::Hostname" => 0,
    "Term::ANSIColor" => 0,
    "Text::Template" => 0,
    "Text::Wrap" => 0,
    "URI::Find" => 0,
    "XML::Simple" => 0,
    "YAML::XS" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.4.1",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



