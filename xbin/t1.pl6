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
#  method check-username-msg ( Str :$input, Hash :$kv, Array :$entry --> Str ) {
  method check-username (
    Str :$input, Hash :$kv, Array :$entry, Bool :$check-only --> Str
  ) {
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
my QAManager $qa-manager .= new;
my Hash $data = $qa-manager.run-invoice(
  :sheet<__QASheet1>, :callback-handlers(CheckHandlers.new),
  :result-file<data-2>, :save, :json
);











=finish
#-------------------------------------------------------------------------------
my QAManager $qa-manager .= new(:user-data-file('data'));
$qa-manager.set-callback-object(CheckHandlers.new);

$qa-manager.load-category('__test-accounting');
#$qa-manager.load-category('xxx');

my Hash $bip1 = $qa-manager.build-invoice-page( 'Name', 'Title',
 'Description jzh glfksd slfdjg sdfgl jsfdg lsdfg jhsdlfgj sdfg lsdkj sdgljshdfg ls dfj sdf glsjfdg sdflg ksdlfgj sdfg sdflkhsdf gsdfkggh ');
#`{{}}
$qa-manager.add-set(
  $bip1, $qa-manager.get-category('__test-accounting'), 'credentials'
);
$qa-manager.add-set(
  $bip1, $qa-manager.get-category('__test-accounting'), 'profile'
);

#`{{
$qa-manager.add-set(
  $bip1, $qa-manager.get-category('xxx'), 'xxx'
);

$qa-manager.add-set(
  $bip1, $qa-manager.get-category('yyy'), 'yyy'
);
}}

$qa-manager.run-invoices;
