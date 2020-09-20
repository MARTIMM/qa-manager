use v6.d;
use Test;

use QAManager::Set;
use QAManager::Question;
use QAManager::Category;
use QAManager::QATypes;

#-------------------------------------------------------------------------------
subtest 'Manipulations', {

  # 1 category
  my QAManager::Category $category .= new(:category('__category'));
  isa-ok $category, QAManager::Category, 'QA Manager category';

  # 1 set
  my QAManager::Set $set .= new(:name<credentials>);
  is $set.title, 'Credentials', '.title()';
  $set.description = 'Name and password for account';

  # 1st question and add to set
  my QAManager::Question $question .= new(:name<username>);
  $question.description = 'Username of account';
  $question.required = True;
  ok $set.add-question($question), '.add-question() username';

  # 2nd question and add to set
  $question .= new(:name<password>);
  $question.description = 'Password for username';
  $question.required = True;
  $question.encode = True;
  $question.invisible = True;
  ok $set.add-question($question), '.add-question() password';

  # add set to category
  ok $category.add-set($set), '.add-set()';

  # save category
  $category.save;

  my QAManager::Category $category2 .= new(:category('__category'));

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
  $category.save;

  my Str $qa-path = $qa-types.qa-path( '__category', :!sheet);
  ok $qa-path.IO.r, 'category file found';

  ok $category.remove(:ignore-changes), '.remove()';
  nok $qa-path.IO.r, 'category file removed';
}

#-------------------------------------------------------------------------------
done-testing
