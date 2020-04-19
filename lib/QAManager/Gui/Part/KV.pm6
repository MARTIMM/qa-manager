use v6;

use Gnome::Gtk3::Grid;
use Gnome::Gtk3::Label;
use Gnome::Gtk3::Frame;
use Gnome::Gtk3::Widget;
use Gnome::Gtk3::Enums;
use Gnome::Gtk3::Entry;
use Gnome::Gtk3::TextView;
use Gnome::Gtk3::CheckButton;
use Gnome::Gtk3::ComboBoxText;
use Gnome::Gtk3::Switch;
use Gnome::Gtk3::Image;
use Gnome::Gtk3::StyleContext;

use QAManager::QATypes;
use QAManager::KV;

#-------------------------------------------------------------------------------
=begin pod
Purpose of this part is to display a question in a row on a given grid.
=end pod

unit class QAManager::Gui::Part::KV;


#-------------------------------------------------------------------------------
submethod BUILD (
  Gnome::Gtk3::Grid :$kv-grid, Int :$grid-row, QAManager::KV :$kv
) {

  # place label on the left. the required star is in the middle column.
  self!shape-label(
    $kv-grid, $grid-row, $kv.title, $kv.description, $kv.required
  );

  # and input fields to the right
  given $kv.field {
    when QAEntry {
      self.entry-field( $kv-grid, $grid-row, $kv);
    }

    when QATextView {
      self.textview-field( $kv-grid, $grid-row, $kv);
    }

    when QAComboBox {
      self.combobox-field( $kv-grid, $grid-row, $kv);
    }

    when QARadioButton {
    }

    when QACheckButton {
      self.checkbutton-field( $kv-grid, $grid-row, $kv);
    }

    when QAToggleButton {
    }

    when QAScale {
    }

    when QASwitch {
#      self.switch-field( $kv-grid, $grid-row, $set, $kv);
    }
  }
}

#-------------------------------------------------------------------------------
# on the left side a text label for the input field on the right
# this text must take  the available space pressing fields to the right
method !shape-label (
  Gnome::Gtk3::Grid $grid, Int $row,
  Str $title, Str $description, Bool $required
) {

  my Str $label-text = [~] '<b>', $description // $title, '</b>:';
  my Gnome::Gtk3::Label $l .= new(:text($label-text));
  $l.set-use-markup(True);
  $l.widget-set-hexpand(True);
  $l.set-line-wrap(True);
  #$l.set-max-width-chars(40);
  $l.set-justify(GTK_JUSTIFY_FILL);
  $l.widget-set-halign(GTK_ALIGN_START);
  $l.widget-set-valign(GTK_ALIGN_CENTER);
  my Gnome::Gtk3::StyleContext $context .= new(
    :native-object($l.get-style-context)
  );
  $context.add-class('labelText');
  $grid.grid-attach( $l, 0, $row, 1, 1);

  # mark required fields with a bold star
  $label-text = [~] ' <b>', $required ?? '*' !! '', '</b> ';
  $l .= new(:text($label-text));
  $l.set-use-markup(True);
  $l.widget-set-valign(GTK_ALIGN_CENTER);
  $grid.grid-attach( $l, 1, $row, 1, 1);
}

#`{{
#-------------------------------------------------------------------------------
method text-field (
  Gnome::Gtk3::Grid $kv-grid, Int $grid-row is copy,
  QAManager::Set $set, Hash $kv
#   --> Int
) {

  my Str $text;
#`{{
  # existing entries get a 'x' toolbar button
  if ?$kv<repeatable> {
    my Array $texts = $!user-data{$set.name}{$kv<name>} // [];
    my Int $n-texts = +@$texts;
    loop ( my Int $i = 0; $i < $n-texts; $i++ ) {
      $text = $texts[$i];
      self.shape-text-field(
        $text, $kv, $kv-grid, $grid-row, $!invoice-title, $set
      );

      my Gnome::Gtk3::Image $image .= new(
        :filename(%?RESOURCES<Delete.png>.Str)
      );
      my Gnome::Gtk3::ToolButton $tb .= new(:icon($image));
      $tb.widget-set-name('delete-tb-button');
      $tb.register-signal(
        $!main-handler, 'add-or-delete-grid-row', 'clicked',
        :$!invoice-title, :$set, :$kv
      );
      $kv-grid.grid-attach( $tb, 3, $grid-row, 1, 1);

      $grid-row++;
      $text = Str;
    }
  }

  else {
}}
    $text = $!user-data{$set.name}{$kv<name>} // Str;
#  }

  self.shape-text-field(
    $text, $kv, $kv-grid, $grid-row, $!invoice-title, $set
  );
#`{{
  # last entry gets a '+' toolbar button
  if ?$kv<repeatable> {
    my Gnome::Gtk3::Image $image .= new(:filename(%?RESOURCES<Add.png>.Str));
    my Gnome::Gtk3::ToolButton $tb .= new(:icon($image));
    $tb.widget-set-name('add-tb-button');
    $tb.register-signal(
      $!main-handler, 'add-or-delete-grid-row', 'clicked',
      :$!invoice-title, :$set, :$kv
    );
    $kv-grid.grid-attach( $tb, 3, $grid-row, 1, 1);
  }
}}

  $grid-row
}

#-------------------------------------------------------------------------------
method shape-text-field (
  Str $text, Hash $kv, Gnome::Gtk3::Grid $kv-grid,
  Int $grid-row, Str $!invoice-title#, QAManager::Set $set
) {

  my Gnome::Gtk3::Entry $w .= new;
  $w.set-text($text) if ? $text;

  $w.widget-set-margin-top(3);
  $w.set-size-request( 200, 1);
  $w.widget-set-name($kv<name>);
  $w.set-tooltip-text($kv<tooltip>) if ?$kv<tooltip>;

  $w.set-placeholder-text($kv<example>) if ?$kv<example>;
  $w.set-visibility(!$kv<invisible>);

  $kv-grid.grid-attach( $w, 2, $grid-row, 1, 1);
#  $!main-handler.add-widget( $w, $!invoice-title, $set, $kv);
#  $!main-handler.check-field( $w, $kv);

#  $w.register-signal(
#    $!main-handler, 'check-on-focus-change', 'focus-out-event', :$kv,
#  );
}
}}

#-------------------------------------------------------------------------------
method entry-field (
  Gnome::Gtk3::Grid $kv-grid, Int $grid-row, QAManager::KV $kv
) {

  my Gnome::Gtk3::Entry $w .= new;

  # select default if any
  $w.set-text($kv.default) if ? $kv.default;

  $w.widget-set-margin-top(3);
  $w.set-size-request( 200, 1);
  $w.widget-set-name($kv.name);
  $w.set-tooltip-text($kv.tooltip) if ?$kv.tooltip;

  $w.set-placeholder-text($kv.example) if ?$kv.example;
  $w.set-visibility(!$kv.invisible);

  self.set-status-hint( $w, QAStatusNormal);

  $kv-grid.grid-attach( $w, 2, $grid-row, 1, 1);
}

#-------------------------------------------------------------------------------
method textview-field (
  #Gnome::Gtk3::Grid $kv-grid, Int $grid-row, QAManager::Set $set, Hash $kv
  Gnome::Gtk3::Grid $kv-grid, Int $grid-row, QAManager::KV $kv
) {

  my Gnome::Gtk3::Frame $frame .= new;
  $frame.set-shadow-type(GTK_SHADOW_ETCHED_IN);
  $frame.widget-set-margin-top(3);

  my Gnome::Gtk3::TextView $w .= new;
  $frame.container-add($w);

  #$w.widget-set-margin-top(6);
  $w.set-size-request( 1, $kv.height // 50);
  $w.widget-set-name($kv.name);
  $w.set-tooltip-text($kv.tooltip) if ?$kv.tooltip;
  $w.set-wrap-mode(GTK_WRAP_WORD);

#  my Gnome::Gtk3::TextBuffer $tb .= new(:native-object($w.get-buffer));
#  my Str $text = $!user-data{$set.name}{$kv.name} // '';
#  $tb.set-text( $text, $text.chars);

  $kv-grid.grid-attach( $frame, 2, $grid-row, 1, 1);
#  $!main-handler.add-widget( $w, $!invoice-title, $set, $kv);
}

#-------------------------------------------------------------------------------
method combobox-field (
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

  $w.widget-set-margin-top(3);
  $w.widget-set-name($kv.name);
  $w.set-tooltip-text($kv.tooltip) if ?$kv.tooltip;

  $kv-grid.grid-attach( $w, 2, $grid-row, 1, 1);
#  $!main-handler.add-widget( $w, $!invoice-title, $set, $kv);
}

#-------------------------------------------------------------------------------
method checkbutton-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::KV $kv
) {

  my Gnome::Gtk3::Frame $frame .= new;
  $frame.set-shadow-type(GTK_SHADOW_ETCHED_IN);
  $frame.widget-set-margin-top(3);
  $set-grid.grid-attach( $frame, 2, $set-row, 1, 1);

  # A series of checkbuttons are stored in a grid
  my Gnome::Gtk3::Grid $g .= new;
  $g.widget-set-name('checkbutton-grid');
  $frame.container-add($g);

  # user data is stored as a hash to make the check more easily
#  my Array $v = $!user-data{$set.name}{$kv.name} // [];
#  my Hash $reversed-v = $v.kv.reverse.hash;

  my Int $rc = 0;
  for @($kv.values) -> $vname {
    my Gnome::Gtk3::CheckButton $w .= new(:label($vname));
#    $w.set-active($reversed-v{$vname}:exists);
    $w.widget-set-name($kv.name);
    $w.widget-set-margin-top(3);
    $w.set-tooltip-text($kv.tooltip) if ?$kv.tooltip;
    $g.grid-attach( $w, 0, $rc++, 1, 1);
  }

#  $!main-handler.add-widget( $g, $!invoice-title, $set, $kv);
}

#-------------------------------------------------------------------------------
method set-status-hint (
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
