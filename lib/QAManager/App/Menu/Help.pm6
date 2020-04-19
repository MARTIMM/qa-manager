use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::App::Menu::Help:auth<github:MARTIMM>;

use Gnome::GObject::Object;

# $!app is a QAManager::Gui::Application
has $!app;

#-------------------------------------------------------------------------------
submethod BUILD ( :$!app ) { }

#-------------------------------------------------------------------------------
# Help > About
method help-about (
  Gnome::GObject::Object :widget($menu-item)
) {
  note "Select 'About' from 'Help' menu";
}
