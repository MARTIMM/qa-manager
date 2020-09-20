use v6.d;
use Test;

use QAManager::Sheet;
use QAManager::Category;
use QAManager::Set;
use QAManager::KV;
use QAManager::QATypes;

#-------------------------------------------------------------------------------
my QAManager::QATypes $qa-types .= instance;
my QAManager::Sheet $sheet .= new(:sheet<__login>);

# create some category data with some sets
make-category();

#-------------------------------------------------------------------------------
subtest 'ISO-Test', {

  isa-ok $sheet, QAManager::Sheet, '.new(:sheet)';
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {

  is $sheet.display, QANoteBook, '.display()';

  ok $sheet.new-page(:name<tstsheet2>), '.new-page()';
  $sheet.new-page(:name<tstsheet3>);

  $sheet.new-page(
    :name<tstsheet1>,
    :title("Test Sheet 1"),
    :description("Description jzh glfksd slfdjg sdfgl jsfdg lsdfg jhsdlfgj sdfg lsdkj sdgljshdfg ls dfj sdf glsjfdg sdflg ksdlfgj sdfg sdflkhsdf gsdfkggh"
    )
  );

  ok $sheet.add-set( :category<__test-accounting>, :set<credentials>),
     '.add-set()';
  nok $sheet.remove-set( :category<__test-accounting>, :set<creds>),
     'creds set not added';
  nok $sheet.remove-set( :category<__test-accounting>, :set<profile>),
     'profile set not removed';
  ok $sheet.remove-set( :category<__test-accounting>, :set<credentials>),
     '.remove-set()';

  ok $sheet.add-set( :category<__test-accounting>, :set<credentials>),
     '.add-set()';
  ok $sheet.add-set( :category<__test-accounting>, :set<profile>),
     '.add-set()';

  $sheet.delete-page(:name<tstsheet2>);
  $sheet.save;

  if $*DISTRO.is-win {
    skip 'No idea for store locations on windows yet', 1;
  }

  else {
    my Str $qa-path = $qa-types.qa-path( '__login', :sheet);
    ok $qa-path.IO.r, '.save() __login';
  }

  $sheet.save-as('__login2');
  if $*DISTRO.is-win {
    skip 'No idea for store locations on windows yet', 1;
  }

  else {
    my Str $qa-path = $qa-types.qa-path( '__login2', :sheet);
    ok $qa-path.IO.r, '.save-as() __login2';
  }

  $sheet .= new(:sheet<__login2>);
  ok $sheet.remove, '__login2 deleted';

  # cannot remove unloaded sheets
  $sheet .= new(:sheet<__login>);
  ok $sheet.remove, '__login removed';
}

#-------------------------------------------------------------------------------
my QAManager::Category $category .= new(:category<__test-accounting>);
$category.remove;

done-testing;

#-------------------------------------------------------------------------------
# create some category data with some sets
sub make-category ( ) {
  my QAManager::Category $category .= new(:category<__test-accounting>);

  # 1 set
  my QAManager::Set $set .= new(:name<credentials>);
  $set.description = 'Name and password for account';

  # 1st kv and add to set
  my QAManager::KV $kv .= new(:name<username>);
  $kv.description = 'Username of account';
  $kv.required = True;
  $set.add-kv($kv);

  # 2nd kv and add to set
  $kv .= new(:name<password>);
  $kv.description = 'Password for username';
  $kv.required = True;
  $kv.encode = True;
  $kv.invisible = True;
  $set.add-kv($kv);

  # add set to category
  $category.add-set($set);

  # 2 set
  $set .= new(:name<profile>);
  $set.description = 'Extra info for account';

  # 1st kv and add to set
  $kv .= new(:name<waddress>);
  $kv.description = 'Work Address';
  $kv.required = True;
  $set.add-kv($kv);

  # add set to category
  $category.add-set($set);

  # save category
  $category.save;
}
