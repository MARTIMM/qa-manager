#!/usr/bin/env raku

use v6;
#use lib '../gnome-gobject/lib';

use Gnome::Gtk3::Dialog;
use Gnome::Gtk3::Main;
#use Gnome::Gtk3::Enums;
use Gnome::Gtk3::Window;
use Gnome::Gtk3::Button;

use QAManager::Gui::SheetDialog;
use QAManager::QATypes;

#-------------------------------------------------------------------------------
class EH {

  method show-dialog ( ) {
    my QAManager::Gui::SheetDialog $sheet-dialog .= new(
      :sheet-name<QAManagerSetDialog> #, :close-message
    );
    my Int $response = $sheet-dialog.show-dialog;

    note 'dialog closed: ', GtkResponseType($response);

    my $i = 0;
    sub show-hash ( Hash $h ) {
      $i++;
      for $h.keys.sort -> $k {
        if $h{$k} ~~ Hash {
          note '  ' x $i, "$k => \{";
          show-hash($h{$k});
          note '  ' x $i, '}';
        }

        elsif $h{$k} ~~ Array {
          note '  ' x $i, "$k => $h{$k}.perl()";
        }

        else {
          note '  ' x $i, "$k => $h{$k}";
        }
      }
      $i--;
    }

    show-hash($sheet-dialog.result-user-data);
  }

  method exit-app ( ) {
    Gnome::Gtk3::Main.new.gtk-main-quit;
  }

  # check methods
  method check-char ( Str $input, :$char --> Any ) {
    "No $char allowed in string" if ?($input ~~ m/$char/)
  }
}

#-------------------------------------------------------------------------------
# data structure
my EH $eh .= new,
#`{{
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

my QAManager::QATypes $qa-types .= instance;
$qa-types.data-file-type = QAJSON;
$qa-types.cfgloc-userdata = 'xt/Data';
$qa-types.qa-save( 'QAManagerSetDialog', $user-data, :userdata);
#$qa-types.data-file-type = QATOML;
#$qa-types.qa-save( 'QAManagerSetDialog', $user-data, :userdata);

#note $qa-types.qa-load( 'QAManagerSetDialog', :userdata);

#$qa-types.cfgloc-category;
#$qa-types.cfgloc-sheet;
#$qa-types.callback-objects;
#exit(0);
}}

my QAManager::QATypes $qa-types .= instance;
$qa-types.data-file-type = QAJSON;
$qa-types.cfgloc-userdata = 'xt/Data';
$qa-types.set-check-handler( 'check-exclam', $eh, 'check-char', :char<!>);
#note $qa-types.get-check-handler('check-exclam');
#exit(0);


my Gnome::Gtk3::Window $top-window .= new;
$top-window.set-title('Sheet Dialog Test');
$top-window.register-signal( $eh, 'exit-app', 'destroy');
$top-window.set-size-request( 300, 1);
$top-window.window-resize( 300, 1);

my Gnome::Gtk3::Button $dialog-button .= new(:label<Show>);
$top-window.container-add($dialog-button);
$dialog-button.register-signal( $eh, 'show-dialog', 'clicked');

$top-window.show-all;

Gnome::Gtk3::Main.new.gtk-main;
