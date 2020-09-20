use v6.d;
use Test;

use QAManager::Question;

#-------------------------------------------------------------------------------
my QAManager::Question $q .= new(
  :name<username>, :qa-data(%(:default<mickey>))
);

#-------------------------------------------------------------------------------
subtest 'ISO-Test', {

  isa-ok $q, QAManager::Question;
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  $q.description = 'Username of account';
  $q.required = True;

  my Hash $x = $q.qa-data;
  is $x<description>, 'Username of account', '.description()';
  ok $x<required>, '.required()';
  is $x<default>, 'mickey', '.new()';

#  note $q.qa-data;
}

#-------------------------------------------------------------------------------
done-testing
