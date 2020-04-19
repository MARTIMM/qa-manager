use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::App::Menu::File:auth<github:MARTIMM>;

use Gnome::GObject::Object;

# $!app is a QAManager::Gui::Application
has $!app;

#-------------------------------------------------------------------------------
submethod BUILD ( :$!app ) { }

#-------------------------------------------------------------------------------
# File > Quit
method file-quit (
  Gnome::GObject::Object :widget($menu-item)
) {
  note "Select 'Quit' from 'File' menu";

  $!app.quit;
}
