use v6.d;

use JSON::Fast;
use Config::TOML;
use Config::INI;
use Config::INI::Writer;

use Gnome::N::X;

use Gnome::GObject::Object;

use Gnome::Glib::Error;

use Gnome::Gdk3::Pixbuf;

use Gnome::Gtk3::Box;
use Gnome::Gtk3::Enums;
use Gnome::Gtk3::Dialog;
use Gnome::Gtk3::Notebook;
use Gnome::Gtk3::Label;
use Gnome::Gtk3::Frame;
use Gnome::Gtk3::Grid;
use Gnome::Gtk3::Entry;
use Gnome::Gtk3::TextView;
use Gnome::Gtk3::TextBuffer;
use Gnome::Gtk3::CheckButton;
use Gnome::Gtk3::ComboBoxText;
use Gnome::Gtk3::RadioButton;
use Gnome::Gtk3::Button;
use Gnome::Gtk3::ToolButton;
use Gnome::Gtk3::Switch;
use Gnome::Gtk3::Image;
use Gnome::Gtk3::Widget;
use Gnome::Gtk3::Window;


use QAManager::QATypes;
#use QAManager::Gui::Main;
use QAManager::Category;
use QAManager::Sheet;
use QAManager::Set;
use QAManager::KV;

#-------------------------------------------------------------------------------
=begin pod
Purpose of this dialog is to present questions. The questions are devided over a number of pages. On each page there are sets of questions. The method to display pages can vary between a Notebook, Assistant or Stack.
=end pod

unit class QAManager::Gui::SheetDialog:auth<github:MARTIMM>;
also is Gnome::Gtk3::Dialog;

# $!app is a QAManager::Gui::Application
has $!app;

has Hash $!user-data;
has Array $!categories;
has Str $!invoice-title;
has Bool $.results-valid;
has Any $!callback-object;

has Gnome::Gtk3::Grid $!grid;
has Gnome::Gtk3::Notebook $!notebook;

#-------------------------------------------------------------------------------
has QAManager::Sheet $!sheet;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  self.bless( :GtkDialog, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD ( Gnome::GObject::Object :$!app ) {

#Gnome::N::debug(:on);
  self.set-keep-above(True);
#  self.set-transient-for($!app);
  self.set-position(GTK_WIN_POS_MOUSE);
  self.set-size-request( 550, 1);
  self.window-resize( 550, 1);

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
#Gnome::N::debug(:off);

  $!user-data = %();
  $!categories = [];

  # a grid is placed in this dialog
  $!grid .= new;
  $!grid.widget-set-hexpand(True);

#Gnome::N::debug(:on);
  my Gnome::Gtk3::Box $content .= new(:native-object(self.get-content-area));
  $content.container-add($!grid);

#TODO type of representation QADisplayType
  # in this grid a notebook at ( 0, 0)
  $!notebook .= new;
  $!notebook.widget-set-hexpand(True);
  $!notebook.widget-set-vexpand(True);
  $!grid.grid-attach( $!notebook, 0, 0, 1, 1);

  # and another grid for buttons at ( 0, 1)
  my Gnome::Gtk3::Grid $button-grid .= new;
  $button-grid.widget-set-hexpand(True);
  $!grid.grid-attach( $button-grid, 0, 1, 1, 1);

  # insert a space eating all available space. this will push
  # the buttons to the right
  my Gnome::Gtk3::Label $space .= new(:text(' '));
  $space.widget-set-hexpand(True);
  $button-grid.grid-attach( $space, 0, 0, 1, 1);

  my Gnome::Gtk3::Button $b .= new(
    :native-object(self.add-button( 'Cancel', GTK_RESPONSE_CANCEL))
  );
  $b.register-signal( self, 'cancel-dialog', 'clicked');

  $b .= new(
    :native-object(self.add-button( 'Finish', GTK_RESPONSE_ACCEPT))
  );
  $b.register-signal( self, 'finish-dialog', 'clicked');

#`{{
  my Gnome::Gtk3::Button $cancel-button .= new(:label<Cancel>);
  $cancel-button.register-signal( $!main-handler, 'cancel-program', 'clicked');
  $button-grid.grid-attach( $cancel-button, 1, 0, 1, 1);

  my Gnome::Gtk3::Button $finish-button .= new(:label<Finish>);
  $finish-button.register-signal( $!main-handler, 'finish-program', 'clicked');
  $button-grid.grid-attach( $finish-button, 2, 0, 1, 1);
}}
}

#-------------------------------------------------------------------------------
method set-callback-object ( Any:D $!callback-object ) { }

#-------------------------------------------------------------------------------
method run-invoice(
  Str :$sheet, Bool :$save = True
  --> Hash
) {

  # load sheet
  $!sheet .= new(:$sheet);
  if $!sheet.is-loaded {

  }

  given GtkResponseType(self.gtk-dialog-run) {
    when GTK_RESPONSE_ACCEPT {
      note "accept response: ", $_;
    }

    default {
      note "cancel response: ", $_;
    }
  }

  $!user-data
}

#-------------------------------------------------------------------------------
method load-userdata (
  Str :$result-file is copy,
  Bool :$use-filename-as-is = False,
  --> Hash
) {
  my Hash $user-data = %();

  my Str $pdir = $*PROGRAM-NAME.IO.basename;

  if ? $result-file {

    # check if filename is renamed to file in config path with proper extension
    unless $use-filename-as-is {

      # extend filename with extension
      given $*DataFileType {
        when 'json' {
          $result-file ~= '.json';
        }

        when 'toml' {
          $result-file ~= '.toml';
        }

        when 'ini' {
          $result-file ~= '.ini';
        }
      }

      # define and create config environment
      mkdir( "$*HOME/.config", 0o760) unless "$*HOME/.config".IO.e;
      mkdir( "$*HOME/.config/$pdir", 0o760) unless "$*HOME/.config/$pdir".IO.e;

      $result-file = "$*HOME/.config/$pdir/$result-file";
    }
  }

  else {
    $pdir ~~ s/ \. <-[.]>+ $ //;
    $result-file = "$pdir.cfg";
  }

  if $result-file.IO.r {
    given $*DataFileType {
      when 'json' {
        $user-data = from-json($result-file.IO.slurp);
      }

      when 'toml' {
        $user-data = from-toml($result-file.IO.slurp);
      }

      when 'ini' {
        $user-data = Config::INI::parse($result-file.IO.slurp);
      }
    }
  }

  $!user-data
}

#-------------------------------------------------------------------------------
method finish-program ( --> Int ) {

  1
}

#-------------------------------------------------------------------------------
method cancel-program ( --> Int ) {
  $!results-valid = False;

  1
}
