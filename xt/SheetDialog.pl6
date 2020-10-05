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

  method show-dialog ( Hash :$user-data = %() ) {
    my QAManager::Gui::SheetDialog $sheet-dialog .= new(
      :sheet-name<QAManagerSetDialog>, :$user-data
    );
    my Int $response = $sheet-dialog.show-dialog;
note 'dialog closed: ', GtkResponseType($response), ', ', $sheet-dialog.dialog-content, ', ', $sheet-dialog.result-user-data.perl;

    $sheet-dialog.widget-destroy;
  }

  method exit-app ( ) {
    Gnome::Gtk3::Main.new.gtk-main-quit;
  }
}

#-------------------------------------------------------------------------------
my EH $eh .= new,
my Hash $user-data = %(
  page1 => %(
    QAManagerDialogs => %(
      set-spec => %(
        :name('my key'),
        :title('whatsemegaddy'),
        :description('longer text')
      ),
    ),
  ),
  page2 => %(
    QAManagerDialogs => %(
      entry-spec => %(
      ),
    ),
  ),
);

my Gnome::Gtk3::Window $top-window .= new;
$top-window.set-title('Sheet Dialog Test');
$top-window.register-signal( $eh, 'exit-app', 'destroy');
$top-window.set-size-request( 300, 1);
$top-window.window-resize( 300, 1);

my Gnome::Gtk3::Button $dialog-button .= new(:label<Show>);
$top-window.container-add($dialog-button);
$dialog-button.register-signal( $eh, 'show-dialog', 'clicked', :$user-data);

$top-window.show-all;

Gnome::Gtk3::Main.new.gtk-main;
