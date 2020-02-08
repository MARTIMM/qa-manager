use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::Main:auth<github:MARTIMM>;

use QATypes;

use Gnome::Gdk3::Events;
use Gnome::Gtk3::Main;
use Gnome::Gtk3::Widget;
use Gnome::Gtk3::Entry;
use Gnome::Gtk3::TextView;
use Gnome::Gtk3::CheckButton;
use Gnome::Gtk3::RadioButton;
use Gnome::Gtk3::StyleContext;

use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
has Gnome::Gtk3::Main $!main;
has Hash $!widgets;
has Hash $.results;
has Bool $.results-valid;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  $!main .= new;
  $!results = %();
  $!widgets = %();
  $!results-valid = False;
}

#-------------------------------------------------------------------------------
method add-widget ( $widget, Str $cat-name, Str $set-name, Hash $field-specs ) {

  my Str $field-name = $field-specs<name>;

  $!widgets{$cat-name} = %() unless $!widgets{$cat-name}:exists;
  $!widgets{$cat-name}{$set-name} = %()
    unless $!widgets{$cat-name}{$set-name}:exists;
  $!widgets{$cat-name}{$set-name}{$field-name} = %()
    unless $!widgets{$cat-name}{$set-name}{$field-name}:exists;

  $!widgets{$cat-name}{$set-name}{$field-name} = [ $widget, $field-specs];
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

  for $!widgets.keys -> $cat-name {
note "cat: $cat-name";
    for $!widgets{$cat-name}.keys -> $set-name {
note "set: $set-name";
      for $!widgets{$cat-name}{$set-name}.keys -> $field-name {
note "field: $field-name";
        my $w = $!widgets{$cat-name}{$set-name}{$field-name}[0];
        my Hash $field-spec = $!widgets{$cat-name}{$set-name}{$field-name}[1];

        if $w.get-class-name eq 'GtkEntry' {
          my Gnome::Gtk3::Entry $e .= new(:native-object($w));
          my Str $txt = $e.get-text;
          $txt = $field-spec<default> // Str unless ?$txt;

          if ?$field-spec<required> and !$txt {
#            self.set-status-hint( $e, QAStatusFail);
            $data-ok = False;
          }

          else {
#            self.set-status-hint( $e, QAStatusOk);
            $!results{$cat-name}{$set-name}{$field-name} = $txt;
          }
#`{{
          elsif ?$field-spec<required> {
            $data-ok = False;
            self.set-status-hint( $e, QAStatusFail);
          }

          else {
            self.set-status-hint( $e, QADontCare);
          }
}}
        }

        elsif $w.get-class-name eq 'GtkCheckButton' {
          my Gnome::Gtk3::CheckButton $cb .= new(:native-object($w));
          $!results{$cat-name}{$set-name}{$field-name} = ?$cb.get_active;
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
  }

  1
}

#-------------------------------------------------------------------------------
method check-on-focus-change (
  GdkEventFocus $event, :widget($w), Hash :$field-spec
  --> Int
) {
#  note "focus in/out of $field-spec<name>: ", $w.get-class-name;

  self.check-field( $w, $field-spec);

  # must propogate further to prevent messages when notebook page is switched
  # otherwise it would do ok to return 1.
  0
}

#-------------------------------------------------------------------------------
method add-grid-row ( :$widget ) {
  note "Row add in grid";
}

#-------------------------------------------------------------------------------
method delete-grid-row ( :$widget ) {
  note "Row delete in grid";
}

#-------------------------------------------------------------------------------
method cancel-program ( --> Int ) {
  $!results-valid = False;
  $!main.gtk-main-quit;

  1
}
