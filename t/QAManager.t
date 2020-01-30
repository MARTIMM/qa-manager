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
  my Hash $qa = %(
    :name('Credentials'),
    :description('Name and password for account'),
    :keys( [ %(
          :username( [ 'Username of account', QAString, { :required }]),
          :password( [ 'Password for username', QAString, { :encode, :stars }])
        )
      ]
    ),
  );

#`{{
  nok $qam.add-set( 'test1', 'credential', $qa), 'Category not loaded';
  ok $qam.load-category('test1'), '.load-category()';
  ok $qam.add-set( 'test1', 'credential', $qa), '.add-set()';
  nok $qam.add-set( 'test1', 'credential', $qa), 'set already added';
  ok $qam.save-category('test1'), '.save-category()';

  ok $qam.remove-set( 'test1', 'credential'), '.remove-set()';
  nok $qam.remove-set( 'test1', 'credential'), 'set already removed';
  nok $qam.remove-set( 'other test1', 'credential'), 'Category does not exist';

  ok $qam.remove-category('test1'), '.remove-category()';
  nok $qam.remove-category('test1'), 'Category does not exist';
}}
}

#-------------------------------------------------------------------------------
done-testing
