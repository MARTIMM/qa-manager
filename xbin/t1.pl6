#!/usr/bin/env raku

use v6.d;
use lib '../gnome-gtk3/lib';

use QAManager;
use QAManager::Category;

#-------------------------------------------------------------------------------
my QAManager $qa-manager .= new;

$qa-manager.load-category('accounting');
$qa-manager.load-category('__test-accounting');
my Hash $data = $qa-manager.do-invoice;

note "user data: ", $data.perl;
