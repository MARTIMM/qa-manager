use v6.d;

use Gnome::Gtk3::Statusbar;

#use QAManager::QATypes;
#use QAManager::Gui::Frame;
#use QAManager::Question;
#use QAManager::Gui::Value;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::Statusbar;
also is Gnome::Gtk3::Statusbar;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  # let the Gnome::Gtk3::Frame class process the options
  self.bless( :GtkStatusbar, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD (
) {
}
