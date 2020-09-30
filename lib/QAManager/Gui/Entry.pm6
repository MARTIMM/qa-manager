use v6.d;

use Gnome::Gtk3::Entry;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::Entry;
also is Gnome::Gtk3::Entry;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  # let the Gnome::Gtk3::Entry class process the options
  self.bless( :GtkEntry, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD (
  Str :$text = '', Str :$example = '', Str :$tooltip = '',
  Bool :$visibility = True, Str :$widget-name = '',
  *%options
) {
  # do not change settings if object comes from elsewhere
  return if %options<native-object>:exists;

#note "V: {$text//'-'}, {$visibility//'-'}";
  self.set-name($widget-name) if ?$widget-name;
  self.set-margin-top(3);
  self.set-size-request( 200, 1);
  self.set-hexpand(True);
  self.set-text($text) if ?$text;
  self.set-tooltip-text($tooltip) if ?$tooltip;
  self.set-visibility(?$visibility);
  self.set-placeholder-text($example) if ?$example;
}
