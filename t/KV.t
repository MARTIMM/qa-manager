use v6.d;
use Test;

use QAManager::KV;

#-------------------------------------------------------------------------------
my QAManager::KV $qa-kv .= new(
  :name<username>, :kv(%(:default<mickey>))
);

#-------------------------------------------------------------------------------
subtest 'ISO-Test', {

  isa-ok $qa-kv, QAManager::KV, 'QA key values';
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  $qa-kv.description = 'Username of account';
  $qa-kv.required = True;

  my Hash $x = $qa-kv.kv-data;
  is $x<description>, 'Username of account', '.description()';
  ok $x<required>, '.required()';
  is $x<default>, 'mickey', '.new()';

#  note $qa-kv.kv-data;
}

#-------------------------------------------------------------------------------
done-testing
