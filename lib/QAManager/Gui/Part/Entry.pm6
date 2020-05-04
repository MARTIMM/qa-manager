use v6.d;

use Gnome::Gtk3::Entry;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::Part::Entry;
also is Gnome::Gtk3::Entry;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  # let the Gnome::Gtk3::Frame class process the options
  self.bless( :GtkEntry, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD (
  Str :$text, Str :$example, Str :$tooltip, Bool :$visibility,
  Str :$widget-name
) {

  self.widget-set-name($widget-name) if ?$widget-name;
  self.widget-set-margin-top(3);
  self.set-size-request( 200, 1);
  self.widget-set-hexpand(True);
  self.set-text($text) if ?$text;
  self.set-tooltip-text($tooltip) if ?$tooltip;
  self.set-visibility(?$visibility);
  self.set-placeholder-text($example) if ?$example;
}
