use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::TopLevel:auth<github:MARTIMM>;

use QAManager::Gui::Main;

use QAManager::Category;
use QAManager::Set;
use QAManager::KV;

use Gnome::Gtk3::Main;
use Gnome::Gtk3::Window;
use Gnome::Gtk3::Notebook;
use Gnome::Gtk3::Label;
use Gnome::Gtk3::Frame;
use Gnome::Gtk3::Grid;
use Gnome::Gtk3::Entry;
use Gnome::Gtk3::TextView;
use Gnome::Gtk3::Button;
use Gnome::Gtk3::CheckButton;
use Gnome::Gtk3::RadioButton;

use Gnome::N::X;
Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
has Gnome::Gtk3::Main $!main;
has Gnome::Gtk3::Window $!window;
has Gnome::Gtk3::Grid $!grid;
has Gnome::Gtk3::Notebook $!notebook;

has Array $!categories = [];
has Hash $!user-data = %();

has QAManager::Gui::Main $!main-handler;

#-------------------------------------------------------------------------------
submethod BUILD ( Array :$!categories ) {

  $!main .= new;
  $!main-handler .= new;

  $!window .= new;
  $!window.register-signal( $!main-handler, 'exit-program', 'destroy');

  $!grid .= new;
#  $!grid.widget-hexpand(True);
  $!window.container-add($!grid);

  $!notebook .= new;
#  $!notebook.widget-expand(True);
  $!grid.grid-attach( $!notebook, 0, 1, 1, 1);

  my Gnome::Gtk3::Grid $button-grid .= new;
#  $button-grid.widget-hexpand(True);
  $!grid.grid-attach( $button-grid, 0, 2, 1, 1);
  my Gnome::Gtk3::Button $cancel-button .= new(:label<Cancel>);
  $button-grid.grid-attach( $cancel-button, 0, 0, 1, 1);
  my Gnome::Gtk3::Button $finish-button .= new(:label<Finish>);
  $button-grid.grid-attach( $finish-button, 1, 0, 1, 1);
}

#-------------------------------------------------------------------------------
method do-invoice ( --> Hash ) {

  # build sheet for each category
  for @$!categories -> $c {
    my Gnome::Gtk3::Grid $sheet .= new;
    my Int $sheet-row = 0;
    for $c.get-setnames -> $setname {
      my QAManager::Set $set = $c.get-set($setname);

      # each set is displayed in a frame with a grid
      my Gnome::Gtk3::Frame $set-frame .= new(:label($set.title));
      $set-frame.set-label-align( 4e-2, 5e-1);
      $set-frame.set-border-width(5);
      $sheet.grid-attach( $set-frame, 0, $sheet-row++, 2, 1);

      my Int $set-row = 0;
      my Gnome::Gtk3::Grid $set-grid .= new;
      $set-grid.set-border-width(5);
      $set-frame.container-add($set-grid);

      # place set description on top
      $set-grid.grid-attach(
        Gnome::Gtk3::Label.new(:text($set.description)), 0, $set-row++, 2, 1
      );

      for @($set.get-kv)>>.kv-data -> Hash $kv {
        $set-grid.grid-attach(
          Gnome::Gtk3::Label.new(:text($kv<name>)), 0, $set-row, 1, 1
        );

        # check widget field type
        if $kv<field> ~~ QAEntry {
          my Gnome::Gtk3::Entry $e .= new;
          $e.widget-set-name($kv<name>);

          $set-grid.grid-attach( $e, 1, $set-row, 1, 1);
        }

        $set-row++;
      }
    }

    $!notebook.append-page( $sheet, Gnome::Gtk3::Label.new(:text($c.title)));

  }


  # add each sheet to a Stack or a Notebook

  # show the starting category

  $!window.show-all;
  $!main.gtk-main;

  $!user-data
}
