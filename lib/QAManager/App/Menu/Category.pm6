use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::App::Menu::Category:auth<github:MARTIMM>;

use Gnome::GObject::Object;

# $!app is a QAManager::Gui::Application
has $!app;

#-------------------------------------------------------------------------------
submethod BUILD ( :$!app ) { }

#-------------------------------------------------------------------------------
# category > New
method category-new (
  Gnome::GObject::Object :widget($menu-item)
) {
  note "Select 'New' from 'Category' menu";
}
