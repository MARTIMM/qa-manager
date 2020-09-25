#!/usr/bin/env raku

use v6;
#use lib 'lib';

use Gnome::Gtk3::Dialog;
use Gnome::Gtk3::Main;
#use Gnome::Gtk3::Enums;
use Gnome::Gtk3::Window;
use Gnome::Gtk3::Button;

use QAManager::Gui::SheetDialog;

#-------------------------------------------------------------------------------
class EH {

  method show-dialog ( ) {
    my QAManager::Gui::SheetDialog $sheet-dialog .= new(
      :sheet<QAManagerSetDialog>
    );
    my Int $response = $sheet-dialog.show-dialog;
    if $response ~~ GTK_RESPONSE_CLOSE {
      note 'dialog closed: ', $sheet-dialog.dialog-content;
    }

    $sheet-dialog.widget-destroy;
  }

  method exit-app ( ) {
    Gnome::Gtk3::Main.new.gtk-main-quit;
  }
}

#-------------------------------------------------------------------------------
my EH $eh .= new,

my Gnome::Gtk3::Window $top-window .= new;
$top-window.set-title('Sheet Dialog Test');
$top-window.register-signal( $eh, 'exit-app', 'destroy');

my Gnome::Gtk3::Button $dialog-button .= new(:label<Show>);
$top-window.container-add($dialog-button);
$dialog-button.register-signal( $eh, 'show-dialog', 'clicked');

$top-window.show-all;

Gnome::Gtk3::Main.new.gtk-main;
