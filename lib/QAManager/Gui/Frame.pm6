use v6;

#-------------------------------------------------------------------------------
use Gnome::Gtk3::Frame;
#use Gnome::Gtk3::StyleContext;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::Frame;
also is Gnome::Gtk3::Frame;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  # let the Gnome::Gtk3::Frame class process the options
  self.bless( :GtkFrame, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  # modify frame and title
  self.set-label-align( 4e-2, 5e-1);
  self.widget-set-margin-bottom(3);
  #self.set-border-width(5);
  self.widget-set-hexpand(True);
#  my Gnome::Gtk3::StyleContext $context .= new(
#    :native-object(self.get-style-context)
#  );
#  $context.add-class('titleText');
}
