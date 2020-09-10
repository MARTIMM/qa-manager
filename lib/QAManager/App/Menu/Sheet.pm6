use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::App::Menu::Sheet:auth<github:MARTIMM>;

use Gnome::GObject::Object;

# $!app is a QAManager::Gui::Application
has $!app;

#-------------------------------------------------------------------------------
submethod BUILD ( :$!app ) { }

#-------------------------------------------------------------------------------
# Sheet > New
method sheet-new (
  Int :$_handler_id,
    Gnome::GObject::Object :_widget($menu-item)
) {
  note "Select 'New' from 'Sheet' menu";
}
