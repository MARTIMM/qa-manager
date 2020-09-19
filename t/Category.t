use v6.d;
use Test;

#use QAManager;
use QAManager::Set;
use QAManager::KV;
use QAManager::Category;

use QAManager::QATypes;

#-------------------------------------------------------------------------------
subtest 'Manipulations', {

  # 1 category
  my QAManager::Category $category .= new(:category('__category'));
  isa-ok $category, QAManager::Category, 'QA Manager category';
#  ok $category.is-loaded, '.is-loaded()';

  # 1 set
  my QAManager::Set $set .= new(:name<credentials>);
  is $set.title, 'Credentials', '.title()';
  $set.description = 'Name and password for account';

  # 1st kv and add to set
  my QAManager::KV $kv .= new(:name<username>);
  $kv.description = 'Username of account';
  $kv.required = True;
  ok $set.add-kv($kv), '.add-kv() username';

  # 2nd kv and add to set
  $kv .= new(:name<password>);
  $kv.description = 'Password for username';
  $kv.required = True;
  $kv.encode = True;
  $kv.invisible = True;
  ok $set.add-kv($kv), '.add-kv() password';

  # add set to category
  ok $category.add-set($set), '.add-set()';
  ok $category.is-changed, '.is-changed()';

  # save category
  $category.save;
  nok $category.is-changed, 'saved -> not changed';

#  # try to load category with same name -> fail
#  my QAManager::Category $category2 .= new(:category('__category'));
#  nok $category2.is-loaded, '2nd time not loaded';

#  # purge
#  $category.purge;
#  nok $category2.remove, 'after purge no category';

#  # after purge we can load it in another variable
  my QAManager::Category $category2 .= new(:category('__category'));
#  ok $category2.is-loaded, 'now loaded';

  like (|$category2.get-setnames).join(','), / credentials /, '.get-setnames()';
  $category2.delete-set('credentials');
  unlike (|$category2.get-setnames).join(','), / credentials /,
         'credentials deleted';

  # remove from disk
  ok $category2.remove(:ignore-changes), '.remove()';
  nok $category2.remove, '__category already removed';
}


#-------------------------------------------------------------------------------
subtest 'Save elsewhere', {

  mkdir 't/Data/Categories', 0o750 unless 't/Data/Categories'.IO.e;
  mkdir 't/Data/Sheets', 0o750 unless 't/Data/Sheets'.IO.e;
  my QAManager::QATypes $qa-types .= instance;
  $qa-types.cfgloc-category = 't/Data/Categories';
  $qa-types.cfgloc-sheet = 't/Data/Sheets';

  # 1 category
  my QAManager::Category $category .= new(:category('__category'));
#`{{
  isa-ok $category, QAManager::Category, 'QA Manager category';
#  ok $category.is-loaded, '.is-loaded()';

  # 1 set
  my QAManager::Set $set .= new(:name<credentials>);
  is $set.title, 'Credentials', '.title()';
  $set.description = 'Name and password for account';

  # 1st kv and add to set
  my QAManager::KV $kv .= new(:name<username>);
  $kv.description = 'Username of account';
  $kv.required = True;
  ok $set.add-kv($kv), '.add-kv() username';

  # 2nd kv and add to set
  $kv .= new(:name<password>);
  $kv.description = 'Password for username';
  $kv.required = True;
  $kv.encode = True;
  $kv.invisible = True;
  ok $set.add-kv($kv), '.add-kv() password';

  # add set to category
  ok $category.add-set($set), '.add-set()';
  ok $category.is-changed, '.is-changed()';

  # save category
}}
  $category.save;
  nok $category.is-changed, 'saved -> not changed';
  my Str $qa-path = $qa-types.qa-path( '__category', :!sheet);
  ok $qa-path.IO.r, 'category file found';

  ok $category.remove(:ignore-changes), '.remove()';
  nok $qa-path.IO.r, 'category file removed';


#  # try to load category with same name -> fail
#  my QAManager::Category $category2 .= new(:category('__category'));
#  nok $category2.is-loaded, '2nd time not loaded';

#  # purge
#  $category.purge;
#  nok $category2.remove, 'after purge no category';
#`{{
#  # after purge we can load it in another variable
  my QAManager::Category $category2 .= new(:category('__category'));
#  ok $category2.is-loaded, 'now loaded';

  like (|$category2.get-setnames).join(','), / credentials /, '.get-setnames()';
  $category2.delete-set('credentials');
  unlike (|$category2.get-setnames).join(','), / credentials /,
         'credentials deleted';

  # remove from disk
  ok $category2.remove(:ignore-changes), '.remove()';
  nok $category2.remove, '__category already removed';
}}
}

#-------------------------------------------------------------------------------
done-testing
