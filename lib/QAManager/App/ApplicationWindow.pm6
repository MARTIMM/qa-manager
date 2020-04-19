use v6;

#-------------------------------------------------------------------------------
use Gnome::Glib::Error;

use Gnome::Gdk3::Pixbuf;

use Gnome::Gtk3::ApplicationWindow;
use Gnome::Gtk3::Window;

#-------------------------------------------------------------------------------
unit class QAManager::App::ApplicationWindow;
also is Gnome::Gtk3::ApplicationWindow;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  # let the Gnome::Gtk3::ApplicationWindow class process the options
  self.bless( :GtkApplicationWindow, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD ( *%options ) {

  self.set-title('Question Answer Manager');
#  self.set-border-width(20);
  self.register-signal( self, 'exit-program', 'destroy');
  self.set-keep-above(True);
  self.set-position(GTK_WIN_POS_MOUSE);
  self.set-size-request( 400, 450);
  self.window-resize( 400, 450);

  my Gnome::Gdk3::Pixbuf $win-icon .= new(
    :file(%?RESOURCES<icons8-invoice-100.png>.Str)
  );
  my Gnome::Glib::Error $e = $win-icon.last-error;
  if $e.is-valid {
    note "Error icon file: $e.message()";
  }

  else {
    self.set-icon($win-icon);
  }
}
