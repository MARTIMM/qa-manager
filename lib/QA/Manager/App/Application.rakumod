use v6.d;

use Gnome::N::X;
use Gnome::N::N-GObject;

use Gnome::Glib::Error;

use Gnome::Gio::Enums;
use Gnome::Gio::Resource;

use Gnome::Gdk3::Screen;

use Gnome::Gtk3::Builder;
use Gnome::Gtk3::CssProvider;
use Gnome::Gtk3::StyleContext;
use Gnome::Gtk3::StyleProvider;
use Gnome::Gtk3::Grid;
use Gnome::Gtk3::Notebook;
use Gnome::Gtk3::Frame;
use Gnome::Gtk3::Label;
use Gnome::Gtk3::MenuBar;
use Gnome::Gtk3::Application;

use QA::Manager::App::ApplicationWindow;
use QA::Manager::App::Menu::File;
use QA::Manager::App::Menu::Help;
#use QA::Manager::App::Page::Category;
#use QA::Manager::App::Page::Sheet;
#use QA::Manager::App::Page::Set;

#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
unit class QA::Manager::App::Application:auth<github:MARTIMM>;
also is Gnome::Gtk3::Application;

#enum NotebookPages <SHEETPAGE CATPAGE SETPAGE>;
constant APP-ID = 'io.github.martimm.qa-manager';

has QA::Manager::App::ApplicationWindow $!app-window;
has Gnome::Gtk3::Grid $!grid;
has Gnome::Gtk3::Notebook $!notebook;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  # let the Gnome::Gtk3::Application class process the options
  self.bless( :GtkApplication, :app-id(APP-ID), |c);
}

#-------------------------------------------------------------------------------
submethod BUILD ( *%options ) {

  # load the gtk resource file and register resource to make data global to app
  my Gnome::Gio::Resource $r .= new(
    :load(%?RESOURCES<g-resources/QAManager.gresource>.Str)
  );
  $r.register;

  # startup signal fired after registration of app
  self.register-signal( self, 'app-startup', 'startup');

  # fired after g_application_run
  self.register-signal( self, 'app-activate', 'activate');

  # fired after g_application_quit
  self.register-signal( self, 'app-shutdown', 'shutdown');

  # now we can register the application.
  my Gnome::Glib::Error $e = self.register;
  die $e.message if $e.is-valid;
}

#-------------------------------------------------------------------------------
method app-startup ( Gnome::Gtk3::Application :_widget($app) ) {
  #TODO check for tasks which do not need a gui, if so, don't self.run
note 'run';
  self.run;
}

#-------------------------------------------------------------------------------
method app-shutdown ( Gnome::Gtk3::Application :_widget($app) ) {
  #TODO save and cleanup tasks
note 'shutdown';
}

#-------------------------------------------------------------------------------
# need gui then, build base
method app-activate ( Gnome::Gtk3::Application :_widget($app) ) {
note 'activate';

  # read the menu xml into the builder
  my Gnome::Gtk3::Builder $builder .= new(:resource(
      self.get-resource-base-path ~ '/resources/g-resources/QAManager-menu.xml'
    )
  );

  # read the style definitions into the css provider and style context
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


  # make main window widgets
  $!grid .= new;
  $!app-window.add($!grid);

  self.setup-menu($builder);
  #my Gnome::Gtk3::Grid $fst-page = self.setup-workarea;
  self.setup-workarea;

#Gnome::N::debug(:on);
  $!app-window.show-all;

  # set the visibility of the menu after all is shown
#  self.set-menu-visibility( 'sheet', :visible);
#  self.set-menu-visibility( 'category', :!visible);
#  self.set-menu-visibility( 'set', :!visible);
}

#-------------------------------------------------------------------------------
method setup-menu ( Gnome::Gtk3::Builder $builder ) {
note 'setup menu';
  my Gnome::Gtk3::MenuBar $mb .= new(:build-id<menubar>);
  $!grid.grid-attach( $mb, 0, 0, 1, 1);

  my $app := self;
  my QA::Manager::App::Menu::File $file .= new(:$app);
  my QA::Manager::App::Menu::Help $help .= new(:$app);

  my Hash $handlers = %(
    :file-quit($file),
    :help-about($help),
  );

  $builder.connect-signals-full($handlers);
}

#`{{
#-------------------------------------------------------------------------------
# register a handler for a menu item. The $build-id is also the name
# of the handler method in the $menu object.
method menu-handler ( $menu, $build-id ) {

  my Gnome::Gtk3::MenuItem $mi .= new(:$build-id);
  $mi.register-signal( $menu, $build-id, 'activate');
}
}}

#-------------------------------------------------------------------------------
method setup-workarea ( --> Gnome::Gtk3::Grid ) {
#`{{
  $!notebook .= new;
  $!notebook.widget-set-hexpand(True);
  $!notebook.widget-set-vexpand(True);

  my $app := self;
  my QA::Manager::App::Page::Sheet $sheet .= new;
  $!notebook.append-page( $sheet, Gnome::Gtk3::Label.new(:text<Sheets>));

  $!notebook.append-page(
    QA::Manager::App::Page::Category.new,
    Gnome::Gtk3::Label.new(:text<Categories>)
  );

  $!notebook.append-page(
    QA::Manager::App::Page::Set.new(
      :$app, :$!app-window, :rbase-path(self.get-resource-base-path)
    ),
    Gnome::Gtk3::Label.new(:text<Sets>)
  );

#  $!notebook.register-signal( self, 'change-menu', 'switch-page');
  $!grid.grid-attach( $!notebook, 0, 1, 1, 1);

  # return one of the pages to set the visibility of the menu after all is shown
  $sheet
}}
}

#`{{
#-------------------------------------------------------------------------------
method set-menu-visibility( Str $menu-id, Bool :$visible ) {
  my Gnome::Gtk3::MenuItem $menu .= new(:build-id($menu-id));
  $menu.set-visible($visible);
}
}}

#--[ signal handlers ]----------------------------------------------------------
#`{{
# change menu on change of notebook pages
method change-menu ( N-GObject $no, uint32 $page-num --> Int ) {

  given $page-num {
    when SHEETPAGE {
      self.set-menu-visibility( 'sheet', :visible);
      self.set-menu-visibility( 'category', :!visible);
      self.set-menu-visibility( 'set', :!visible);
    }

    when CATPAGE {
      self.set-menu-visibility( 'sheet', :!visible);
      self.set-menu-visibility( 'category', :visible);
      self.set-menu-visibility( 'set', :!visible);
    }

    when SETPAGE {
      self.set-menu-visibility( 'sheet', :!visible);
      self.set-menu-visibility( 'category', :!visible);
      self.set-menu-visibility( 'set', :visible);
    }
  }

  1;
}
}}

#-------------------------------------------------------------------------------
method exit-program ( --> Int ) {
  self.quit;

  1
}
