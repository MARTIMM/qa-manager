#!/usr/bin/env raku

use v6.d;
use lib '../gnome-gtk3/lib';

use JSON::Fast;

use QAManager;
use QAManager::Category;

#-------------------------------------------------------------------------------

#my Hash $data = %();
#$data = from-json('xbin/data/data.cfg'.IO.slurp) if 'xbin/data/data.cfg'.IO.r;

my QAManager $qa-manager .= new(:user-data-file('data.cfg'));
#my QAManager $qa-manager .= new(
#  :user-data-file('xbin/data/data.cfg'), :use-filename-as-is
#);
#my QAManager $qa-manager .= new;
$qa-manager.load-category('__test-accounting');
$qa-manager.load-category('accounting');

#my Hash $data = $qa-manager.do-invoice;
#note "user data: ", $data.perl;

#$qa-manager.set-user-data($data);


my Hash $bip = $qa-manager.build-invoice-page( 'Name', 'Title', 'Description');
$qa-manager.add-set(
  $bip, $qa-manager.get-category('__test-accounting'), 'credentials'
);

$qa-manager.add-set(
  $bip, $qa-manager.get-category('accounting'), 'profile'
);

my Hash $bip2 = $qa-manager.build-invoice-page(
  'Name2', 'Title2', 'Description2'
);
$qa-manager.add-set(
  $bip2, $qa-manager.get-category('__test-accounting'), 'profile'
);


$qa-manager.run-invoices;
#'xbin/data/data.cfg'.IO.spurt(to-json($data)) if $qa-manager.results-valid;

#note "user data: ", $data.perl;
