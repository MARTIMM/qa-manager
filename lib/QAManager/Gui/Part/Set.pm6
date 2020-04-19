use v6;

use Gnome::Gtk3::Grid;
use Gnome::Gtk3::Frame;
#use Gnome::Gtk3::Widget;
use Gnome::Gtk3::Enums;
use Gnome::Gtk3::Separator;
use Gnome::Gtk3::StyleContext;

use QAManager::Set;
use QAManager::KV;
use QAManager::Gui::Part::KV;
use QAManager::Gui::Part::Frame;

#-------------------------------------------------------------------------------
=begin pod
Purpose of this part is to display a set of questions.
The format is roughly;
  parent grid
    ...
    set frame with title
      set grid
        description
        kv grid
          label entry
          ...

    ...

  The questions are placed in a grid.
=end pod

unit class QAManager::Gui::Part::Set;

#-------------------------------------------------------------------------------
has Hash $!part-user-data;
has QAManager::Set $!set;

#-------------------------------------------------------------------------------
submethod BUILD (
  Gnome::Gtk3::Grid:D :grid($parent-grid),
  Int:D :grid-row($parent-grid-row) = 0,
  QAManager::Set:D :$!set, Hash :$!part-user-data = %(),
) {

  # create a frame with title
  my QAManager::Gui::Part::Frame $set-frame .= new(:label($!set.title));
  $parent-grid.grid-attach( $set-frame, 0, $parent-grid-row, 1, 1);

  # the grid is for displaying the input fields and are
  # strechable horizontally
  my Gnome::Gtk3::Grid $set-grid .= new;
  $set-grid.set-border-width(5);
  #$set-grid.set-row-spacing(5);
  $set-grid.widget-set-hexpand(True);
  $set-frame.container-add($set-grid);

  # place set description at the top of the grid
  my Gnome::Gtk3::Label $descr .= new(:text($!set.description));
  $descr.set-line-wrap(True);
  #$descr.set-max-width-chars(60);
  $descr.set-justify(GTK_JUSTIFY_FILL);
  $descr.widget-set-halign(GTK_ALIGN_START);
  $descr.widget-set-margin-bottom(3);
  my Gnome::Gtk3::StyleContext $context .= new(
    :native-object($descr.get-style-context)
  );
  $context.add-class('descriptionText');
  my Int $set-row = 0;
  $set-grid.grid-attach( $descr, 0, $set-row++, 3, 1);

  my Gnome::Gtk3::Separator $sep .= new(
    :orientation(GTK_ORIENTATION_HORIZONTAL)
  );
  $set-grid.grid-attach( $sep, 0, $set-row++, 3, 1);


  # show set with user data if any
  self!show-set-fields( $set-grid, $set-row);
  self!show-set-field-values( $set-grid, $!part-user-data);
#  $set-grid.show-all;
}

#-------------------------------------------------------------------------------
method !show-set-fields ( Gnome::Gtk3::Grid $kv-grid, Int $grid-row is copy ) {
#Gnome::N::debug(:on);

  my $value = '';

  for @($!set.get-kv) -> QAManager::KV $kv {
    QAManager::Gui::Part::KV.new( :$kv-grid, :$grid-row, :$value, :$kv);
    $grid-row++;
  }
}

#-------------------------------------------------------------------------------
method !show-set-field-values (
  Gnome::Gtk3::Grid $kv-grid, Hash $part-user-data
) {
#Gnome::N::debug(:on);

#  for @($!set.get-kv) -> QAManager::KV $kv {
#    QAManager::Gui::Part::KV.new( :$kv-grid, :$grid-row, :$value, :$kv);
#    $grid-row++;
#  }
}
