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
  Int :$_handler_id,
    Gnome::GObject::Object :_widget($menu-item)
) {
  note "Select 'New' from 'Category' menu";
}
