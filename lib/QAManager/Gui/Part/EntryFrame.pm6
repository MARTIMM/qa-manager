use v6.d;

use Gnome::N::N-GObject;

use Gnome::Gtk3::Frame;
use Gnome::Gtk3::ComboBoxText;
use Gnome::Gtk3::Grid;
use Gnome::Gtk3::ToolButton;
use Gnome::Gtk3::Image;
use Gnome::Gtk3::Enums;
use Gnome::Gtk3::ComboBoxText;

use QAManager::Gui::Part::Entry;
use QAManager::App::Part::ValueRepr;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::Part::EntryFrame;
also is Gnome::Gtk3::Frame;
also is QAManager::App::Part::ValueRepr;

#-------------------------------------------------------------------------------
has Array[QAManager::Gui::Part::Entry] $!entries;
has Gnome::Gtk3::Grid $!grid;

has Str $!widget-name;
has Str $!example;
has Str $!tooltip;
has Bool $!repeatable;
has Bool $!visibility;
has Array $!entry-category;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  # let the Gnome::Gtk3::Frame class process the options
  self.bless( :GtkFrame, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD (
  Str:D :$!widget-name, Str :$!example, Str :$!tooltip,
  Bool :$!repeatable, Bool :$!visibility,
  Array :$!entry-category
) {
  $!example //= '';
  $!tooltip //= '';
  $!repeatable //= False;
  $!visibility //= True;
  $!entry-category //= [];

note "\nB: $!widget-name, $!example, $!tooltip, $!repeatable, $!visibility";

  # clear values
  $!entries = Array[QAManager::Gui::Part::Entry].new;

  # fiddle a bit
  self.widget-set-margin-top(3);
#  self.set-size-request( 200, 1);
  self.widget-set-name($!widget-name);
  self.widget-set-hexpand(True);

  # add a grid to the frame
  $!grid .= new;
  self.container-add($!grid);

  # create one entry
  self.set-values(['',]);
}

#------------------------------------------------------------------------------
method set-value (
  $data-key, $data-value, $row, Bool :$overwrite = True, Bool :$last-row
) {

  # if not repeatable, only row 0 can exist
  return if not $!repeatable and $row > 0;

#  my Int $tb-col = self.check-toolbutton-column;

  # if key is a number then only text without a combobox is shown. Text is
  # found in $data-value. If combobox is needed then text is in text-key
  # and combobox selection in text-value.
  my Bool $need-combobox = $!entry-category.elems.Bool;
  my Str $text = ($data-key ~~ m/^ \d+ $/).Bool ?? $data-value !! $data-key;
note "SV: {$data-key//'-'}, {$data-value//'-'}, {$text//'-'}";

  # check if there is an input field defined. if not, create input field.
  # otherwise get object from grid
  my Bool $new-row;
  my QAManager::Gui::Part::Entry $entry;
  if $!entries[$row].defined {
    $new-row = False;
    $entry .= new(:native-object($!grid.get-child-at( 0, $row)));
  }

  else {
    $new-row = True;
    $entry .= new( :$text, :$!example, :$!tooltip, :$!visibility);
    $!grid.grid-attach( $entry, 0, $row, 1, 1);
    $!entries.push($entry);
  }

  # the text can be written only if field is empty or if overwrite is True
  $!entries[$row].set-text($text) if ! $!entries[$row].get-text or $overwrite;

  # insert and set value of a combobox
  my Gnome::Gtk3::ComboBoxText $cbt;
  if $need-combobox {
    if $new-row {
      $cbt = self.create-combobox;
      $!grid.attach-next-to( $cbt, $entry, GTK_POS_RIGHT, 1, 1);
    }

    else {
      $cbt .= new(:native-object($!grid.get-child-at( 1, $row)));
    }

    self.set-combobox-select( $cbt, $data-value.Str);
  }

  # at last the toolbutton if $!repeatable
  if $!repeatable {
    my Gnome::Gtk3::ToolButton $tb;
    if $new-row {
      $tb = self.create-toolbutton(:add($last-row));
      $!grid.attach-next-to(
        $tb, $need-combobox ?? $cbt !! $entry, GTK_POS_RIGHT, 1, 1
      );
    }

    else {

    }
  }

  self.rename-buttons;
}

#-------------------------------------------------------------------------------
method get-values ( --> Array ) {
}

#-------------------------------------------------------------------------------
method check-values ( ) {
}

#-------------------------------------------------------------------------------
method !add-value ( Str $text ) {
}

#-------------------------------------------------------------------------------
method add-entry (
  Gnome::Gtk3::ToolButton :_widget($toolbutton), Int :$_handler-id
) {

  # modify this buttons icon and signal handler
  my Gnome::Gtk3::Image $image .= new(:filename(%?RESOURCES<Delete.png>.Str));
  $toolbutton.set-icon-widget($image);
  $toolbutton.handler-disconnect($_handler-id);
  $toolbutton.register-signal( self, 'delete-entry', 'clicked');

  # create new tool button on row below the button triggering this handler
  my Gnome::Gtk3::ToolButton $tb;
  $image .= new(:filename(%?RESOURCES<Add.png>.Str));
  $tb .= new(:icon($image));
  $tb.register-signal( self, 'add-entry', 'clicked');
  $!grid.attach-next-to( $tb, $toolbutton, GTK_POS_BOTTOM, 1, 1);

  # check if a combobox is to be drawn
  my Int $tbcol = self.check-toolbutton-column;
  my Gnome::Gtk3::ComboBoxText $cbt;
  if $tbcol == 2 {
    $cbt = self.create-combobox;
    $!grid.attach-next-to( $cbt, $tb, GTK_POS_LEFT, 1, 1);
  }

  # create new text entry to the left of the button
  my QAManager::Gui::Part::Entry $entry .= new(:$!visibility);
  $!grid.attach-next-to(
    $entry, $tbcol == 2 ?? $cbt !! $tb, GTK_POS_LEFT, 1, 1
  );

  self.rename-buttons;
  $!grid.show-all;
}

#-------------------------------------------------------------------------------
method delete-entry (
  Gnome::Gtk3::ToolButton :_widget($toolbutton), Int :$_handler-id
) {

  # delete a row using the name of the toolbutton, see also rename-buttons().
  my Str $name = $toolbutton.get-name;
  $name ~~ s/ 'tb-button' //;
  my Int $row = $name.Int;
  $!grid.remove-row($row);
  self.rename-buttons;
}

#-------------------------------------------------------------------------------
# rename buttons in such a way that the row number is saved in the name.
method rename-buttons ( ) {

  my Int $tb-col = self.check-toolbutton-column;
  my Int $row = 0;
  my Gnome::Gtk3::ToolButton $toolbar-button;
  loop {
    my $ntb = $!grid.get-child-at( $tb-col, $row);
    last unless $ntb.defined;

    $toolbar-button .= new(:native-object($ntb));
    $toolbar-button.set-name("tb-button$row");
    $row++;
  }
}

#-------------------------------------------------------------------------------
# plans are to insert a combobox before entry. this means that toolbutton
# can be in column 1 or 2
method check-toolbutton-column ( --> Int ) {

  my $ntb = $!grid.get-child-at( 2, 0);
  $ntb.defined ?? 2 !! 1
}

#-------------------------------------------------------------------------------
method create-toolbutton ( Bool :$add --> Gnome::Gtk3::ToolButton ) {

  my Gnome::Gtk3::Image $image .= new(
    :filename($add ?? %?RESOURCES<Add.png>.Str !! %?RESOURCES<Delete.png>.Str)
  );

  my Gnome::Gtk3::ToolButton $tb .= new(:icon($image));
  $tb.register-signal(
    self, $add ?? 'add-entry' !! 'delete-entry', 'clicked'
  );

  $tb
}

#-------------------------------------------------------------------------------
method create-combobox ( Str $select = '' --> Gnome::Gtk3::ComboBoxText ) {

  my Gnome::Gtk3::ComboBoxText $cbt .= new;
  for @$!entry-category -> $v {
    $cbt.append-text($v);
  }

  self.set-combobox-select( $cbt, $select);
  $cbt
}

#-------------------------------------------------------------------------------
method set-combobox-select( Gnome::Gtk3::ComboBoxText $cbt, Str $select = '' ) {

  my Int $value-index = $!entry-category.first( $select, :k) // 0;
  $cbt.set-active($value-index);
}
