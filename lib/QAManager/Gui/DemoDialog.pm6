use v6.d;

use Gnome::N::X;

use Gnome::Gtk3::Enums;
use Gnome::Gtk3::Dialog;

use QAManager::Gui::Dialog;

#-------------------------------------------------------------------------------
=begin pod
Purpose of this dialog is to demo a set of questions. This gives the user a proper idea of what the set will look like and if there are other modifications needed or questions added.
=end pod

unit class QAManager::Gui::DemoDialog:auth<github:MARTIMM>;
also is QAManager::Gui::Dialog;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  self.bless( :GtkDialog, |c);
}

#-------------------------------------------------------------------------------
#submethod BUILD ( Gnome::GObject::Object :$!app ) {
submethod BUILD ( ) {
  self.set-title('Question Answer Demo');
  self.add-dialog-button(
    self, 'close-dialog', 'Close', GTK_RESPONSE_CLOSE
  );
}

#-------------------------------------------------------------------------------
method close-dialog ( --> Int ) {
  note 'close dialog';

  1
}
