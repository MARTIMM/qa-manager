use v6.d;
use lib './lib';

use QAManager::Set;
use QAManager::Question;
use QAManager::Category;
use QAManager::QATypes;

unit class Build;

method build( Str $dist-path --> Int ) {

  note "dist path: $dist-path";
  note "R: \n  ", './resources'.IO.dir>>.Str.join("\n  ");

  1;
}
