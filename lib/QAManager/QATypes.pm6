use v6.d;

#-------------------------------------------------------------------------------
#enum QADataFileType is export < INI JSON TOML >;

enum QAFieldType is export <
        QAEntry QATextView QAComboBox QARadioButton QACheckButton
        QAToggleButton QAScale QASwitch QAImage QAFileChooserDialog
        QAColorChooserDialog QADragAndDrop
        >;

enum QADisplayType is export <QADialog QANoteBook QAStack QAAssistant>;

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
