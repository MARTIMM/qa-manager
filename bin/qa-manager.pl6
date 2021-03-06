#!/usr/bin/env raku
use v6.d;
#use lib '../gnome-gobject/lib';
#use lib '../gnome-native/lib';
use lib '../gnome-gtk3/lib';

use QAManager::App::Application;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Str $*data-file-type = 'json';
my Any $*callback-object;

my QAManager::App::Application $app;

#-------------------------------------------------------------------------------
sub MAIN ( Str :$dft? where * ~~ any( Any, 'json', 'toml', 'ini') ) {

  $*data-file-type = $dft // 'json';

  $app .= new(
    :app-id('io.github.martimm.qa'),
  #  :flags(G_APPLICATION_HANDLES_OPEN), # +| G_APPLICATION_NON_UNIQUE),
  #  :!initialize
  );
}
