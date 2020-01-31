use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::KV:auth<github:MARTIMM>;

enum QATypes is export <QANumber QAString QABoolean QAImage QAArray QASet>;
enum QAFieldTypes is export <QAEntry QAScale QATextView QAComboBox
        QARadioButton QACheckButton QASwitch QAToggleButton
        QAFileChooserDialog QADragAndDrop QAColorChooserDialog
        QADialog QAStack QANoteBook
        >;

has Str $.name is required;
has Str $.title is rw;          # optional = $!name.tclc
has Str $.description is rw;    # optional
has QATypes $.type is rw;       # optional = QAString
has QAFieldTypes $.field is rw; # optional = QAEntry, QADialog or QACheckButton
has Any $.minimum is rw;        # optional range for number type
has Any $.maximum is rw;        # optional range for number type
has Any $.default is rw;        # optional default value
has Bool $.required is rw;      # when value is required
has Bool $.encode is rw;        # when value must be encoded with sha256
has Bool $.stars is rw;         # when value is displayed as stars
has Str $.category is rw;       # when referring to other set
has Str $.set is rw;            # when referring to other set

#-------------------------------------------------------------------------------
submethod BUILD ( Str:D :$!name, Hash :$kv ) {

  $!type = $kv<type> // QAString;
  if $kv<field> ~~ QAFieldTypes {
    $!field = $kv<field>;
  }

  elsif $!type ~~ QASet {
    $!field = QAEntry;
  }

  elsif $!type ~~ QAArray {
    $!field = QAComboBox;
  }

  else {
    $!field = QAEntry;
  }

  $!title = $kv<title> // $!name.tclc;
  $!description = $kv<description> if $kv<description>.defined;
  $!minimum = $kv<minimum> if $kv<minimum>.defined;
  $!maximum = $kv<maximum> if $kv<maximum>.defined;
  $!default = $kv<default> if $kv<default>.defined;
  $!required = $kv<required> // False;
  $!encode = $kv<encode> // False;
  $!stars = $kv<stars> // False;
  $!category = $kv<category> if $kv<category>.defined;
  $!set = $kv<set> if $kv<set>.defined;
}

#-------------------------------------------------------------------------------
method kv ( --> Hash ) {
  my Hash $kv = %( :$!type, :$!field, :$!required, :$!encode, :$!stars);

  $kv<title> = $!title if $!title.defined;
  $kv<description> = $!description if $!description.defined;
  $kv<minimum> = $!minimum if $!minimum.defined;
  $kv<maximum> = $!maximum if $!maximum.defined;
  $kv<default> = $!default if $!default.defined;
  $kv<category> = $!category if $!category.defined;
  $kv<set> = $!set if $!set.defined;

  %$kv
}

#-------------------------------------------------------------------------------
