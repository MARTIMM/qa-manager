#!/usr/bin/env raku

=begin pod
=head1

This program creates a questionaire for the QAManager system. This sheet is for questions to create a questionaire for the user. The result is stored in the resources directory of the QAManager.

=end pod

use v6.d;

#use QAManager::Gui::Application;
#use lib 'qa-manager/lib';

#use Gnome::N::X;
#Gnome::N::debug(:on);

use QAManager::Set;
use QAManager::KV;
use QAManager::QATypes;
use QAManager::Category;
use QAManager::Sheet;

#-------------------------------------------------------------------------------
my QAManager::Set $entry-dialog .= new(:name<entry-spec>);
$entry-dialog.title = 'Sheet Configuration';
$entry-dialog.description = 'Specify the fields that makup this sheet';

my QAManager::KV $field;
given   .= new(:name<name>) {
  .description = 'Name of this sheet';
  .required = True;
$entry-dialog.add-kv($field);

  .= new(:name<description>);
  .field = QAComboBox;
  .values = [<
      QAEntry QATextView QASwitch QAComboBox QARadioButton QACheckButton
      QAToggleButton
    >];
#  .default = 'QAEntry';
  .description = 'Describe what the use is for';
$entry-dialog.add-kv($field);

#`{{
  .= new(:name<title>);
  .description = 'Title text';
  .required = False;
$entry-dialog.add-kv($field);

  .= new(:name<description>);
  .field = QATextView;
  .description = 'Description of this input field';
  .required = False;
$entry-dialog.add-kv($field);

  .= new(:name<default>);
  .description = 'Default input value when left empty';
  .required = False;
$entry-dialog.add-kv($field);

  .= new(:name<example>);
  .description = 'Example input value shown in gray when empty';
  .required = False;
$entry-dialog.add-kv($field);

  .= new(:name<tooltip>);
  .description = 'Extra info shown when above input field';
  .required = False;
$entry-dialog.add-kv($field);

  .= new(:name<callback>);
  .description = 'Callback name in user provided handler object';
  .required = False;
$entry-dialog.add-kv($field);

  .= new(:name<invisible>);
  .description = 'Text substituted with *s';
  .required = False;
  .default = False;
  .field = QASwitch;
$entry-dialog.add-kv($field);

  .= new(:name<required>);
  .description = 'Required input';
  .required = False;
  .default = False;
  .field = QASwitch;
$entry-dialog.add-kv($field);

  .= new(:name<encode>);
  .description = 'Encode input value before returning';
  .required = False;
  .default = False;
  .field = QASwitch;
$entry-dialog.add-kv($field);

  .= new(:name<minimum>);
  .description = 'Minimum number of characters';
  .required = False;
  .default = 0;
$entry-dialog.add-kv($field);

  .= new(:name<maximum>);
  .description = 'Maximum number of characters';
  .required = False;
$entry-dialog.add-kv($field);
}}
}

#note $entry-dialog.set;

my QAManager::Category $category .= new(:category<QAManagerDialogs>);
$category.replace-set($entry-dialog);
$category.save;


my QAManager::Sheet $sheet .= new(:sheet<QAManagerSheetDialog>);

$sheet.new-page(
  :name<Entry>,
  :title("Entry Specification"),
  :description("Specification of an input field. Below you can fill in the necessary fields required for a description of an input field."
  )
);

$sheet.add-set( :category<QAManagerDialogs>, :set<entry-spec>);
$sheet.save;
