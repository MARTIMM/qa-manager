use v6.d;

use Gnome::N::X;
#Gnome::N::debug(:on);

use Gnome::Gio::Enums;
use Gnome::Gio::Resource;

use Gnome::Gtk3::Grid;
#use Gnome::Gtk3::Button;
use Gnome::Gtk3::MenuBar;
use Gnome::Gtk3::MenuItem;
use Gnome::Gtk3::Application;
use Gnome::Gtk3::ApplicationWindow;
use Gnome::Gtk3::Builder;

use QAManager::Gui::MenuCategory;
use QAManager::Gui::MenuSet;
use QAManager::Gui::MenuHelp;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::Application:auth<github:MARTIMM>;
also is Gnome::Gtk3::Application;

has Gnome::Gtk3::Grid $!grid;
has Gnome::Gtk3::ApplicationWindow $!app-window;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  # let the Gnome::Gtk3::Application class process the options
  self.bless( :GtkApplication, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD ( *%options ) {

note 'R: ', %options.perl;

  my Gnome::Gio::Resource $r .= new(
    :load(%?RESOURCES<g-resources/QAManager.gresource>.Str)
  );
  $r.register;

  # startup signal fired after registration
  self.register-signal( self, 'app-startup', 'startup');

  # fired after g_application_quit
  self.register-signal( self, 'app-shutdown', 'shutdown');

  # fired after g_application_run
  self.register-signal( self, 'app-activate', 'activate');

  # now we can register the application.
  my Gnome::Glib::Error $e = self.register;
  die $e.message if $e.is-valid;
}

#-------------------------------------------------------------------------------
method app-startup ( Gnome::Gtk3::Application :widget($app) ) {
  self.run;
}

#-------------------------------------------------------------------------------
method app-shutdown ( Gnome::Gtk3::Application :widget($app) ) {

}

#-------------------------------------------------------------------------------
method app-activate ( Gnome::Gtk3::Application :widget($app) ) {

  my Gnome::Gtk3::Builder $builder .= new;
  my Gnome::Glib::Error $e = $builder.add-from-resource(
    self.get-resource-base-path ~ '/resources/g-resources/QAManager-menu.xml'
  );
  die $e.message if $e.is-valid;

  $!app-window .= new(:application(self));
  $!app-window.set-title('Application Window Test');
#  $!app-window.set-border-width(20);
  $!app-window.register-signal( self, 'exit-program', 'destroy');

  # prepare widgets which are directly below window
  $!grid .= new;
  $!app-window.container-add($!grid);
  self.setup-menu;

  $!app-window.show-all;
}

#-------------------------------------------------------------------------------
method setup-menu ( ) {
#Gnome::N::debug(:on);

  my Gnome::Gtk3::MenuBar $mb .= new(:build-id<menubar>);
  $!grid.grid-attach( $mb, 0, 0, 1, 1);

  my Gnome::Gtk3::MenuItem $mi;
  my QAManager::Gui::MenuCategory $mc .= new(:app(self));
  $mi .= new(:build-id<category-new>);
  $mi.register-signal( $mc, 'category-new', 'activate');

  $mi .= new(:build-id<category-quit>);
  $mi.register-signal( $mc, 'category-quit', 'activate');

  my QAManager::Gui::MenuSet $ms .= new(:app(self));
  $mi .= new(:build-id<set-new>);
  $mi.register-signal( $ms, 'set-new', 'activate');

  my QAManager::Gui::MenuHelp $mh .= new(:app(self));
  $mi .= new(:build-id<help-about>);
  $mi.register-signal( $mh, 'help-about', 'activate');
}

#-------------------------------------------------------------------------------
method exit-program ( --> Int ) {
  self.quit;

  1
}
