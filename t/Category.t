use v6.d;
use Test;

use QAManager;
use QAManager::Set;
use QAManager::KV;
use QAManager::Category;

#-------------------------------------------------------------------------------
my QAManager::Category $test2-cat .= new(:category('test2'));
#-------------------------------------------------------------------------------
subtest 'ISO-Test', {

  isa-ok $test2-cat, QAManager::Category, 'QA Manager category';
  ok $test2-cat.is-loaded, '.is-loaded()';
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {

  $test2-cat.title = 'Accounting';
  $test2-cat.description = 'QA forms about credentials';

  my QAManager::Set $creds .= new(:name<credentials>);
  is $creds.title, 'Credentials', '.title()';
  $creds.description = 'Name and password for account';

  my QAManager::KV $kv .= new(:name<username>);
  $kv.description = 'Username of account';
  $kv.required = True;
#  $creds.add-kv($kv);

  $kv .= new(:name<password>);
  $kv.description = 'Password for username';
  $kv.required = True;
  $kv.encode = True;
  $kv.stars = True;
#  $creds.add-kv($kv);

#  $test2-cat.add-set($creds);

  ok $test2-cat.save, '.save()';
#note "TD: $test2-cat.title(), $test2-cat.description()";

  my QAManager::Category $test2-cat2 .= new(:category('test2'));
  nok $test2-cat2.is-loaded, '2nd time not loaded';
  $test2-cat.purge;
  nok $test2-cat2.remove, 'after purge no category';
  $test2-cat2 .= new(:category('test2'));
  ok $test2-cat2.is-loaded, 'now loaded';

#  ok $test2-cat2.remove, '.remove()';
#  nok $test2-cat2.remove, 'category already removed';
}

#-------------------------------------------------------------------------------
done-testing
