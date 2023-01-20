use v6;

#-------------------------------------------------------------------------------
unit class QA::Manager::App::Menu::Help:auth<github:MARTIMM>;

use Gnome::GObject::Object;

# $!app is a QA::Manager::Gui::Application
has $!app;

#-------------------------------------------------------------------------------
submethod BUILD ( :$!app ) { }

#-------------------------------------------------------------------------------
# Help > About
method help-about (
  Int :$_handler_id, :_native-object($menu-item)
) {
  note "Select 'About' from 'Help' menu";
}
