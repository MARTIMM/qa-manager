use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::Main:auth<github:MARTIMM>;

use QATypes;
use QAManager::Set;

use Gnome::Gdk3::Events;
use Gnome::Gtk3::Enums;
use Gnome::Gtk3::Main;
use Gnome::Gtk3::Widget;
use Gnome::Gtk3::Window;
use Gnome::Gtk3::Entry;
use Gnome::Gtk3::Grid;
use Gnome::Gtk3::ToolButton;
use Gnome::Gtk3::Image;
use Gnome::Gtk3::TextView;
use Gnome::Gtk3::CheckButton;
use Gnome::Gtk3::RadioButton;
use Gnome::Gtk3::StyleContext;
use Gnome::Gtk3::MessageDialog;

use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
has Gnome::Gtk3::Main $!main;
has Hash $!widgets;
has Hash $.results;
has Bool $.results-valid;
has Gnome::Gtk3::Window $!toplevel-window;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  $!main .= new;
  $!results = %();
  $!widgets = %();
  $!results-valid = False;
}

#-------------------------------------------------------------------------------
method set-toplevel-window ( Gnome::Gtk3::Window $!toplevel-window ) { }

#-------------------------------------------------------------------------------
method add-widget (
  $widget, Str $invoice-title, Str $cat-name, QAManager::Set $set,
  Hash $field-specs
) {

  my Str $field-name = $field-specs<name>;
  my Str $set-name = $set.name;

  $!widgets{$cat-name} = %() unless $!widgets{$cat-name}:exists;

  $!widgets{$cat-name}{$set-name} = %()
    unless $!widgets{$cat-name}{$set-name}:exists;

  # an array of entry info tupples are stored. an array is used to cope
  # with those fields which can be repeatable.
  $!widgets{$cat-name}{$set-name}{$field-name} = []
    unless $!widgets{$cat-name}{$set-name}{$field-name}:exists;

  $!widgets{$cat-name}{$set-name}{$field-name}.push: [
    $widget, $field-specs, $invoice-title, $set.title
  ];
}

#-------------------------------------------------------------------------------
method set-status-hint (
  Gnome::Gtk3::Widget $widget, inputStatusHint $status
) {
  my Gnome::Gtk3::StyleContext $context .= new(
    :native-object($widget.get-style-context)
  );

  # remove classes first
  $context.remove-class('dontcare');
  $context.remove-class('fieldOk');
  $context.remove-class('fieldFail');

  # add class depending on status
  if $status ~~ QADontCare {
    $context.add-class('dontcare');
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
method check-field ( $w, Hash $field-spec ) {

  note "check $field-spec<name> field";

  if $w.get-class-name eq 'GtkEntry' {
    my Gnome::Gtk3::Entry $e .= new(:native-object($w));
    my Str $txt = $e.get-text;
    $txt = $field-spec<default> // Str unless ?$txt;

    if ?$field-spec<required> and ! $txt {
      self.set-status-hint( $e, QAStatusFail);
    }

    else {
      self.set-status-hint( $e, QAStatusOk);
    }
  }
}

#-------------------------------------------------------------------------------
method exit-program ( --> Int ) {
  $!results-valid = False;
  $!main.gtk-main-quit;

  1
}

#-------------------------------------------------------------------------------
method finish-program ( --> Int ) {

#note $!widgets.perl;
#Gnome::N::debug(:on);
  my Bool $data-ok = True;
  my Str $markup-message = '';

  for $!widgets.keys -> $cat-name {
note "cat: $cat-name";
    for $!widgets{$cat-name}.keys -> $set-name {
note "set: $set-name";
      for $!widgets{$cat-name}{$set-name}.keys -> $field-name {
        my Array $widget-spec = $!widgets{$cat-name}{$set-name}{$field-name};
note "field: $field-name";

        my Array $entries = $widget-spec;
        for @$entries -> $entry {
          my $w = $entry[0];
          my Hash $field-spec = $entry[1];

          if $w.get-class-name eq 'GtkEntry' {

            # get text from input field
            my Str $txt = $w.get-text;

            # use default if there is no text input
            $txt = $field-spec<default> // Str unless ?$txt;

            if ?$field-spec<repeatable> {
              if ? $txt {
                $!results{$cat-name}{$set-name}{$field-name} = []
                  unless ?$!results{$cat-name}{$set-name}{$field-name};
                $!results{$cat-name}{$set-name}{$field-name}.push($txt);
              }
            }

            else {
              # check if input is required
              if ?$field-spec<required> and !$txt {
                my Str $invoice-title = $entry[2];
                my Str $set-title = $entry[3];

                $data-ok = False;
                $markup-message ~= "Field <b>$field-spec<title>\</b> on sheet <b>$invoice-title\</b> and set <b>$set-title\</b> is required.\n";
              }

              elsif ?$txt {
                $!results{$cat-name}{$set-name}{$field-name} = $txt;
              }
            }
          }

          elsif $w.get-class-name eq 'GtkCheckButton' {
            $!results{$cat-name}{$set-name}{$field-name} = ? $w.get_active;
          }
        }
      }
    }
  }

  if $data-ok {
    $!results-valid = True;
    $!main.gtk-main-quit;
  }

  else {
    # display warning, show in color or other hints that input is not
    # correct or absent
    my Gnome::Gtk3::MessageDialog $md;
    if ?$markup-message {
      $md .= new( :$markup-message, :parent($!toplevel-window));
      $md.dialog-run;
      $md.gtk_widget_destroy;
    }
  }

  1
}

#-------------------------------------------------------------------------------
method check-on-focus-change (
  GdkEventFocus $event, :widget($w), Hash :$field-spec
  --> Int
) {
#Gnome::N::debug(:on);

  self.check-field( $w, $field-spec);

  # must propogate further to prevent messages when notebook page is switched
  # otherwise it would do ok to return 1.
  0
}

#-------------------------------------------------------------------------------
method add-or-delete-grid-row (
  :widget($toolbar-button), Gnome::Gtk3::Grid :$grid,
  Str :$invoice-title, Str :$cat-name, QAManager::Set :$set, Hash :$kv
  --> Int
) {
Gnome::N::debug(:on);

  my Bool $add = $toolbar-button.widget-get-name eq 'add-tb-button';
  my Gnome::Gtk3::Image $image .= new(
    :native-object($toolbar-button.get-icon-widget)
  );
  $image.image-clear;

  if $add {
    note "Row add in grid";
    $image.set-from-file(%?RESOURCES<Delete.png>.Str);
    $toolbar-button.widget-set-name('delete-tb-button');

    # add a row in the grid below the one where this button resides
    $image .= new(:filename(%?RESOURCES<Add.png>.Str));
    my Gnome::Gtk3::ToolButton $tb .= new(:icon($image));
    $tb.widget-set-name('add-tb-button');
    $tb.register-signal(
      self, 'add-or-delete-grid-row', 'clicked', :$grid,
      :$invoice-title, :$cat-name, :$set, :$kv
    );

    $grid.grid-insert-next-to( $toolbar-button, GTK_POS_BOTTOM);
    $grid.grid-attach-next-to( $tb, $toolbar-button, GTK_POS_BOTTOM, 1, 1);

    self.shape-entry(
      $grid, $invoice-title, $cat-name, $set, $kv, :sibling($tb),
      :pos(GTK_POS_LEFT)
    );
    $grid.show-all;
  }

  else {
    note "Row delete in grid";
    $image.set-from-file(%?RESOURCES<Add.png>.Str);
    $toolbar-button.widget-set-name('add-tb-button');
  }

  1
}

#-------------------------------------------------------------------------------
method shape-entry (
  Gnome::Gtk3::Grid:D $grid,
  Str $invoice-title, Str $cat-name, QAManager::Set:D $set, Hash:D $kv,
  Str :$text = '', Int :$set-row, Gnome::GObject::Object :$sibling,
  GtkPositionType :$pos = GTK_POS_RIGHT
) {

  my Gnome::Gtk3::Entry $w .= new;
  $w.set-text($text) if ? $text;

  $w.widget-set-margin-top(3);
  $w.widget-set-name($kv<name>);
  $w.set-tooltip-text($kv<tooltip>) if ?$kv<tooltip>;

  $w.set-placeholder-text($kv<example>) if ?$kv<example>;
  $w.set-visibility(!$kv<invisible>);

  if $set-row.defined {
    $grid.grid-attach( $w, 2, $set-row, 1, 1);
  }

  elsif $sibling.defined {
    $grid.grid-attach-next-to( $w, $sibling, $pos, 1, 1);
  }

  self.add-widget( $w, $invoice-title, $cat-name, $set, $kv);
  self.check-field( $w, $kv);

  $w.register-signal(
    self, 'check-on-focus-change', 'focus-out-event',
    :field-spec($kv),
  );
}

#-------------------------------------------------------------------------------
method cancel-program ( --> Int ) {
  $!results-valid = False;
  $!main.gtk-main-quit;

  1
}
