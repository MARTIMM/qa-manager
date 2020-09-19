use v6.d;
use Test;

#use QAManager;
use QAManager::Sheet;
use QAManager::Category;
use QAManager::Set;
use QAManager::KV;
use QAManager::QATypes;

#-------------------------------------------------------------------------------
my QAManager::Sheet $sheet .= new(:sheet<__login>);
#-------------------------------------------------------------------------------
subtest 'ISO-Test', {

  isa-ok $sheet, QAManager::Sheet, '.new(:sheet)';
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
#  ok $sheet.is-loaded, '.is-loaded()';
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
  nok $sheet.remove-set( :category<__test-accounting>, :set<credents>),
     'not added';
  nok $sheet.remove-set( :category<__test-accounting>, :set<profile>),
     'not removed';
  ok $sheet.remove-set( :category<__test-accounting>, :set<credentials>),
     '.remove-set()';

  ok $sheet.add-set( :category<__test-accounting>, :set<credentials>),
     '.add-set()';
  ok $sheet.add-set( :category<__test-accounting>, :set<profile>),
     '.add-set()';

#`{{
note $sheet.WHAT;
  for $sheet -> $page {
    note "P: ", $page.perl;
  }
}}

  $sheet.delete-page(:name<tstsheet2>);

  $sheet.save;

  if $*DISTRO.is-win {
    skip 'No idea for store locations on windows yet', 1;
  }

  else {
    ok "$*HOME/.config/QAManager/QA.d/__login.cfg".IO.r, '.save() __login';
  }

  $sheet.save-as('__login2');
  if $*DISTRO.is-win {
    skip 'No idea for store locations on windows yet', 1;
  }

  else {
    ok "$*HOME/.config/QAManager/QA.d/__login2.cfg".IO.r, '.save-as() __login2';
  }

#  # purge __login2
#  ok $sheet.purge(:ignore-changes), '.purge() __login2';
#  nok $sheet.remove(:sheet<__login2>), '__login2 not deleted, was purged';
  $sheet .= new(:sheet<__login2>);
  ok $sheet.remove(:sheet<__login2>), '__login2 deleted';
  nok $sheet.remove(:sheet<__login2>), '__login2 not existent';

  # cannot remove unloaded sheets
  ok $sheet.remove(:sheet<__login>), '__login removed';

#  # delete __login. for that we must load it first
#  $sheet .= new(:sheet<__login>);
#  ok $sheet.remove(:sheet<__login>), '__login removed';
}

#-------------------------------------------------------------------------------
done-testing
