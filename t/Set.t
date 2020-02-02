use v6.d;
use Test;

#use QAManager;
use QAManager::Set;
use QAManager::KV;

#-------------------------------------------------------------------------------
my QAManager::Set $creds .= new(:name<credentials>);
#-------------------------------------------------------------------------------
subtest 'ISO-Test', {

  isa-ok $creds, QAManager::Set, 'QA Manager';
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  is $creds.title, 'Credentials', '.title()';
  $creds.description = 'Name and password for account';

  my QAManager::KV $un .= new(:name<username>);
  $un.description = 'Username of account';
  $un.required = True;

  my QAManager::KV $pw .= new(:name<password>);
  $pw.description = 'Password for username';
  $pw.required = True;
  $pw.encode = True;
  $pw.stars = True;

  ok $creds.add-kv($un), '.add-kv()';
  nok $creds.add-kv($un), 'allready added';
  ok $creds.add-kv($pw), '.add-kv()';
  ok $creds.replace-kv($pw), '.replace-kv()';

#  note $creds.set;
}

#-------------------------------------------------------------------------------
done-testing
