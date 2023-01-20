#!/usr/bin/env raku

use v6.d;

use QAManager::Category;

#-------------------------------------------------------------------------------
my QAManager::Category $cat .= new(:category<__test-accounting>);
$cat.save-as('__test2');
