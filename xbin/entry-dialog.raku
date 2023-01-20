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
my QAManager::Set $entry-dialog .= new(:name<entry-spec>);
$entry-dialog.title = 'Entry Specification';
$entry-dialog.description = 'Specify the fields that makup this question';

my QAManager::KV $field .= new(:name<name>);
$field.description = 'Key of this input field';
$field.required = True;
$entry-dialog.add-kv($field);

$field .= new(:name<field>);
$field.field = QAComboBox;
$field.values = [<
      QAEntry QATextView QASwitch QAComboBox QARadioButton QACheckButton
      QAToggleButton
    >];
$field.default = 'QAEntry';
$field.description = 'Type of input field';
$entry-dialog.add-kv($field);

$field .= new(:name<title>);
$field.description = 'Title text';
$field.required = False;
$entry-dialog.add-kv($field);

$field .= new(:name<description>);
$field.field = QATextView;
$field.description = 'Description of this input field';
$field.required = False;
$entry-dialog.add-kv($field);

$field .= new(:name<default>);
$field.description = 'Default input value when left empty';
$field.required = False;
$entry-dialog.add-kv($field);

$field .= new(:name<example>);
$field.description = 'Example input value shown in gray when empty';
$field.required = False;
$entry-dialog.add-kv($field);

$field .= new(:name<tooltip>);
$field.description = 'Extra info shown when above input field';
$field.required = False;
$entry-dialog.add-kv($field);

$field .= new(:name<callback>);
$field.description = 'Callback name in user provided handler object';
$field.required = False;
$entry-dialog.add-kv($field);

$field .= new(:name<invisible>);
$field.description = 'Text substituted with *s';
$field.required = False;
$field.default = False;
$field.field = QASwitch;
$entry-dialog.add-kv($field);

$field .= new(:name<required>);
$field.description = 'Required input';
$field.required = False;
$field.default = False;
$field.field = QASwitch;
$entry-dialog.add-kv($field);

$field .= new(:name<encode>);
$field.description = 'Encode input value before returning';
$field.required = False;
$field.default = False;
$field.field = QASwitch;
$entry-dialog.add-kv($field);

$field .= new(:name<minimum>);
$field.description = 'Minimum number of characters';
$field.required = False;
$field.default = 0;
$entry-dialog.add-kv($field);

$field .= new(:name<maximum>);
$field.description = 'Maximum number of characters';
$field.required = False;
$entry-dialog.add-kv($field);

#note $entry-dialog.set;

my QAManager::Category $category .= new(:category<QAManagerDialogs>);
$category.replace-set($entry-dialog);
$category.save;


my QAManager::Sheet $sheet .= new(:sheet<QAManagerEntryDialog>);

$sheet.new-page(
  :name<Entry>,
  :title("Entry Specification"),
  :description("Specification of an input field. Below you can fill in the necessary fields required for a description of an input field."
  )
);

$sheet.add-set( :category<QAManagerDialogs>, :set<entry-spec>);
$sheet.save;
