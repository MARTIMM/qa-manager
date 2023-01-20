#!/usr/bin/env raku
use v6.d;
#use lib '../gnome-gobject/lib';
#use lib '../gnome-gtk3/lib';
#use QAManager::Gui::Application;
use lib 'qa-manager/lib';

#use Gnome::N::X;
#Gnome::N::debug(:on);

use QAManager::Set;
use QAManager::KV;
use QAManager::QATypes;
use QAManager::Category;
use QAManager::Sheet;

#-------------------------------------------------------------------------------
my QAManager::Set $set-dialog .= new(:name<set-spec>);
$set-dialog.title = 'Set Specification';
$set-dialog.description = 'Specify the fields that makup this set';

my QAManager::KV $field .= new(:name<name>);
$field.description = 'Key of this input field';
$field.required = True;
$set-dialog.add-kv($field);

$field .= new(:name<title>);
$field.description = 'Title text';
$field.required = False;
$set-dialog.add-kv($field);

$field .= new(:name<description>);
$field.field = QATextView;
$field.description = 'Description of this input field';
$field.required = False;
$set-dialog.add-kv($field);
$field.field = QATextView;

#note $set-dialog.set;

my QAManager::Category $category .= new(:category<QAManagerDialogs>);
$category.replace-set($set-dialog);
$category.save;


my QAManager::Sheet $sheet .= new(:sheet<QAManagerSetDialog>);

$sheet.new-page(
  :name<Set>,
  :title("Set Specification"),
  :description("Specification of a set. Below you can fill in the necessary fields required for a description of an iinput field."
  )
);

$sheet.add-set( :category<QAManagerDialogs>, :set<set-spec>);
$sheet.save;
