#!/usr/bin/env raku

use v6;
use QAManager;

my QAManager $qam .= new;
$qam.load-Category('accounting');

my Hash $qa = %(
  :name('credentials'),
  :title('Credentials'),
  :description('Name and password for account'),
  :keys( [ %(
        :username( [ 'Username of account', QAString, { :required }]),
        :password( [ 'Password for username', QAString, { :encode, :stars }])
      )
    ]
  ),
);

$qam.add-set( 'accounting', 'credential', $qa);
$qam.save-Category('accounting');
