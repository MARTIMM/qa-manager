use v6.d;

use Gnome::Gtk3::Frame;
use Gnome::Gtk3::ComboBoxText;
use Gnome::Gtk3::Grid;
use Gnome::Gtk3::ToolButton;
use Gnome::Gtk3::Image;
#use Gnome::Gtk3::Entry;

use QAManager::Gui::Part::Entry;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::Part::EntryFrame;
also is Gnome::Gtk3::Frame;

#-------------------------------------------------------------------------------
has Array[QAManager::Gui::Part::Entry] $!values;
has Gnome::Gtk3::Grid $!grid;

has Str $!widget-name;
has Str $!example;
has Str $!tooltip;
has Bool $!repeatable;
has Bool $!visibility;

#has Int $!entry-count;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  # let the Gnome::Gtk3::Frame class process the options
  self.bless( :GtkFrame, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD (
  Str:D :$!widget-name, Str :$!example, Str :$!tooltip,
  Bool :$!repeatable = False, Bool :$!visibility = True
) {
  $!example //= '';
  $!tooltip //= '';
  $!repeatable //= False;
  $!visibility //= True;
#  $!entry-count = 0;

#note "\nB: $!widget-name, $!example, $!tooltip, $!repeatable, $!visibility";

  # clear values
  $!values = Array[QAManager::Gui::Part::Entry].new;

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

#-------------------------------------------------------------------------------
method set-values ( Array $text-array, Bool :$overwrite = True ) {

  # when no repetitions, there should be only one field max
  my Int $n-fields = $!repeatable
                     ?? $text-array.elems
                     !! min( $text-array.elems, 1);

  loop ( my $i = 0; $i < $n-fields; $i++ ) {
    my Str $text = $text-array[$i];

    if $!values[$i].defined {
      $!values[$i].set-text($text) if ?$!values[$i] or $overwrite;

      # modify the one before the last button image which was a '+' to add
      # entries into one that deletes the entry
      if $!repeatable and $i == $n-fields - 2 {
        my Gnome::Gtk3::ToolButton $tb .= new(
          :native-object($!grid.get-child-at( 1, $i))
        );
        $tb.widget-destroy;
        my Gnome::Gtk3::Image $image .= new(
          :filename(%?RESOURCES<Delete.png>.Str)
        );
        $tb .= new(:icon($image));
        $tb.register-signal( self, 'delete-entry', 'clicked');
        $!grid.grid-attach( $tb, 1, $i, 1, 1);
      }
    }

    else {
#      my Str $entry-widget-name = $!widget-name ~ $!entry-count;
      my QAManager::Gui::Part::Entry $entry .= new(
        :$text, :$!example, :$!tooltip, :$!visibility,
#        :widget-name($entry-widget-name)
      );
      $!grid.grid-attach( $entry, 0, $i, 1, 1);
      $!values.push($entry);

      if $!repeatable {
        my Gnome::Gtk3::ToolButton $tb;
        my Gnome::Gtk3::Image $image;
        if $i < $n-fields - 1 {
          $image .= new(:filename(%?RESOURCES<Delete.png>.Str));
          $tb .= new(:icon($image));
          $tb.register-signal( self, 'delete-entry', 'clicked');
        }

        else {
          $image .= new(:filename(%?RESOURCES<Add.png>.Str));
          $tb .= new(:icon($image));
          $tb.register-signal( self, 'add-entry', 'clicked');
        }


        $!grid.grid-attach( $tb, 1, $i, 1, 1);
      }

#      $!entry-count++;
    }
  }

#`{{
  # when repetitions, add an empty entry
  my QAManager::Gui::Part::Entry $entry .= new(
    :$!example, :$!tooltip, :$!visibility
  );
  $!grid.grid-attach( $entry, 0, $!values.elems, 1, 1);

  if $!repeatable {
    my Gnome::Gtk3::Image $image .= new(:filename(%?RESOURCES<Add.png>.Str));
    my Gnome::Gtk3::ToolButton $tb .= new(:icon($image));
    $tb.register-signal( self, 'add-entry', 'clicked');
    $!grid.grid-attach( $tb, 1, $i, 1, 1);
  }

  $!values.push($entry);
}}

  self.show-all;
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
method add-entry ( :$widget ) {
note 'add entry';
}

#-------------------------------------------------------------------------------
method delete-entry ( :$widget ) {
note 'delete entry';
}
