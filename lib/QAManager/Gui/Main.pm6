use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::Main:auth<github:MARTIMM>;

use Gnome::Gtk3::Main;
use Gnome::Gtk3::Entry;
use Gnome::Gtk3::TextView;
use Gnome::Gtk3::CheckButton;
use Gnome::Gtk3::RadioButton;

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
method add-widget ( $widget, Str $cat-name, Str $set-name,  Str $field-name ) {

  $!widgets{$cat-name} = %() unless $!widgets{$cat-name}:exists;
  $!widgets{$cat-name}{$set-name} = %()
    unless $!widgets{$cat-name}{$set-name}:exists;
  $!widgets{$cat-name}{$set-name}{$field-name} = %()
    unless $!widgets{$cat-name}{$set-name}{$field-name}:exists;

  $!widgets{$cat-name}{$set-name}{$field-name} = $widget;
}

#-------------------------------------------------------------------------------
method exit-program ( --> Int ) {
  $!main.gtk-main-quit;

  1
}

#-------------------------------------------------------------------------------
method finish-program ( --> Int ) {

#note $!widgets.perl;
#Gnome::N::debug(:on);

  for $!widgets.keys -> $cat-name {
    for $!widgets{$cat-name}.keys -> $set-name {
      for $!widgets{$cat-name}{$set-name}.keys -> $field-name {
        my $w = $!widgets{$cat-name}{$set-name}{$field-name};

        if $w.get-class-name eq 'GtkEntry' {
          my Gnome::Gtk3::Entry $e .= new(:native-object($w));
          $!results{$cat-name}{$set-name}{$field-name} = $e.get-text;
        }

        elsif $w.get-class-name eq 'GtkCheckButton' {
          my Gnome::Gtk3::CheckButton $cb .= new(:native-object($w));
          $!results{$cat-name}{$set-name}{$field-name} = ?$cb.get_active;
        }
      }
    }
  }

  $!results-valid = True;
  $!main.gtk-main-quit;

  1
}

#-------------------------------------------------------------------------------
method cancel-program ( --> Int ) {
  $!main.gtk-main-quit;

  1
}
