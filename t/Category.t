use v6.d;
use Test;

#use QAManager;
use QAManager::Set;
use QAManager::KV;
use QAManager::Category;

#-------------------------------------------------------------------------------
subtest 'Manipulations', {

  # 1 category
  my QAManager::Category $category .= new(:category('__category'));
  isa-ok $category, QAManager::Category, 'QA Manager category';
  ok $category.is-loaded, '.is-loaded()';

  $category.title = 'Accounting';
  $category.description = 'QA forms about credentials';

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
  $kv.stars = True;
  ok $set.add-kv($kv), '.add-kv() password';

  # add set to category
  ok $category.add-set($set), '.add-set()';
  ok $category.is-changed, '.is-changed()';

  # save category
  ok $category.save, '.save()';
  nok $category.is-changed, 'saved -> not changed';

  # try to load category with same name -> fail
  my QAManager::Category $category2 .= new(:category('__category'));
  nok $category2.is-loaded, '2nd time not loaded';

  # purge
  $category.purge;
  nok $category2.remove, 'after purge no category';

  # after purge we can load it in another variable
  $category2 .= new(:category('__category'));
  ok $category2.is-loaded, 'now loaded';

  # remove from disk
  ok $category2.remove, '.remove()';
  nok $category2.remove, 'category already removed';
}

#-------------------------------------------------------------------------------
done-testing
