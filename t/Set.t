use v6.d;
use Test;

#use QAManager;
use QAManager::Set;
use QAManager::Question;

#-------------------------------------------------------------------------------
my QAManager::Set $creds .= new(:name<credentials>);
#-------------------------------------------------------------------------------
subtest 'ISO-Test', {

  isa-ok $creds, QAManager::Set, '.new(:name)';
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  is $creds.title, 'Credentials', '.title()';
  $creds.description = 'Name and password for account';

  my QAManager::Question $un .= new(:name<username>);
  $un.description = 'Username of account';
  $un.required = True;

  my QAManager::Question $pw .= new(:name<password>);
  $pw.description = 'Password for username';
  $pw.required = True;
  $pw.encode = True;
  $pw.invisible = True;

  ok $creds.add-question($un), '.add-kv()';
  nok $creds.add-question($un), 'allready added';
  ok $creds.add-question($pw), '.add-kv()';
  ok $creds.replace-question($pw), '.replace-kv()';

#  note $creds.set;
}

#-------------------------------------------------------------------------------
done-testing
