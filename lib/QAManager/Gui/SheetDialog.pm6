#tl:1:QAManager::Gui::SheetDialog
use v6.d;

use Gnome::Gtk3::ScrolledWindow;
use Gnome::Gtk3::Grid;
use Gnome::Gtk3::Label;
use Gnome::Gtk3::Button;
use Gnome::Gtk3::Notebook;
use Gnome::Gtk3::Stack;
use Gnome::Gtk3::Assistant;

use QAManager::Gui::Dialog;
use QAManager::Set;
use QAManager::Category;
use QAManager::Question;
use QAManager::Sheet;
use QAManager::QATypes;

#-------------------------------------------------------------------------------
=begin pod
=head1 QAManager::Gui::SheetDialog

This module shows a dialog wherein a sheet configuration is displayed. Several ways to display the sheet are available
=end pod

unit class QAManager::Gui::SheetDialog:auth<github:MARTIMM>;
also is QAManager::Gui::Dialog;

#-------------------------------------------------------------------------------
has QAManager::Sheet $!sheet;

#-------------------------------------------------------------------------------
# must repeat this new call because it won't call the one of
# QAManager::Gui::SetDemoDialog
submethod new ( |c ) {
  self.bless( :GtkDialog, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD ( Str :$sheet ) {
  $!sheet .= new(:$sheet);

  self!init-dialog;
}

#-------------------------------------------------------------------------------
method !init-dialog {

  given $!sheet.display {
    when QADialog {
    }

    when QANoteBook {
      my Gnome::Gtk3::Grid $grid = self.dialog-content;
      my Gnome::Gtk3::ScrolledWindow $scroll-window .= new;
      $grid.grid-attach( $scroll-window, 0, 0, 1, 1);

      my Gnome::Gtk3::Notebook $notebook .= new;
      $notebook.widget-set-hexpand(True);
      $notebook.widget-set-vexpand(True);
      $scroll-window.container-add($notebook);

      $grid.grid-attach(
        self!dialog-buttons(
          self!create-button( 'cancel', 'cancel-dialog'),
          self!create-button( 'finish', 'finish-dialog')
        ),
        0, 1, 1, 1
      );
    }

    when QAStack {
    }

    when QAAssistant {
    }
  }
}

#-------------------------------------------------------------------------------
method !create-button ( $widget-name, $method-name --> Gnome::Gtk3::Button ) {
  my Gnome::Gtk3::Button $b .= new;
  $b.set-name($widget-name);
  $b.register-signal( self, $method-name, 'clicked');

  $b
}

#-------------------------------------------------------------------------------
method !dialog-buttons ( *@buttons --> Gnome::Gtk3::Grid ) {

  my Int $count = 0;
  my Gnome::Gtk3::Grid $db .= new;

  my Gnome::Gtk3::Label $strut .= new(:text(''));
  $strut.set-hexpand(True);
  $db.grid-attach( $strut, $count++, 0, 1, 1);

  my Hash $button-map = $!sheet.button-map // %();
  for @buttons -> $button {
    my Str $button-name = $button.get-name;
    $button-name = $button-map{$button-name} if ?$button-map{$button-name};
    $button.set-label($button-name);
    $db.grid-attach( $button, $count++, 0, 1, 1);
  }

  $db
}

#-------------------------------------------------------------------------------
method cancel-dialog ( ) {
  note 'dialog cancelled';
}

#-------------------------------------------------------------------------------
method finish-dialog ( ) {
  note 'dialog finished';
}
