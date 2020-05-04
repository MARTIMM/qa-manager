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
my QAManager::Set $entry-dialog .= new(:name<example-text-entries>);
$entry-dialog.title = 'Example Text Entries';
$entry-dialog.description = 'Display of text entries and their different ways of display';

my QAManager::KV $field .= new(:name<entry1>);
$field.description = 'Entry input field 1';
$field.repeatable = True;
#$field.default = ['default input 1','default input 2',];
$entry-dialog.add-kv($field);

$field .= new(:name<entry2>);
$field.description = 'Entry input field 2';
$field.required = True;
$entry-dialog.add-kv($field);

$field .= new(:name<entry3>);
$field.description = 'Entry input field 3';
$field.default = ['default input',];
$entry-dialog.add-kv($field);

$field .= new(:name<entry4>);
$field.description = 'Entry input field 4';
$field.example = 'example input';
$entry-dialog.add-kv($field);

$field .= new(:name<entry5>);
$field.description = 'Entry input field 5';
$field.default = ['password input',];
$field.invisible = True;
$field.tooltip = 'Invisible for password';
$entry-dialog.add-kv($field);


$field .= new(:name<textview1>);
$field.field = QATextView;
$field.description = 'Textview input field 1';
$field.required = True;
$entry-dialog.add-kv($field);

#note $entry-dialog.set;

my QAManager::Category $category .= new(:category<ExampleEntries>);
$category.replace-set($entry-dialog);
$category.save;

#`{{
my QAManager::Sheet $sheet .= new(:sheet<ExampleEntries>);

$sheet.new-page(
  :name<Entry>,
  :title("Entry Specification"),
  :description("Specification of an input field. Below you can fill in the necessary fields required for a description of an input field."
  )
);

$sheet.add-set( :category<QAManagerDialogs>, :set<entry-spec>);
$sheet.save;
}}
