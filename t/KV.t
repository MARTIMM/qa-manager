use v6.d;
use Test;

use QAManager::KV;

#-------------------------------------------------------------------------------
my QAManager::KV $qa-kv .= new(
  :name<username>, :kv(%(:default<micky>))
);

#-------------------------------------------------------------------------------
subtest 'ISO-Test', {

  isa-ok $qa-kv, QAManager::KV, 'QA key values';
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  $qa-kv.description = 'Username of account';
  $qa-kv.required = True;

  note $qa-kv.kv;
}

#-------------------------------------------------------------------------------
done-testing
