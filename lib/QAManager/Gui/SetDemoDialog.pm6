use v6.d;

use Gnome::N::X;

use Gnome::Gtk3::Box;
use Gnome::Gtk3::Enums;
use Gnome::Gtk3::Dialog;
use Gnome::Gtk3::Grid;

#use QAManager::QATypes;
use QAManager::Category;
use QAManager::Set;
use QAManager::Gui::Part::Dialog;
use QAManager::Gui::Part::Set;

#-------------------------------------------------------------------------------
=begin pod
Purpose of this dialog is to demo a set of questions. This gives the user a proper idea of what the set will look like and if there are other modifications needed or questions added.
=end pod

unit class QAManager::Gui::SetDemoDialog:auth<github:MARTIMM>;
also is QAManager::Gui::Part::Dialog;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  self.bless( :GtkDialog, |c);
}

#-------------------------------------------------------------------------------
#submethod BUILD ( Gnome::GObject::Object :$!app ) {
submethod BUILD ( ) {
  self.set-title('QA Set Demo');
  self.add-dialog-button(
    self, 'close-dialog', 'Close', GTK_RESPONSE_CLOSE
  );
}

#-------------------------------------------------------------------------------
method set-dialog-content ( Str $cat-name, Str $set-name ) {

  my QAManager::Category $cat .= new(:category($cat-name));
  my QAManager::Set $set = $cat.get-set($set-name);

  QAManager::Gui::Part::Set.new( :grid(self.dialog-content), :$set);
}

#-------------------------------------------------------------------------------
method close-dialog ( --> Int ) {
  note 'close dialog';

  1
}
