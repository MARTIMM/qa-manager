#!/usr/bin/env raku
use v6.d;
#use lib '../gnome-gobject/lib';
use lib '../gnome-gtk3/lib';
use QAManager::Gui::Application;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my QAManager::Gui::Application $app .= new(
  :app-id('io.github.martimm.qa'),
#  :flags(G_APPLICATION_HANDLES_OPEN), # +| G_APPLICATION_NON_UNIQUE),
#  :!initialize
);

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
