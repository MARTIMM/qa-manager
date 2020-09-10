use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::App::Menu::Set:auth<github:MARTIMM>;

use Gnome::GObject::Object;

use QAManager;
use QAManager::Gui::SheetDialog;

# $!app is a QAManager::Gui::Application
has $!app;

#-------------------------------------------------------------------------------
submethod BUILD ( :$!app ) { }

#-------------------------------------------------------------------------------
# Set > New
method set-new ( Int :$_handler_id,
    Gnome::GObject::Object :_widget($menu-item) ) {
#Gnome::N::debug(:on);
  note "Select 'New' from 'Set' menu, dft=$*DataFileType";

  my QAManager::Gui::SheetDialog $set-entry-dialog .= new(:$!app);
#`{{
  $set-entry-dialog.set-callback-object($callback-handlers);
  $set-entry-dialog.load-userdata(
    :result-file(''), :use-filename-as-is
  );
}}

  my Hash $set-data = $set-entry-dialog.run-invoice(
    :sheet<QAManagerSetDialog>, :!save
  );

  $set-entry-dialog.gtk_widget_destroy;

  note $set-data.perl;
#Gnome::N::debug(:off);
}
