#!/usr/bin/env raku

use v6.d;
#use lib '../gnome-gtk3/lib';
#use lib '../gnome-gobject/lib';
#use lib '../gnome-native/lib';

use QAManager;
#use QAManager::Category;
#-------------------------------------------------------------------------------
class CheckHandlers {

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  method check-username-msg ( Str :$input, Hash :$kv, Array :$entry --> Str ) {
#note "check msg on username: $input, $kv<required>";
    my Str $markup-message = '';

    if ?$kv<required> and !$input {
      $markup-message = self!msg(
        "Input is required for", $kv<title>, $entry[2], $entry[3]
      );
    }

#note "Error: $markup-message";

    $markup-message
  }

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  method check-username-sts ( Str :$input, Hash :$kv --> Bool ) {

#note "check sts on username: $input, $kv<required>";
    my Bool $error-state = False;
    $error-state = (?$kv<required> and !$input);

    $error-state
  }

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  method check-password-msg ( Str :$input, Hash :$kv, Array :$entry --> Str ) {
#note "check msg on username: $input, $kv<required>";
    my Str $markup-message = '';

    if ?$kv<required> and !$input {
      $markup-message = self!msg(
        "Input is required for", $kv<title>, $entry[2], $entry[3]
      );
    }

#note "Error: $markup-message";

    $markup-message
  }

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  method check-password-sts ( Str :$input, Hash :$kv --> Bool ) {

#note "check sts on username: $input, $kv<required>";
    my Bool $error-state = False;
    $error-state = (?$kv<required> and !$input);

    $error-state
  }

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  method !msg (
    Str $error, Str $title, Str $invoice-title, Str $set-title
    --> Str
  ) {
    "$error field <b>$title\</b> on sheet <b>$invoice-title\</b> and set <b>$set-title\</b>.\n"
  }
}

#-------------------------------------------------------------------------------
my QAManager $qa-manager .= new(:user-data-file('data'));
$qa-manager.set-callback-object(CheckHandlers.new);



$qa-manager.run-invoices;
