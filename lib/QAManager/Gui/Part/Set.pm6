use v6;

use Gnome::Gtk3::Grid;
use Gnome::Gtk3::Frame;
use Gnome::Gtk3::Enums;
use Gnome::Gtk3::Separator;
use Gnome::Gtk3::StyleContext;

use QAManager::Category;
use QAManager::Set;
use QAManager::KV;
use QAManager::Gui::Part::KV;
use QAManager::Gui::Frame;
use QAManager::Gui::DemoDialog;

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

unit class QAManager::Gui::Part::Set:auth<github:MARTIMM>;
also is QAManager::Gui::DemoDialog;

#-------------------------------------------------------------------------------
has Hash $!part-user-data;
has QAManager::Set $!set;

#-------------------------------------------------------------------------------
# must repeat this new call because it won't call the one of
# QAManager::Gui::SetDemoDialog
submethod new ( |c ) {
  self.bless( :GtkDialog, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD (
  Int:D :grid-row($parent-grid-row) = 0, Str:D :$category, Str:D :$set-name,
  Hash :$!part-user-data = %(),
) {

  # get the grid of the dialog
  my $parent-grid = self.dialog-content;

  # get the set from
  $!set = QAManager::Category.new(:$category).get-set($set-name);

  # create a frame with title
  my QAManager::Gui::Frame $set-frame .= new(:label($!set.title));
  $parent-grid.grid-attach( $set-frame, 0, $parent-grid-row, 1, 1);

  # the grid is for displaying the input fields and are
  # strechable horizontally
  my Gnome::Gtk3::Grid $kv-grid .= new;
  $kv-grid.set-border-width(5);
  #$kv-grid.set-row-spacing(5);
  $kv-grid.widget-set-hexpand(True);
  $set-frame.container-add($kv-grid);

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
  my Int $grid-row = 0;
  $kv-grid.grid-attach( $descr, 0, $grid-row++, 3, 1);

  my Gnome::Gtk3::Separator $sep .= new(
    :orientation(GTK_ORIENTATION_HORIZONTAL)
  );
  $kv-grid.grid-attach( $sep, 0, $grid-row++, 3, 1);


  # show set with user data if any
  self!build-set-fields( $kv-grid, $grid-row);
  self!set-field-values( $kv-grid, $grid-row, $!part-user-data);
#  $kv-grid.show-all;
}

#-------------------------------------------------------------------------------
method !build-set-fields ( Gnome::Gtk3::Grid $kv-grid, Int $grid-row is copy ) {
#Gnome::N::debug(:on);

  my QAManager::Gui::Part::KV $kv-part .= new;
  $kv-part.clean-entries;

  for @($!set.get-kv) -> QAManager::KV $kv {
note "kv: $kv.name(), $kv.field()";
    $kv-part .= new;

    $kv-part.build-entry( :$kv-grid, :$grid-row, :$kv);
    $kv-part.check-field( :$kv-grid, :$grid-row, :$kv);

    $grid-row++;
  }
}

#-------------------------------------------------------------------------------
method !set-field-values (
  Gnome::Gtk3::Grid $kv-grid, Int $grid-row is copy, Hash $part-user-data
) {
#Gnome::N::debug(:on);

  for @($!set.get-kv) -> QAManager::KV $kv {
    my QAManager::Gui::Part::KV $kv-part .= new;
    $kv-part.set-value( :$kv-grid, :$grid-row, :values($part-user-data), :$kv);
#    QAManager::Gui::Part::KV.new( :$kv-grid, :$grid-row, :$value, :$kv);
#    $grid-row++;
  }
}
