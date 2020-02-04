use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::TopLevel:auth<github:MARTIMM>;

use QAManager::Gui::Main;

use QAManager::Category;
use QAManager::Set;
use QAManager::KV;

use Gnome::Gdk3::Types;

use Gnome::Gtk3::Enums;
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
#Gnome::N::debug(:on);

subset GtkAllocation of N-GdkRectangle;

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
  $!grid.widget-set-hexpand(True);
  $!window.container-add($!grid);

  $!notebook .= new;
  $!notebook.widget-set-hexpand(True);
  $!notebook.widget-set-vexpand(True);
  $!grid.grid-attach( $!notebook, 0, 1, 1, 1);

  my Gnome::Gtk3::Grid $button-grid .= new;
  $button-grid.widget-set-hexpand(True);
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
    $sheet.set-border-width(5);
    my Int $sheet-row = 0;

    # place category title and description as first text at top of sheet
    my Gnome::Gtk3::Label $cat-title .= new(:text([~] '<b>', $c.name, '</b>'));
    $cat-title.set-use-markup(True);
    $cat-title.widget-set-hexpand(True);
    $cat-title.widget-set-halign(GTK_ALIGN_START);
    $cat-title.widget-set-valign(GTK_ALIGN_START);
    $sheet.grid-attach( $cat-title, 0, $sheet-row++, 1, 1);

    my Gnome::Gtk3::Label $cat-descr .= new(:text($c.description));
    $cat-descr.set-line-wrap(True);
#    $cat-text.widget-set-hexpand(True);
    $cat-descr.widget-set-halign(GTK_ALIGN_START);
    $cat-descr.widget-set-valign(GTK_ALIGN_START);
#    $sheet.grid-attach( $cat-descr, 0, $sheet-row++, 1, 1);

    for $c.get-setnames -> $setname {
      my QAManager::Set $set = $c.get-set($setname);

      # each set is displayed in a frame with a grid. the frame is
      # only to expand horizontally so frames keep together
      my Gnome::Gtk3::Frame $set-frame .= new(:label($set.title));
      $set-frame.set-label-align( 4e-2, 5e-1);
      #$set-frame.set-border-width(5);
      $set-frame.widget-set-hexpand(True);
      $sheet.grid-attach( $set-frame, 0, $sheet-row++, 2, 1);

      # the grid is for displaying the input fields also only
      # strechable horizontally
      my Int $set-row = 0;
      my Gnome::Gtk3::Grid $set-grid .= new;
      $set-grid.set-border-width(5);
      $set-grid.widget-set-hexpand(True);
      $set-frame.container-add($set-grid);

      # place set description on top
      my Gnome::Gtk3::Label $descr .= new(:text("<b>$set.description()\</b>"));
      $descr.set-use-markup(True);
      $set-grid.grid-attach( $descr, 0, $set-row++, 2, 1);

      for @($set.get-kv)>>.kv-data -> Hash $kv {
        # on the left side a text for the input field on the right
        # this text must take  the available space pressing fields to the right
        my Gnome::Gtk3::Label $l .= new(
          :text([~] '<b>', $kv<description> // $kv<title>, '</b>', ':')
        );
        $l.set-use-markup(True);
        $l.widget-set-hexpand(True);
        $l.widget-set-halign(GTK_ALIGN_START);
        $l.widget-set-valign(GTK_ALIGN_START);
        $set-grid.grid-attach( $l, 0, $set-row, 1, 1);

        # Show required with a bold star
        $l .= new(:text([~] '<b>', $kv<required> ?? '*' !! '', '</b>', ' '));
        $l.set-use-markup(True);
        $set-grid.grid-attach( $l, 1, $set-row, 1, 1);


        # fields come at the right side only using space for themselves
        # check widget field type
        if $kv<field> ~~ QAEntry {
          my Gnome::Gtk3::Entry $e .= new;
          $e.widget-set-margin-top(3);
          $e.widget-set-name($kv<name>);
          $e.set-placeholder-text($kv<example>) if ?$kv<example>;
          $e.set-visibility(!$kv<invisible>);
          $set-grid.grid-attach( $e, 2, $set-row, 1, 1);
        }

        elsif $kv<field> ~~ QACheckButton {
          my Gnome::Gtk3::CheckButton $cb .= new;
          $cb.widget-set-name($kv<name>);
          $cb.widget-set-margin-top(3);
          $set-grid.grid-attach( $cb, 2, $set-row, 1, 1);
        }

        $set-row++;
      }
    }

    $!notebook.append-page( $sheet, Gnome::Gtk3::Label.new(:text($c.title)));
Gnome::N::debug(:on);
my N-GdkRectangle $r = $!notebook.get-allocation;
note "w 0: ", $r.perl;
    $sheet.grid-attach( $cat-descr, 0, $sheet-row++, 1, 1);
$r = $!notebook.get-allocation;
note "w 1: ", $r.perl;

  }


  # add each sheet to a Stack or a Notebook

  # show the starting category

  $!window.show-all;
  $!main.gtk-main;

  $!user-data
}
