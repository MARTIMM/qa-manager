use v6.d;
use Test;

use QAManager;

#-------------------------------------------------------------------------------
my QAManager $qam .= new;
#-------------------------------------------------------------------------------
subtest 'ISO-Test', {

  isa-ok $qam, QAManager, 'QA Manager';
}

#-------------------------------------------------------------------------------
subtest 'Manipulations', {
  ok $qam.load-category('__test-accounting'), '.load-category()';

  my QAManager $qam2 .= new;
  nok $qam2.load-category('__test-accounting'), 'can not load in 2nd manager';
}

#-------------------------------------------------------------------------------
done-testing
