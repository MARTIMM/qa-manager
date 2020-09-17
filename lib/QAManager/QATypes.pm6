#tl:1:QATypes:

use v6.d;

#-------------------------------------------------------------------------------
=begin pod
=end pod

unit module QATypes:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
=begin pod
=head1 Types
=end pod

#-------------------------------------------------------------------------------
enum QADataFileType is export < INI JSON TOML >;


#-------------------------------------------------------------------------------
=begin pod
=head2 QAFieldType

QAFieldType is an enumeration of field types to provide an anwer. The types are (and more to come);

=item QACheckButton; A group of checkbuttons.
=comment item QADragAndDrop;
=comment item QAColorChooserDialog;
=item QAComboBox; A pulldown list with items.
=item QAEntry; A single line of text.
=comment item QAFileChooserDialog;
=comment item QAImage; An image.
=item QARadioButton; A group of radiobuttons.
=item QAScale; A scale for numeric input.
=item QASwitch; On/Off, Yes/No kind of input.
=item QATextView; Multy line input.
=item QAToggleButton; Like switch.

=end pod

#tt:1:QAFieldType:
enum QAFieldType is export <
  QAEntry QATextView QAComboBox QARadioButton QACheckButton
  QAToggleButton QAScale QASwitch QAImage QAFileChooserDialog
  QAColorChooserDialog QADragAndDrop
>;

#-------------------------------------------------------------------------------
#tt:1:QADisplayType:
enum QADisplayType is export <QADialog QANoteBook QAStack QAAssistant>;

#-------------------------------------------------------------------------------
#tt:1:inputStatusHint:
enum inputStatusHint is export <QAStatusNormal QAStatusOk QAStatusFail>;


#-------------------------------------------------------------------------------
#`{{
sub check-data-file-type ( --> QADataFileType ) is export {
  my QADataFileType $dft = JSON;

  $dft = INI if 'ini' ∈ @*ARGS;
  $dft = TOML if 'toml' ∈ @*ARGS;
  $dft = JSON if 'json' ∈ @*ARGS;
}
}}

#-------------------------------------------------------------------------------
=begin pod
=head1 Subroutines
=end pod

=begin pod
=head2 init

Initialization of dynamic variables. The application can modify the variables before opening any query sheets.

The following variables are used in this program;

=item QADataFileType $*data-file-type; You can choose from INI, JSON or TOML. By default it saves the answers in json formatted files.
=item Hash $*callback-objects;
... structure ...

=end pod
state Bool $initialized = False;
my QADataFileType $*data-file-type;
my Hash $*callback-objects;

#tm:0:init:
sub init ( ) is export {

  if !$initialized {
    $*data-file-type = 'json';
    $*callback-objects = %(
      actions => %(),
      qachecks => %(),
    );

    $initialized = True;
  }
}
