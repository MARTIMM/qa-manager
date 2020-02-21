
use v6.d;

enum QAFieldType is export <
        QAEntry QAScale QATextView QAComboBox QARadioButton QACheckButton
        QASwitch QAToggleButton QAFileChooserDialog QADragAndDrop
        QAColorChooserDialog QAImage
        >;

enum QADisplayType is export <QADialog QANoteBook QAStack QAAssistant>;

enum inputStatusHint is export <QADontCare QAStatusOk QAStatusFail>;
