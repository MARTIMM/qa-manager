use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::MenuSheet:auth<github:MARTIMM>;

use Gnome::GObject::Object;

# $!app is a QAManager::Gui::Application
has $!app;

#-------------------------------------------------------------------------------
submethod BUILD ( :$!app ) { }

#-------------------------------------------------------------------------------
# Sheet > New
method sheet-new (
  Gnome::GObject::Object :widget($menu-item)
) {
  note "Select 'New' from 'Sheet' menu";
}
