#!/usr/bin/env raku

use v6.d;
#use lib '../gnome-gtk3/lib';
#use lib '../gnome-gobject/lib';
#use lib '../gnome-native/lib';

use QAManager;
use QAManager::Category;
#-------------------------------------------------------------------------------
class CheckHandlers {

  method check-username ( Str $username --> Str ) {
note 'check on username';

    ''
  }
}

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
