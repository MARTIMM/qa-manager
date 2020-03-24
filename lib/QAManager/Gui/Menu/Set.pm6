use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::Menu::Set:auth<github:MARTIMM>;

use Gnome::GObject::Object;

# $!app is a QAManager::Gui::Application
has $!app;

#-------------------------------------------------------------------------------
submethod BUILD ( :$!app ) { }

#-------------------------------------------------------------------------------
# Set > New
method set-new (
  Gnome::GObject::Object :widget($menu-item)
) {
  note "Select 'New' from 'Set' menu";
}
