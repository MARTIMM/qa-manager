use v6.d;

#-------------------------------------------------------------------------------
unit class QA::Manager::App::Menu::File:auth<github:MARTIMM>;

use Gnome::GObject::Object;

# $!app is a QA::Manager::Gui::Application
has $!app;

#-------------------------------------------------------------------------------
submethod BUILD ( :$!app ) { }

#-------------------------------------------------------------------------------
# File > Quit
method file-quit ( ) {
  note "Select 'Quit' from 'File' menu";

  $!app.quit;
}
