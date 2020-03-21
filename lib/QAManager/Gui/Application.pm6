use v6.d;

use Gnome::N::X;
use Gnome::N::N-GVariant;
#Gnome::N::debug(:on);

use Gnome::Gio::Enums;
use Gnome::Gio::MenuModel;
use Gnome::Gio::Resource;
use Gnome::Gio::SimpleAction;

use Gnome::Glib::Variant;

#use Gnome::Gtk3::Grid;
#use Gnome::Gtk3::Button;
use Gnome::Gtk3::Application;
use Gnome::Gtk3::ApplicationWindow;
use Gnome::Gtk3::Builder;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::Application;
also is Gnome::Gtk3::Application;

#has Gnome::Gio::MenuModel $!menubar;
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

  #
  #self.register-signal( self, 'app-open', 'open');

  # now we can register the application.
  my Gnome::Glib::Error $e = self.register;
  die $e.message if $e.is-valid;
}

#-------------------------------------------------------------------------------
method app-startup ( Gnome::Gtk3::Application :widget($app) ) {
#note 'app registered';
  self.run;
}

#-------------------------------------------------------------------------------
method app-shutdown ( Gnome::Gtk3::Application :widget($app) ) {
#note 'app shutdown';
}

#-------------------------------------------------------------------------------
method app-activate ( Gnome::Gtk3::Application :widget($app) ) {
#note 'app activated';

#    my $rbpath = self.get-resource-base-path;

  my Gnome::Gtk3::Builder $builder .= new;
  my Gnome::Glib::Error $e = $builder.add-from-resource(
    self.get-resource-base-path ~ '/resources/g-resources/QAManager-menu.ui'
  );
  die $e.message if $e.is-valid;

  self.setup-menu;

  $!app-window .= new(:application(self));
  $!app-window.set-title('Application Window Test');
  $!app-window.set-border-width(20);
  $!app-window.register-signal( self, 'exit-program', 'destroy');

  # prepare widgets which are directly below window
#    $!grid .= new;
#    my Gnome::Gtk3::Button $b1 .= new(:label<Stop>);
#    $!grid.grid-attach( $b1, 0, 0, 1, 1);
#    $b1.register-signal( self, 'exit-program', 'clicked');

#    $!app-window.container-add($!grid);
  $!app-window.show-all;

#    note "\nInfo:\n  Registered: ", self.get-is-registered;
#    note '  resource base path: ', $rbpath;
#    note '  app id: ', self.get-application-id;
}

#-------------------------------------------------------------------------------
method setup-menu ( ) {
  self.set-menubar(Gnome::Gio::MenuModel.new(:build-id<menubar>));

  # in xml: <attribute name='action'>app.category-new</attribute>
  my Gnome::Gio::SimpleAction $menu-entry .= new(:name<category-new>);
  $menu-entry.register-signal( self, 'category-new', 'activate');
  self.add-action($menu-entry);

  # in xml: <attribute name='action'>app.category-quit</attribute>
  $menu-entry .= new(:name<category-quit>);
  $menu-entry.register-signal( self, 'category-quit', 'activate');
  self.add-action($menu-entry);



  # in xml: <attribute name='action'>app.help-about</attribute>
  $menu-entry .= new(:name<help-about>);
  $menu-entry.register-signal( self, 'help-about', 'activate');
  self.add-action($menu-entry);
}

#-------------------------------------------------------------------------------
method app-open (
#    Pointer $f, Int $nf, Str $hint,
  $f, Int $nf, Str $hint,
  Gnome::Gtk3::Application :widget($app)
) {
note 'app open: ', $nf;
}

#-------------------------------------------------------------------------------
method exit-program ( --> Int ) {
  self.quit;

  1
}

#-- [menu] ---------------------------------------------------------------------
# category > New
method category-new (
  N-GVariant $parameter, Gnome::GObject::Object :widget($category-new-action)
) {
  note "Select 'New' from 'Category' menu";
  note "p: ", $parameter.perl;
  my Gnome::Glib::Variant $v .= new(:native-object($parameter));
  note "tsv: ", $v.is-valid;
  note "ts: ", $v.get-type-string if $v.is-valid;
}

# category > Quit
method category-quit (
  N-GVariant $parameter, Gnome::GObject::Object :widget($category-quit-action)
  --> Int
) {
  note "Select 'Quit' from 'Category' menu";

  self.quit;

  1
}

# Help > About
method help-about (
  N-GVariant $parameter, Gnome::GObject::Object :widget($help-about-action)
) {
  note "Select 'About' from 'Help' menu";
  note "p: ", $parameter.perl;
  my Gnome::Glib::Variant $v .= new(:native-object($parameter));
  note "tsv: ", $v.is-valid;
  note "ts: ", $v.get-type-string if $v.is-valid;
}
