use v6.d;

use Gnome::N::X;
use Gnome::N::N-GObject;

use Gnome::Glib::Error;

use Gnome::Gio::Enums;
use Gnome::Gio::Resource;

use Gnome::Gdk3::Screen;

use Gnome::Gtk3::Grid;
use Gnome::Gtk3::Notebook;
use Gnome::Gtk3::Frame;
use Gnome::Gtk3::Label;
use Gnome::Gtk3::MenuBar;
use Gnome::Gtk3::MenuItem;
use Gnome::Gtk3::Application;
use Gnome::Gtk3::ApplicationWindow;
use Gnome::Gtk3::Builder;
use Gnome::Gtk3::CssProvider;
use Gnome::Gtk3::StyleContext;
use Gnome::Gtk3::StyleProvider;

use QAManager::Gui::Menu::Sheet;
use QAManager::Gui::Menu::Category;
use QAManager::Gui::Menu::Set;
use QAManager::Gui::Menu::Help;

use QAManager::Gui::Page::Sheet;

use QAManager::Sheet;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
unit class QAManager::Gui::Application:auth<github:MARTIMM>;
also is Gnome::Gtk3::Application;

has Gnome::Gtk3::ApplicationWindow $!app-window;
has Gnome::Gtk3::Grid $!grid;
has Gnome::Gtk3::Notebook $!notebook;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  # let the Gnome::Gtk3::Application class process the options
  self.bless( :GtkApplication, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD ( *%options ) {

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

  # read the menu xml into the builder
  my Gnome::Gtk3::Builder $builder .= new;
  my Gnome::Glib::Error $e = $builder.add-from-resource(
    self.get-resource-base-path ~ '/resources/g-resources/QAManager-menu.xml'
  );
  die $e.message if $e.is-valid;

  # read the style definitions into the css provide and style context
  my Gnome::Gtk3::CssProvider $css-provider .= new;
  $css-provider.load-from-resource(
    self.get-resource-base-path ~ '/resources/g-resources/QAManager-style.css'
  );
  my Gnome::Gtk3::StyleContext $style-context .= new;
  $style-context.add_provider_for_screen(
    Gnome::Gdk3::Screen.new, $css-provider, GTK_STYLE_PROVIDER_PRIORITY_USER
  );

  # make the main screen
  $!app-window .= new(:application(self));
  $!app-window.set-title('Question Answer Manager');
#  $!app-window.set-border-width(20);
  $!app-window.register-signal( self, 'exit-program', 'destroy');

  # make main window widgets
  $!grid .= new;
  $!app-window.container-add($!grid);

  self.setup-menu;
  my Gnome::Gtk3::Grid $fst-page = self.setup-workarea;

  $!app-window.show-all;

  # set the visibility of the menu after all is shown
  self.change-menu( $fst-page.get-native-object, 0);
}

#-------------------------------------------------------------------------------
method setup-menu ( ) {
#Gnome::N::debug(:on);

  my Gnome::Gtk3::MenuBar $mb .= new(:build-id<menubar>);
  $!grid.grid-attach( $mb, 0, 0, 1, 1);

  my Gnome::Gtk3::MenuItem $mi;

  my QAManager::Gui::Menu::Sheet $msheet .= new(:app(self));
  $mi .= new(:build-id<sheet-new>);
  $mi.register-signal( $msheet, 'sheet-new', 'activate');


  my QAManager::Gui::Menu::Category $mcat .= new(:app(self));
  $mi .= new(:build-id<category-new>);
  $mi.register-signal( $mcat, 'category-new', 'activate');

  $mi .= new(:build-id<category-quit>);
  $mi.register-signal( $mcat, 'category-quit', 'activate');


  my QAManager::Gui::Menu::Set $mset .= new(:app(self));
  $mi .= new(:build-id<set-new>);
  $mi.register-signal( $mset, 'set-new', 'activate');


  my QAManager::Gui::Menu::Help $mhelp .= new(:app(self));
  $mi .= new(:build-id<help-about>);
  $mi.register-signal( $mhelp, 'help-about', 'activate');
}

#-------------------------------------------------------------------------------
method setup-workarea ( --> Gnome::Gtk3::Grid ) {
#Gnome::N::debug(:on);
  $!notebook .= new;
  $!notebook.widget-set-hexpand(True);
  $!notebook.widget-set-vexpand(True);


  $!notebook.append-page(
    my Gnome::Gtk3::Grid $f = QAManager::Gui::Page::Sheet.new,
    Gnome::Gtk3::Label.new(:text<Sheets>)
  );

  $!notebook.append-page(
    self.setup-category-page, Gnome::Gtk3::Label.new(:text<Category>)
  );

  $!notebook.append-page(
    self.setup-set-page, Gnome::Gtk3::Label.new(:text<Sets>)
  );

  $!notebook.register-signal( self, 'change-menu', 'switch-page');

  $!grid.grid-attach( $!notebook, 0, 1, 1, 1);

  # return one of the pages to set the visibility of the menu after all is shown
  $f
}

#-------------------------------------------------------------------------------
method setup-sheet-page ( --> Gnome::Gtk3::Grid ) {

  my Gnome::Gtk3::Grid $page .= new;
  $page.widget-set-hexpand(True);
  $page.set-border-width(5);

  my QAManager::Sheet $s .= new(:sheet<x>);
  note $s.get-sheet-list.perl;

  $page
}

#-------------------------------------------------------------------------------
method setup-category-page ( --> Gnome::Gtk3::Grid ) {

  my Gnome::Gtk3::Grid $page .= new;
  $page.widget-set-hexpand(True);
  $page.set-border-width(5);

  $page
}

#-------------------------------------------------------------------------------
method setup-set-page ( --> Gnome::Gtk3::Grid ) {

  my Gnome::Gtk3::Grid $page .= new;
  $page.widget-set-hexpand(True);
  $page.set-border-width(5);

  $page
}

#--[ signal handlers ]----------------------------------------------------------
# change menu on change of notebook pages
method change-menu ( N-GObject $no, uint32 $page-num --> Int ) {
#Gnome::N::debug(:on);

  my Gnome::Gtk3::Frame $page .= new(:native-object($no));

  my Gnome::Gtk3::MenuItem $mi-sheet .= new(:build-id<sheet>);
  my Gnome::Gtk3::MenuItem $mi-cat .= new(:build-id<category>);
  my Gnome::Gtk3::MenuItem $mi-set .= new(:build-id<set>);

  given $page-num {
    when 0 {
      $mi-sheet.set-visible(True);
      $mi-cat.set-visible(False);
      $mi-set.set-visible(False);
    }

    when 1 {
      $mi-sheet.set-visible(False);
      $mi-cat.set-visible(True);
      $mi-set.set-visible(False);
    }

    when 2 {
      $mi-sheet.set-visible(False);
      $mi-cat.set-visible(False);
      $mi-set.set-visible(True);
    }
  }

  1;
}

#-------------------------------------------------------------------------------
method exit-program ( --> Int ) {
  self.quit;

  1
}
