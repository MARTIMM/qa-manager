use v6.d;

use Gnome::Gtk3::Frame;
use Gnome::Gtk3::Enums;

use QAManager::Gui::Value;

#-------------------------------------------------------------------------------
=begin pod
Purpose of this frame is to group a set of widgets.

=end pod

unit class QAManager::Gui::GroupFrame:auth<github:MARTIMM>;
also is Gnome::Gtk3::Frame;
also does QAManager::Gui::Value;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  self.bless( :GtkFrame, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  self.set-shadow-type(GTK_SHADOW_ETCHED_IN);
  self.widget-set-margin-top(3);
}

#-------------------------------------------------------------------------------
method get-values ( --> Array ) {

}

#-------------------------------------------------------------------------------
# no typing of $data-key and $data-value because data can be any
# of text-, number- or boolean
method set-value ( $data-key, $data-value, Int $row, Bool :$overwrite ) {

}

#-------------------------------------------------------------------------------
method check-values ( ) {

}
