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
$entry-dialog.description = 'Display of all available types of entries other that text and their different ways of display';

my QAManager::KV $field .= new(:name<combobox1>);
$field.field = QAComboBox;
$field.required = True;
$field.values = [< value1 value2 value3 value4 >];
$field.description = 'Combobox input field 1';
$entry-dialog.add-kv($field);

$field .= new(:name<combobox2>);
$field.field = QAComboBox;
$field.values = [< value1 value2 value3 value4 >];
$field.default = 'value2';
$field.description = 'Combobox input field 2';
$entry-dialog.add-kv($field);


$field .= new(:name<radio1>);
$field.field = QARadioButton;
$field.description = 'Radio button input field 1';
$field.values = [< value1 value2 value3 value4 >];
$field.default = 'value2';
$entry-dialog.add-kv($field);


$field .= new(:name<check1>);
$field.field = QACheckButton;
$field.description = 'Check button input field 1';
$field.values = [< value1 value2 value3 value4 >];
$field.required = True;
$entry-dialog.add-kv($field);

$field .= new(:name<check2>);
$field.field = QACheckButton;
$field.description = 'Check button input field 2';
$field.values = [< value1 value2 value3 value4 >];
$field.default = [ 'value2', 'value4'];
$entry-dialog.add-kv($field);


$field .= new(:name<toggle1>);
$field.field = QAToggleButton;
$field.description = 'Toggle input field 1';
$field.default = True;
$entry-dialog.add-kv($field);


$field .= new(:name<scale1>);
$field.field = QAScale;
$field.description = 'Scale input field 1';
$field.minimum = 10e0;
$field.maximum = 20e0;
$field.default = 13e0;
$field.step = 7e-1;
$entry-dialog.add-kv($field);


$field .= new(:name<switch1>);
$field.field = QASwitch;
$field.description = 'Switch input field 1';
$field.default = True;
$entry-dialog.add-kv($field);


$field .= new(:name<image1>);
$field.field = QAImage;
$field.description = 'Image input field 1';
$field.default = 'resources/icons8-invoice-100.png';
$field.width = 100;
$field.height = 100;
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
