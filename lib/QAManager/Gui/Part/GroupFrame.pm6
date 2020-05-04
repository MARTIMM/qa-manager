use v6.d;

use Gnome::Gtk3::Frame;
use Gnome::Gtk3::Enums;

#-------------------------------------------------------------------------------
=begin pod
Purpose of this frame is to group a set of widgets.

=end pod

unit class QAManager::Gui::Part::GroupFrame:auth<github:MARTIMM>;
also is Gnome::Gtk3::Frame;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  self.bless( :GtkFrame, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  self.set-shadow-type(GTK_SHADOW_ETCHED_IN);
  self.widget-set-margin-top(3);
}
