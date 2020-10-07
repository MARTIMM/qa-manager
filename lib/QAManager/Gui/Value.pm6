use v6.d;

use Gnome::Gdk3::Events;

#use Gnome::Gtk3::Widget;
#use Gnome::Gtk3::ComboBoxText;
use Gnome::Gtk3::StyleContext;
use Gnome::Gtk3::Grid;
use Gnome::Gtk3::Image;
use Gnome::Gtk3::ToolButton;
use Gnome::Gtk3::Enums;
use Gnome::Gtk3::ComboBoxText;
use Gnome::Gtk3::ToolButton;

use QAManager::Gui::Frame;
use QAManager::QATypes;
use QAManager::Question;

use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
=begin pod

=end pod

unit role QAManager::Gui::Value:auth<github:MARTIMM>;
also is QAManager::Gui::Frame;

#-------------------------------------------------------------------------------
has Gnome::Gtk3::Grid $!grid;
has QAManager::Question $!question;

has Str $!widget-name;

has Array $!values;
has Hash $!user-data-set-part;
has Array $!input-widgets;

#-------------------------------------------------------------------------------
method initialize ( ) {

  # clear values
  $!input-widgets = []; #Array[Gnome::Gtk3::Entry].new;
  $!values = [];

  $!widget-name = $!question.name;

  # make frame invisible if not repeatable
  self.set-shadow-type(GTK_SHADOW_NONE) unless ?$!question.repeatable;

  # fiddle a bit
#  self.widget-set-margin-top(3);
#  self.set-size-request( 200, 1);
  self.widget-set-name($!widget-name);
  self.widget-set-hexpand(True);

  # add a grid to the frame. a grid is used to cope with repeatable values.
  # the input fields are placed under each other in one column. furthermore,
  # a pulldown can be shown when the input can be categorized.
  $!grid .= new;
  self.container-add($!grid);
  self!create-input-row(0);

  self!set-values;
}

#-------------------------------------------------------------------------------
method !create-input-row ( Int $row ) {

  given my $input-widget = self.create-widget("$!widget-name:$row") {

    my Str $tooltip = $!question.tooltip;
    .set-tooltip-text($tooltip) if ?$tooltip;

    .register-signal(
      self, 'check-on-focus-change', 'focus-out-event', :iw($input-widget)
    );
  }

note "W: $row, $input-widget.get-name()";
  $!grid.grid-attach( $input-widget, QAInputColumn, $row, 1, 1);
  $!input-widgets[$row] = $input-widget;

  # add a + button to the right when repeatable is set True
  if $!question.repeatable {
    my Gnome::Gtk3::ToolButton $tb = self!create-toolbutton;
    $!grid.grid-attach( $tb, QAButtonColumn, $row, 1, 1);
  }

  # create comboxes on the left when selectlist is a non-empty Array
  #if $!question.selectlist {
  #}

  $!grid.show-all;
}

#-------------------------------------------------------------------------------
method !set-values ( ) {

  # check if the value is an array
  my $v = $!user-data-set-part{$!question.name};
  my @values = $v ~~ Array ?? @$v !! ($v);

  for @$!input-widgets -> $input-widget {
    #my Str $widget-name = $input-widget.get-name;
    self.set-value( $input-widget, @values.shift);
  }
}

#-------------------------------------------------------------------------------
method !create-toolbutton ( --> Gnome::Gtk3::ToolButton ) {

  my Gnome::Gtk3::Image $image .= new;
  $image.set-from-icon-name( 'list-add', GTK_ICON_SIZE_BUTTON);

  my Gnome::Gtk3::ToolButton $tb .= new(:icon($image));
  $tb.register-signal( self, 'add-row', 'clicked');

  $tb
}

#-------------------------------------------------------------------------------
method !set-status-hint ( $widget, InputStatusHint $status ) {
  my Gnome::Gtk3::StyleContext $context .= new(
    :native-object($widget.get-style-context)
  );

  # remove classes first
  $context.remove-class('dontcare');
  $context.remove-class('fieldOk');
  $context.remove-class('fieldFail');

note "Status of '$widget.get-name()': {InputStatusHint($status)}";
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

#-------------------------------------------------------------------------------
method !adjust-user-data ( $w, $input ) {

  my Str ( $widget-name, $row) = $w.get-name.split(':');
  if ? $!question.repeatable {
    #if $!$!question.selectlist {
    #}
    $!user-data-set-part{$widget-name}[$row] = $input;
  }

  else {
    $!user-data-set-part{$widget-name} = $input;
  }
}

#-------------------------------------------------------------------------------
#--[ Abstract Methods ]---------------------------------------------------------
#-------------------------------------------------------------------------------
# no typing of $data-key and $data-value because data can be any
# of text-, number- or boolean
#method set-value ( $data-key, $data-value, Int $row, Bool :$overwrite ) {
#method set-value ( Any:D $values ) {
method set-value ( Any:D $widget, Any:D $value ) {
  ...
}

#-------------------------------------------------------------------------------
# no typing for return value because it can be a single value, an Array of
# single values or and Array of Pairs.
method get-value ( $widget --> Any ) {
  ...
}

#-------------------------------------------------------------------------------
method create-widget ( Str $widget-name --> Any ) {
  ...
}

#-------------------------------------------------------------------------------
#--[ Signal Handlers ]----------------------------------------------------------
#-------------------------------------------------------------------------------
method add-row (
  Gnome::Gtk3::ToolButton :_widget($toolbutton), Int :$_handler-id,
  :iw($input-widget)
) {
note "AR: ", $input-widget.perl;

  # modify this buttons icon and signal handler
  my Gnome::Gtk3::Image $image .= new;
  $image.set-from-icon-name( 'list-remove', GTK_ICON_SIZE_BUTTON);
  $toolbutton.set-icon-widget($image);
  $toolbutton.handler-disconnect($_handler-id);
  $toolbutton.register-signal(
    self, 'delete-row', 'clicked', :iw($input-widget)
  );

  # create a new row
  self!create-input-row($!input-widgets.elems);
}

#-------------------------------------------------------------------------------
method delete-row (
  Gnome::Gtk3::ToolButton :_widget($toolbutton), Int :$_handler-id,
  :iw($input-widget)
) {

note "DR: ", $input-widget.perl;

  # delete a row using the name of the toolbutton, see also rename-buttons().
  my Str ( $n, $r) = $input-widget.get-name.split(':');
  my Int $row;
  $row = $r.Int;
  $!grid.remove-row($row);
  $!input-widgets.splice( $row, 1);

  $row = 0;
  for @$!input-widgets -> $iw {
    $iw.set-name("$!widget-name:$row");
    $row++;
  }
}

#-------------------------------------------------------------------------------
method check-on-focus-change ( N-GdkEventFocus $event, :_widget($w) --> Int ) {

#note 'focus change';
  my $input = self.get-value($w);

  my Bool $faulty-state;
#`{{
  my Str $cb-name = ($!callback-name // '_') ~ '-sts';
  if ?$*callback-object and $*callback-object.^can($cb-name) {
    $faulty-state = $*callback-object."$cb-name"( :$input, :$kv);
  }

  else {
    $faulty-state = (?$kv<required> and !$input);
  }
}}
  $faulty-state = (?$!question.required and !$input);

  if $faulty-state {
    self!set-status-hint( $w, QAStatusFail);
  }

  elsif ? $!question.required {
    self!set-status-hint( $w, QAStatusOk);
    self!adjust-user-data( $w, $input);
  }

  else {
    self!set-status-hint( $w, QAStatusNormal);
    self!adjust-user-data( $w, $input);
  }


  # must propogate further to prevent messages when notebook page is switched
  # otherwise it would do ok to return 1.
  0
}





=finish

#-------------------------------------------------------------------------------
method check-value ( ) {
  ...
}

#-------------------------------------------------------------------------------
method get-values ( --> Array ) {
  ...
}

#-------------------------------------------------------------------------------
method set-values ( Array $data-array, Bool :$overwrite = True ) {
  my Int $row = 0;
  for @$data-array -> $t {
    my ( $data-key, $data-value) = $t.kv;
#note 'svs: ', $data-key//'--dk--', ', ', $data-value//'--dv--';
    self.set-value(
      $data-key // 0, $data-value // '', $row, :$overwrite,
      :last-row( ($row + 1) == $data-array.elems )
    );

    $row++;
  }
}

#-------------------------------------------------------------------------------
# when called, at least one row is visible. only first row will be
# set with a default unless field is already filled in.
# subsequent calls to fill data from user configs, will overwrite the content.
method set-default ( $t ) {
  my ( $data-key, $data-value) = $t.kv;
  self.set-value( $data-key, $data-value, 0, :!overwrite, :last-row);
}
