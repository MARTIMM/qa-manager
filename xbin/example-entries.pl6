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
my QAManager::Set $entry-dialog .= new(:name<example-entries>);
$entry-dialog.title = 'Example Entries';
$entry-dialog.description = 'Display of all available types of entries and their different ways of display';

my QAManager::KV $field .= new(:name<entry1>);
$field.description = 'Entry input field 1';
$entry-dialog.add-kv($field);

$field .= new(:name<entry2>);
$field.description = 'Entry input field 2';
$field.required = True;
$entry-dialog.add-kv($field);

$field .= new(:name<entry3>);
$field.description = 'Entry input field 3';
$field.default = 'default input';
$entry-dialog.add-kv($field);

$field .= new(:name<entry4>);
$field.description = 'Entry input field 4';
$field.example = 'example input';
$entry-dialog.add-kv($field);

$field .= new(:name<entry5>);
$field.description = 'Entry input field 5';
$field.default = 'password input';
$field.invisible = True;
$field.tooltip = 'Invisible for password';
$entry-dialog.add-kv($field);


$field .= new(:name<textview1>);
$field.field = QATextView;
$field.description = 'Textview input field 1';
$entry-dialog.add-kv($field);


$field .= new(:name<combobox1>);
$field.field = QAComboBox;
$field.required = True;
$field.values = [< value1  value2 value3 value4 >];
$field.description = 'Combobox input field 1';
$entry-dialog.add-kv($field);

$field .= new(:name<combobox2>);
$field.field = QAComboBox;
$field.values = [< value1  value2 value3 value4 >];
$field.default = 'value2';
$field.description = 'Combobox input field 2';
$entry-dialog.add-kv($field);


$field .= new(:name<radio1>);
$field.description = 'Radio button input field 1';
$field.values = [< value1  value2 value3 value4 >];
$field.field = QARadioButton;
$field.required = True;
$entry-dialog.add-kv($field);

$field .= new(:name<radio2>);
$field.description = 'Radio button input field 2';
$field.values = [< value1  value2 value3 value4 >];
$field.default = 'value2';
$field.field = QARadioButton;
$entry-dialog.add-kv($field);


$field .= new(:name<check1>);
$field.description = 'Check button input field 1';
$field.values = [< value1  value2 value3 value4 >];
$field.field = QACheckButton;
$field.required = True;
$entry-dialog.add-kv($field);

$field .= new(:name<check2>);
$field.description = 'Check button input field 2';
$field.values = [< value1  value2 value3 value4 >];
$field.default = 'value2';
$field.field = QACheckButton;
$entry-dialog.add-kv($field);


$field .= new(:name<toggle1>);
$field.description = 'Toggle input field 1';
$field.default = False;
$field.field = QAToggleButton;
$entry-dialog.add-kv($field);


$field .= new(:name<scale1>);
$field.field = QAScale;
$field.description = 'Scale input field 1';
$entry-dialog.add-kv($field);


$field .= new(:name<switch1>);
$field.description = 'Switch input field 1';
$field.default = False;
$field.field = QASwitch;
$entry-dialog.add-kv($field);


$field .= new(:name<image1>);
$field.description = 'Image input field 1';
#$field.default = ...path...;
$field.field = QAImage;
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
