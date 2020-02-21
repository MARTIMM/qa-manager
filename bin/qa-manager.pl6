#!/usr/bin/env raku

use v6.d;

=finish


#use lib '../gnome-gtk3/lib';
#use lib '../gnome-gobject/lib';
#use lib '../gnome-native/lib';

use QAManager;
use QAManager::Category;

#-------------------------------------------------------------------------------
my QAManager $qa-manager .= new(:user-data-file('xyz'));
note 'Manager sheet loaded: ', $qa-manager.load-category(:QAManager);

my Hash $bip1 = $qa-manager.build-invoice-page(
  'QA Manager', 'Main', 'Main sheet definitions'
);
$qa-manager.add-set( $bip1, $qa-manager.get-category, 'sheetname');
$qa-manager.add-set( $bip1, $qa-manager.get-category, 'setname');

$qa-manager.run-invoices;
