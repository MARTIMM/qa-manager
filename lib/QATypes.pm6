
use v6.d;

enum QATypes is export <QANumber QAString QABoolean QAFile QAArray QASet>;
enum QAFieldTypes is export <QAEntry QAScale QATextView QAComboBox
        QARadioButton QACheckButton QASwitch QAToggleButton
        QAFileChooserDialog QADragAndDrop QAColorChooserDialog
        QADialog QAStack QANoteBook QAImage
        >;

enum inputStatusHint is export <QADontCare QAStatusOk QAStatusFail>;
