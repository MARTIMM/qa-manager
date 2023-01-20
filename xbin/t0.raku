#!/usr/bin/env raku

use v6.d;

use QAManager::Set;
use QAManager::KV;
use QAManager::Category;

#-------------------------------------------------------------------------------
my QAManager::Category $category .= new(:category('accounting'));

$category.title = 'Accounting';
$category.description = 'QA forms about credentials';

# first set
my QAManager::Set $set .= new(:name<credentials>);
$set.description = 'Name and password for account';

my QAManager::KV $kv .= new(:name<username>);
$kv.description = 'Username of account';
$kv.required = True;
$set.add-kv($kv);

$kv .= new(:name<password>);
$kv.description = 'Password for username';
$kv.required = True;
$kv.encode = True;
$kv.stars = True;
$set.add-kv($kv);

$category.add-set($set);


# new set
$set .= new(:name<profile>);
$set.description = 'Profile data of user';

$kv .= new(:name<email>);
$kv.description = 'Email address';
$set.add-kv($kv);

$kv .= new(:name<www>);
$kv.description = 'Web site address';
$set.add-kv($kv);

$kv .= new(:name<image>);
$kv.description = 'Profile photo';
$set.add-kv($kv);

$category.add-set($set);


$category.save;


#  ok $category2.remove, '.remove()';
#  nok $category2.remove, 'category already removed';
