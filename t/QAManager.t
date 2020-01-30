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

  nok $qam.add-set( 'test1', 'credential', $qa), 'catagory not loaded';
  ok $qam.load-catagory('test1'), '.load-catagory()';
  ok $qam.add-set( 'test1', 'credential', $qa), '.add-set()';
  nok $qam.add-set( 'test1', 'credential', $qa), 'set already added';
  ok $qam.save-catagory('test1'), '.save-catagory()';

  ok $qam.remove-set( 'test1', 'credential'), '.remove-set()';
  nok $qam.remove-set( 'test1', 'credential'), 'set already removed';
  nok $qam.remove-set( 'other test1', 'credential'), 'catagory does not exist';

  ok $qam.remove-catagory('test1'), '.remove-catagory()';
  nok $qam.remove-catagory('test1'), 'catagory does not exist';
}

#-------------------------------------------------------------------------------
done-testing
