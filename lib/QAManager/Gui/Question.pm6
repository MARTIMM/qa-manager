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
use QAManager::Question;
use QAManager::Gui::GroupFrame;
use QAManager::Gui::EntryFrame;

#-------------------------------------------------------------------------------
=begin pod
Purpose of this part is to display a question in a row on a given grid. This line consists of several columns. The first column shows a text posing the question, the second shows an optional star to show that an input is required. Then the third column is used to show the input area which can be one of several types of input like text, combobox or checkbox groups.
=end pod

unit class QAManager::Gui::Question:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
has Hash $!entry-objects = %( );

#-------------------------------------------------------------------------------
#submethod BUILD ( ) { }

#-------------------------------------------------------------------------------
method build-set-fields (
  QAManager::Set $set, Gnome::Gtk3::Grid $question-grid, Int $grid-row is copy
) {
#Gnome::N::debug(:on);

  self!clean-entries;

  my $c := $set.clone;
  for $c -> QAManager::Question $question {

#  for @($set.get-questions) -> QAManager::Question $question {
#note "kv: $question.name(), $question.field()";
    self.build-entry( :$question-grid, :$grid-row, :$question);
    self.check-field( :$question-grid, :$grid-row, :$question);

    $grid-row++;
  }
}

#-------------------------------------------------------------------------------
method set-field-values (
  QAManager::Set $set, Gnome::Gtk3::Grid $question-grid, Int $grid-row is copy,
  Hash $user-data-set-part
) {
note "sv udsp: $user-data-set-part.perl()";

  my $c := $set.clone;
  for $c -> QAManager::Question $question {
#  for @($set.get-questions) -> QAManager::Question $question {
    self.set-value(
      :$question-grid, :$grid-row, :values($user-data-set-part), :$question
    );
    $grid-row++;
  }
}

#-------------------------------------------------------------------------------
method build-entry (
  Gnome::Gtk3::Grid :$question-grid, Int :$grid-row, QAManager::Question :$question
) {

  # place label on the left. the required star is in the middle column.
  self!shape-label(
    $question-grid, $grid-row, $question.title, $question.description,
    $question.required
  );

  # and input fields to the right
  given $question.field {
    when QAEntry {
      self!entry-field( $question-grid, $grid-row, $question);
    }

    when QATextView {
      self!textview-field( $question-grid, $grid-row, $question);
    }

    when QAComboBox {
      self!combobox-field( $question-grid, $grid-row, $question);
    }

    when QARadioButton {
      self!radiobutton-field( $question-grid, $grid-row, $question);
    }

    when QACheckButton {
      self!checkbutton-field( $question-grid, $grid-row, $question);
    }

    when QAToggleButton {
      self!togglebutton-field( $question-grid, $grid-row, $question);
    }

    when QAScale {
      self!scale-field( $question-grid, $grid-row, $question);
    }

    when QASwitch {
      self!switch-field( $question-grid, $grid-row, $question);
    }

    when QAImage {
      self!image-field( $question-grid, $grid-row, $question);
    }
  }
}

#-------------------------------------------------------------------------------
method check-field (
  Gnome::Gtk3::Grid :$question-grid, Int :$grid-row, QAManager::Question :$question
) {
  my $no = $question-grid.get-child-at( 2, $grid-row);
  my Gnome::Gtk3::Widget $w .= new(:native-object($no));

#note "check field, Type: $question.field(), $grid-row, $w.get-name()";
  my Hash $kv = $question.qa-data;
  for $kv.keys.sort -> $key {
#note "  $key";
  }
}

#-------------------------------------------------------------------------------
method set-value (
  Gnome::Gtk3::Grid :$question-grid, Int :$grid-row, Hash :$values,
  QAManager::Question :$question
) {
  my $no = $question-grid.get-child-at( 2, $grid-row);
  my Gnome::Gtk3::Widget $w .= new(:native-object($no));
note "set value, type: $question.field(), $grid-row, $w.get-name()";

#method set-value (
#  $data-key, $data-value, $row, Bool :$overwrite = True, Bool :$last-row
#) {
}

#-------------------------------------------------------------------------------
method select-image ( ) {
note "select image";
}

#-------------------------------------------------------------------------------
method !clean-entries ( ) {
  $!entry-objects = %( );
}

#-------------------------------------------------------------------------------
# on the left side a text label is placed for the input field on the right.
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
  Gnome::Gtk3::Grid $question-grid, Int $grid-row, QAManager::Question $question
) {

  # A frame with one or more entries
#note "KVO vals: $question.perl()";
  my QAManager::Gui::EntryFrame $w .= new(:$question);

  # select default if any
  $w.set-default($question.default) if $question.default;
  $question-grid.grid-attach( $w, 2, $grid-row, 1, 1);

}

#-------------------------------------------------------------------------------
method !textview-field (
  #Gnome::Gtk3::Grid $question-grid, Int $grid-row, QAManager::Set $set, Hash $kv
  Gnome::Gtk3::Grid $question-grid, Int $grid-row, QAManager::Question $question
) {

  my QAManager::Gui::GroupFrame $frame .= new;
  $question-grid.grid-attach( $frame, 2, $grid-row, 1, 1);

  my Gnome::Gtk3::TextView $w .= new;
  $frame.container-add($w);

  #$w.set-margin-top(6);
  $w.set-size-request( 1, $question.height // 50);
  $w.set-name($question.name);
  $w.set-tooltip-text($question.tooltip) if ?$question.tooltip;
  $w.set-wrap-mode(GTK_WRAP_WORD);

#  my Gnome::Gtk3::TextBuffer $tb .= new(:native-object($w.get-buffer));
#  my Str $text = $!user-data{$set.name}{$question.name} // '';
#  $tb.set-text( $text, $text.chars);

#  $!main-handler.add-widget( $w, $!invoice-title, $set, $question);
}

#-------------------------------------------------------------------------------
method !combobox-field (
#  Gnome::Gtk3::Grid $question-grid, Int $grid-row, QAManager::Set $set, Hash $kv
  Gnome::Gtk3::Grid $question-grid, Int $grid-row, QAManager::Question $question
) {

  my Gnome::Gtk3::ComboBoxText $w .= new;
  for @($question.values) -> $cbv {
    $w.append-text($cbv);
  }

  # select default if any
  $w.set-active($question.values.first( $question.default, :k))
    if ?$question.default;


#  my Str $v = $!user-data{$set.name}{$question.name} // Str;
#  if ?$v {
#    my Int $value-index = $question.values.first( $v, :k) // 0;
#    $w.set-active($value-index);
#  }

  $w.set-margin-top(3);
  $w.set-name($question.name);
  $w.set-tooltip-text($question.tooltip) if ?$question.tooltip;

  $question-grid.grid-attach( $w, 2, $grid-row, 1, 1);
#  $!main-handler.add-widget( $w, $!invoice-title, $set, $question);
}

#-------------------------------------------------------------------------------
method !radiobutton-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::Question $question
) {

  my QAManager::Gui::GroupFrame $frame .= new;
  $set-grid.grid-attach( $frame, 2, $set-row, 1, 1);

  # A series of checkbuttons are stored in a grid
  my Gnome::Gtk3::Grid $g .= new;
  $g.set-name('radiobutton-grid');
  $frame.container-add($g);

  # user data is stored as a hash to make the check more easily
#  my Array $v = $!user-data{$set.name}{$question.name} // [];
#  my Hash $reversed-v = $v.kv.reverse.hash;

  my Int $rc = 0;
  my Gnome::Gtk3::RadioButton $w1st;
  for @($question.values) -> $vname {
    my Gnome::Gtk3::RadioButton $w .= new(:label($vname));
#    $w.set-active($reversed-v{$vname}:exists);
    $w.set-name($question.name);
    $w.set-margin-top(3);
note "RB: $question.default(), $vname, {($question.default // '') eq $vname}";
    $w.set-active(True) if ($question.default // '') eq $vname;
    $w.set-tooltip-text($question.tooltip) if ?$question.tooltip;

    $w.join-group($w1st) if ?$w1st;
    $w1st = $w unless ?$w1st;
    $g.grid-attach( $w, 0, $rc++, 1, 1);
  }

#  $!main-handler.add-widget( $g, $!invoice-title, $set, $question);
}

#-------------------------------------------------------------------------------
method !checkbutton-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::Question $question
) {

  my QAManager::Gui::GroupFrame $frame .= new;
  $set-grid.grid-attach( $frame, 2, $set-row, 1, 1);

  # A series of checkbuttons are stored in a grid
  my Gnome::Gtk3::Grid $g .= new;
  $g.set-name('checkbutton-grid');
  $frame.container-add($g);

  # user data is stored as a hash to make the check more easily
#  my Array $v = $!user-data{$set.name}{$question.name} // [];
#  my Hash $reversed-v = $v.kv.reverse.hash;

  my Int $rc = 0;
  for @($question.values) -> $vname {
    my Gnome::Gtk3::CheckButton $w .= new(:label($vname));
#    $w.set-active($reversed-v{$vname}:exists);
    $w.set-name($question.name);
    $w.set-margin-top(3);
    $w.set-active(?($question.default // []).first($vname));
    $w.set-tooltip-text($question.tooltip) if ?$question.tooltip;
    $g.grid-attach( $w, 0, $rc++, 1, 1);
  }

#  $!main-handler.add-widget( $g, $!invoice-title, $set, $question);
}

#-------------------------------------------------------------------------------
method !togglebutton-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::Question $question
) {

  # user data is stored as a hash to make the check more easily
#  my Array $v = $!user-data{$set.name}{$question.name} // [];
#  my Hash $reversed-v = $v.kv.reverse.hash;

  my Gnome::Gtk3::ToggleButton $w .= new(
    :label(($question.values // ['toggle']).join(':'))
  );

  #    $w.set-active($reversed-v{$vname}:exists);
  $w.set-name($question.name);
  $w.set-margin-top(3);
  $w.set-active(?$question.default);
  $w.set-tooltip-text($question.tooltip) if ?$question.tooltip;
  $set-grid.grid-attach( $w, 2, $set-row, 1, 1);

#  $!main-handler.add-widget( $g, $!invoice-title, $set, $question);
}

#-------------------------------------------------------------------------------
method !scale-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::Question $question
) {

  # user data is stored as a hash to make the check more easily
#  my Array $v = $!user-data{$set.name}{$question.name} // [];
#  my Hash $reversed-v = $v.kv.reverse.hash;

  my Gnome::Gtk3::Scale $w .= new(
    :orientation(GTK_ORIENTATION_HORIZONTAL),
    :min($question.minimum // 0e0), :max($question.maximum // 1e2),
    :step($question.step // 1e0)
  );

  #    $w.set-active($reversed-v{$vname}:exists);
  $w.set-name($question.name);
  $w.set-margin-top(3);
  $w.set-draw-value(True);
  $w.set-digits(2);
  $w.set-value($question.default // $question.minimum // 0e0);
  $w.set-tooltip-text($question.tooltip) if ?$question.tooltip;
  $set-grid.grid-attach( $w, 2, $set-row, 1, 1);

#  $!main-handler.add-widget( $g, $!invoice-title, $set, $question);
}

#-------------------------------------------------------------------------------
method !switch-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::Question $question
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
#  my Bool $v = $!user-data{$set.name}{$question.name} // Bool;
  $w.set-active(?$question.default);
  $w.set-margin-top(3);
  $w.set-name($question.name);
  $w.set-tooltip-text($question.tooltip) if ?$question.tooltip;

  $g.grid-attach( $w, 1, 0, 1, 1);
  $set-grid.grid-attach( $g, 2, $set-row, 1, 1);
#  $!main-handler.add-widget( $w, $!invoice-title, $set, $question);
}

#-------------------------------------------------------------------------------
method !image-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::Question $question
) {

  # user data is stored as a hash to make the check more easily
#  my Array $v = $!user-data{$set.name}{$question.name} // [];
#  my Hash $reversed-v = $v.kv.reverse.hash;

  my QAManager::Gui::GroupFrame $frame .= new;
  $set-grid.grid-attach( $frame, 2, $set-row, 1, 1);

  my Str $file = $question.default // '';
#  $filename = %?RESOURCES{$filename}.Str unless $filename.IO.r;

  my Int $width = $question.width // 100;
  my Int $height = $question.height // 100;
  my Gnome::Gdk3::Pixbuf $pb .= new(:$file, :$width, :$height);
  my Gnome::Gtk3::Image $w .= new;
  $w.set-from-pixbuf($pb);

  #    $w.set-active($reversed-v{$vname}:exists);
  $w.set-name($question.name);
  $w.set-margin-top(3);
  $w.set-tooltip-text($question.tooltip) if ?$question.tooltip;

  $frame.container-add(
    self!field-with-button( self, 'select-image',
    :field-text($file), :field-widget($w)
    )
  );

#  $!main-handler.add-widget( $g, $!invoice-title, $set, $question);
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
