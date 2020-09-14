use v6;

use Gnome::Gdk3::Pixbuf;

use Gnome::Gtk3::Grid;
use Gnome::Gtk3::Label;
use Gnome::Gtk3::ToolButton;
use Gnome::Gtk3::Widget;
use Gnome::Gtk3::Enums;
use Gnome::Gtk3::Entry;
use Gnome::Gtk3::TextView;
use Gnome::Gtk3::CheckButton;
use Gnome::Gtk3::ToggleButton;
use Gnome::Gtk3::RadioButton;
use Gnome::Gtk3::ComboBoxText;
use Gnome::Gtk3::Scale;
use Gnome::Gtk3::Switch;
use Gnome::Gtk3::Image;
use Gnome::Gtk3::StyleContext;

use QAManager::QATypes;
use QAManager::Set;
use QAManager::KV;
use QAManager::Gui::Part::GroupFrame;
use QAManager::Gui::Part::EntryFrame;

#-------------------------------------------------------------------------------
=begin pod
Purpose of this part is to display a question in a row on a given grid. This line consists of several columns. The first column shows a text posing the question, the second shows an optional star to show that an input is required. Then the third column is used to show the input area which can be one of several types of input like text, combobox or checkbox groups.
=end pod

unit class QAManager::Gui::Part::KV;

#-------------------------------------------------------------------------------
my Hash $entry-objects = %( );

#-------------------------------------------------------------------------------
#submethod BUILD ( ) { }

#-------------------------------------------------------------------------------
method build-set-fields (
  QAManager::Set $set, Gnome::Gtk3::Grid $kv-grid, Int $grid-row is copy
) {
#Gnome::N::debug(:on);

  self.clean-entries;

  for @($set.get-kv) -> QAManager::KV $kv {
note "kv: $kv.name(), $kv.field()";
    self.build-entry( :$kv-grid, :$grid-row, :$kv);
    self.check-field( :$kv-grid, :$grid-row, :$kv);

    $grid-row++;
  }
}

#-------------------------------------------------------------------------------
method set-field-values (
  QAManager::Set $set, Gnome::Gtk3::Grid $kv-grid, Int $grid-row is copy,
  Hash $part-user-data
) {

  for @($set.get-kv) -> QAManager::KV $kv {
    self.set-value( :$kv-grid, :$grid-row, :values($part-user-data), :$kv);
  }
}

#-------------------------------------------------------------------------------
method build-entry (
  Gnome::Gtk3::Grid :$kv-grid, Int :$grid-row, QAManager::KV :$kv
) {

  # place label on the left. the required star is in the middle column.
  self!shape-label(
    $kv-grid, $grid-row, $kv.title, $kv.description, $kv.required
  );

  # and input fields to the right
  given $kv.field {
    when QAEntry {
      self!entry-field( $kv-grid, $grid-row, $kv);
    }

    when QATextView {
      self!textview-field( $kv-grid, $grid-row, $kv);
    }

    when QAComboBox {
      self!combobox-field( $kv-grid, $grid-row, $kv);
    }

    when QARadioButton {
      self!radiobutton-field( $kv-grid, $grid-row, $kv);
    }

    when QACheckButton {
      self!checkbutton-field( $kv-grid, $grid-row, $kv);
    }

    when QAToggleButton {
      self!togglebutton-field( $kv-grid, $grid-row, $kv);
    }

    when QAScale {
      self!scale-field( $kv-grid, $grid-row, $kv);
    }

    when QASwitch {
      self!switch-field( $kv-grid, $grid-row, $kv);
    }

    when QAImage {
      self!image-field( $kv-grid, $grid-row, $kv);
    }
  }
}

#-------------------------------------------------------------------------------
method check-field (
  Gnome::Gtk3::Grid :$kv-grid, Int :$grid-row, QAManager::KV :$kv
) {
  my $no = $kv-grid.get-child-at( 2, $grid-row);
  my Gnome::Gtk3::Widget $w .= new(:native-object($no));
note "Type: $kv.field(), $grid-row, $w.get-name()";
}

#-------------------------------------------------------------------------------
method set-value (
  Gnome::Gtk3::Grid :$kv-grid, Int :$grid-row, Hash :$values, QAManager::KV :$kv
) {
#note "Type: $kv.field()";
}

#-------------------------------------------------------------------------------
method select-image ( ) {
note "select image";
}

#-------------------------------------------------------------------------------
method clean-entries ( ) {
  $entry-objects = %( );
}

#-------------------------------------------------------------------------------
# on the left side a text label is laced for the input field on the right.
# this label must take the available space pressing the input fields to the
# right.
method !shape-label (
  Gnome::Gtk3::Grid $grid, Int $row,
  Str $title, Str $description, Bool $required
) {

  #my Str $label-text = [~] '<b>', $description // $title, '</b>:';
  my Str $label-text = $description // $title ~ ':';
  given my Gnome::Gtk3::Label $label .= new(:text($label-text)) {
    #.set-use-markup(True);
    .set-hexpand(True);
    .set-line-wrap(True);
    #.set-max-width-chars(40);
    .set-justify(GTK_JUSTIFY_FILL);
    .set-halign(GTK_ALIGN_START);
    .set-valign(GTK_ALIGN_START);
    .set-margin-top(6);
    .set-margin-start(2);
  }

  my Gnome::Gtk3::StyleContext $context .= new(
    :native-object($label.get-style-context)
  );
  $context.add-class('labelText');
  $grid.grid-attach( $label, 0, $row, 1, 1);


  # mark required fields with a bold star
  $label-text = [~] ' <b>', $required ?? '*' !! '', '</b> ';
  given $label .= new(:text($label-text)) {
    .set-use-markup(True);
    .set-valign(GTK_ALIGN_START);
    .set-margin-top(6);
  }
  $grid.grid-attach( $label, 1, $row, 1, 1);
}

#-------------------------------------------------------------------------------
method !entry-field (
  Gnome::Gtk3::Grid $kv-grid, Int $grid-row, QAManager::KV $kv
) {

  # A frame with one or more entries
  my QAManager::Gui::Part::EntryFrame $w .= new(
    :widget-name($kv.name), :example($kv.example), :tooltip($kv.tooltip)
    :visibility(!$kv.invisible), :repeatable($kv.repeatable),
    :entry-category($kv.values)
  );

  # select default if any
  $w.set-default($kv.default) if $kv.default;
  $kv-grid.grid-attach( $w, 2, $grid-row, 1, 1);

}

#-------------------------------------------------------------------------------
method !textview-field (
  #Gnome::Gtk3::Grid $kv-grid, Int $grid-row, QAManager::Set $set, Hash $kv
  Gnome::Gtk3::Grid $kv-grid, Int $grid-row, QAManager::KV $kv
) {

  my QAManager::Gui::Part::GroupFrame $frame .= new;
  $kv-grid.grid-attach( $frame, 2, $grid-row, 1, 1);

  my Gnome::Gtk3::TextView $w .= new;
  $frame.container-add($w);

  #$w.set-margin-top(6);
  $w.set-size-request( 1, $kv.height // 50);
  $w.set-name($kv.name);
  $w.set-tooltip-text($kv.tooltip) if ?$kv.tooltip;
  $w.set-wrap-mode(GTK_WRAP_WORD);

#  my Gnome::Gtk3::TextBuffer $tb .= new(:native-object($w.get-buffer));
#  my Str $text = $!user-data{$set.name}{$kv.name} // '';
#  $tb.set-text( $text, $text.chars);

#  $!main-handler.add-widget( $w, $!invoice-title, $set, $kv);
}

#-------------------------------------------------------------------------------
method !combobox-field (
#  Gnome::Gtk3::Grid $kv-grid, Int $grid-row, QAManager::Set $set, Hash $kv
  Gnome::Gtk3::Grid $kv-grid, Int $grid-row, QAManager::KV $kv
) {

  my Gnome::Gtk3::ComboBoxText $w .= new;
  for @($kv.values) -> $cbv {
    $w.append-text($cbv);
  }

  # select default if any
  $w.set-active($kv.values.first( $kv.default, :k)) if ?$kv.default;


#  my Str $v = $!user-data{$set.name}{$kv.name} // Str;
#  if ?$v {
#    my Int $value-index = $kv.values.first( $v, :k) // 0;
#    $w.set-active($value-index);
#  }

  $w.set-margin-top(3);
  $w.set-name($kv.name);
  $w.set-tooltip-text($kv.tooltip) if ?$kv.tooltip;

  $kv-grid.grid-attach( $w, 2, $grid-row, 1, 1);
#  $!main-handler.add-widget( $w, $!invoice-title, $set, $kv);
}

#-------------------------------------------------------------------------------
method !radiobutton-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::KV $kv
) {

  my QAManager::Gui::Part::GroupFrame $frame .= new;
  $set-grid.grid-attach( $frame, 2, $set-row, 1, 1);

  # A series of checkbuttons are stored in a grid
  my Gnome::Gtk3::Grid $g .= new;
  $g.set-name('radiobutton-grid');
  $frame.container-add($g);

  # user data is stored as a hash to make the check more easily
#  my Array $v = $!user-data{$set.name}{$kv.name} // [];
#  my Hash $reversed-v = $v.kv.reverse.hash;

  my Int $rc = 0;
  my Gnome::Gtk3::RadioButton $w1st;
  for @($kv.values) -> $vname {
    my Gnome::Gtk3::RadioButton $w .= new(:label($vname));
#    $w.set-active($reversed-v{$vname}:exists);
    $w.set-name($kv.name);
    $w.set-margin-top(3);
note "RB: $kv.default(), $vname, {($kv.default // '') eq $vname}";
    $w.set-active(True) if ($kv.default // '') eq $vname;
    $w.set-tooltip-text($kv.tooltip) if ?$kv.tooltip;

    $w.join-group($w1st) if ?$w1st;
    $w1st = $w unless ?$w1st;
    $g.grid-attach( $w, 0, $rc++, 1, 1);
  }

#  $!main-handler.add-widget( $g, $!invoice-title, $set, $kv);
}

#-------------------------------------------------------------------------------
method !checkbutton-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::KV $kv
) {

  my QAManager::Gui::Part::GroupFrame $frame .= new;
  $set-grid.grid-attach( $frame, 2, $set-row, 1, 1);

  # A series of checkbuttons are stored in a grid
  my Gnome::Gtk3::Grid $g .= new;
  $g.set-name('checkbutton-grid');
  $frame.container-add($g);

  # user data is stored as a hash to make the check more easily
#  my Array $v = $!user-data{$set.name}{$kv.name} // [];
#  my Hash $reversed-v = $v.kv.reverse.hash;

  my Int $rc = 0;
  for @($kv.values) -> $vname {
    my Gnome::Gtk3::CheckButton $w .= new(:label($vname));
#    $w.set-active($reversed-v{$vname}:exists);
    $w.set-name($kv.name);
    $w.set-margin-top(3);
    $w.set-active(?($kv.default // []).first($vname));
    $w.set-tooltip-text($kv.tooltip) if ?$kv.tooltip;
    $g.grid-attach( $w, 0, $rc++, 1, 1);
  }

#  $!main-handler.add-widget( $g, $!invoice-title, $set, $kv);
}

#-------------------------------------------------------------------------------
method !togglebutton-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::KV $kv
) {

  # user data is stored as a hash to make the check more easily
#  my Array $v = $!user-data{$set.name}{$kv.name} // [];
#  my Hash $reversed-v = $v.kv.reverse.hash;

  my Gnome::Gtk3::ToggleButton $w .= new(
    :label(($kv.values // ['toggle']).join(':'))
  );

  #    $w.set-active($reversed-v{$vname}:exists);
  $w.set-name($kv.name);
  $w.set-margin-top(3);
  $w.set-active(?$kv.default);
  $w.set-tooltip-text($kv.tooltip) if ?$kv.tooltip;
  $set-grid.grid-attach( $w, 2, $set-row, 1, 1);

#  $!main-handler.add-widget( $g, $!invoice-title, $set, $kv);
}

#-------------------------------------------------------------------------------
method !scale-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::KV $kv
) {

  # user data is stored as a hash to make the check more easily
#  my Array $v = $!user-data{$set.name}{$kv.name} // [];
#  my Hash $reversed-v = $v.kv.reverse.hash;

  my Gnome::Gtk3::Scale $w .= new(
    :orientation(GTK_ORIENTATION_HORIZONTAL),
    :min($kv.minimum // 0e0), :max($kv.maximum // 1e2), :step($kv.step // 1e0)
  );

  #    $w.set-active($reversed-v{$vname}:exists);
  $w.set-name($kv.name);
  $w.set-margin-top(3);
  $w.set-draw-value(True);
  $w.set-digits(2);
  $w.set-value($kv.default // $kv.minimum // 0e0);
  $w.set-tooltip-text($kv.tooltip) if ?$kv.tooltip;
  $set-grid.grid-attach( $w, 2, $set-row, 1, 1);

#  $!main-handler.add-widget( $g, $!invoice-title, $set, $kv);
}

#-------------------------------------------------------------------------------
method !switch-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::KV $kv
) {

  # the switch is streched to the full width of the grid cell. this is ugly!
  # to prevent this, create another grid to place the switch in. This is
  # usually enough. here however, the switch must be justified to the right,
  # so place a label in the first cell eating all available space. this will
  # push the switch to the right.
  my Gnome::Gtk3::Grid $g .= new;
  my Gnome::Gtk3::Label $l .= new(:text(''));
  $l.set-hexpand(True);
  $g.grid-attach( $l, 0, 0, 1, 1);

  my Gnome::Gtk3::Switch $w .= new;
#  my Bool $v = $!user-data{$set.name}{$kv.name} // Bool;
  $w.set-active(?$kv.default);
  $w.set-margin-top(3);
  $w.set-name($kv.name);
  $w.set-tooltip-text($kv.tooltip) if ?$kv.tooltip;

  $g.grid-attach( $w, 1, 0, 1, 1);
  $set-grid.grid-attach( $g, 2, $set-row, 1, 1);
#  $!main-handler.add-widget( $w, $!invoice-title, $set, $kv);
}

#-------------------------------------------------------------------------------
method !image-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::KV $kv
) {

  # user data is stored as a hash to make the check more easily
#  my Array $v = $!user-data{$set.name}{$kv.name} // [];
#  my Hash $reversed-v = $v.kv.reverse.hash;

  my QAManager::Gui::Part::GroupFrame $frame .= new;
  $set-grid.grid-attach( $frame, 2, $set-row, 1, 1);

  my Str $file = $kv.default // '';
#  $filename = %?RESOURCES{$filename}.Str unless $filename.IO.r;

  my Int $width = $kv.width // 100;
  my Int $height = $kv.height // 100;
  my Gnome::Gdk3::Pixbuf $pb .= new(:$file, :$width, :$height);
  my Gnome::Gtk3::Image $w .= new;
  $w.set-from-pixbuf($pb);

  #    $w.set-active($reversed-v{$vname}:exists);
  $w.set-name($kv.name);
  $w.set-margin-top(3);
  $w.set-tooltip-text($kv.tooltip) if ?$kv.tooltip;

  $frame.container-add(
    self!field-with-button( self, 'select-image',
    :field-text($file), :field-widget($w)
    )
  );

#  $!main-handler.add-widget( $g, $!invoice-title, $set, $kv);
}

#-------------------------------------------------------------------------------
method !field-with-button (
  Any:D $handler-object, Str:D $handler-method,
  Str :$field-text, :$field-widget?
  --> Gnome::Gtk3::Grid
) {

  my Gnome::Gtk3::Image $w .= new(:filename(%?RESOURCES<Folder.png>.Str));
  my Gnome::Gtk3::ToolButton $tb .= new(:icon($w));
  $tb.register-signal( $handler-object, $handler-method, 'clicked');

  my Gnome::Gtk3::Grid $fwb .= new;
  if ?$field-text {
    my Gnome::Gtk3::Label $l .= new(:text($field-text));
    $l.set-use-markup(True);
#    $l.set-hexpand(True);
    $l.set-line-wrap(True);
    #$l.set-max-width-chars(40);
#    $l.set-justify(GTK_JUSTIFY_FILL);
    $l.set-halign(GTK_ALIGN_START);
    $l.set-valign(GTK_ALIGN_CENTER);

    $fwb.grid-attach( $l, 0, 0, 1, 1);
    $fwb.grid-attach( $tb, 1, 0, 1, 1);
  }

  else {
    $fwb.grid-attach( $tb, 0, 0, 2, 1);
  }

  $fwb.grid-attach( $field-widget, 0, 1, 2, 1) if $field-widget.defined;

  $fwb
}

#-------------------------------------------------------------------------------
method !set-status-hint (
  Gnome::Gtk3::Widget $widget, inputStatusHint $status
) {
  my Gnome::Gtk3::StyleContext $context .= new(
    :native-object($widget.get-style-context)
  );

  # remove classes first
  $context.remove-class('fieldNormal');
  $context.remove-class('fieldOk');
  $context.remove-class('fieldFail');

  # add class depending on status
  if $status ~~ QAStatusNormal {
    $context.add-class('fieldNormal');
  }

  elsif $status ~~ QAStatusOk {
    $context.add-class('fieldOk');
  }

  elsif $status ~~ QAStatusFail {
    $context.add-class('fieldFail');
  }

  else {
  }
}
