use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::Question:auth<github:MARTIMM>;

use QAManager::QATypes;

has Str $.callback is rw;       # optional key to check value
has Str $.cmpwith is rw;        # optional to check value against other field
has Any $.default is rw;        # optional default value
has Str $.description is rw;    # optional
has Bool $.encode is rw;        # when value must be encoded with sha256
has Str $.example is rw;        # optional example value for text
has Array $.fieldlist is rw;    # when a list is displayed in e.g. combobox
has QAFieldType $.fieldtype is rw;  # optional = QAEntry, QADialog or QACheckButton
has Int $.height is rw;         # optional height in pixels
has Bool $.hide is rw;          # optional hide question, default False
has Bool $.invisible is rw;     # when value is displayed as dotted characters
has Any $.maximum is rw;        # optional range for string or number type
has Any $.minimum is rw;        # optional range for string or number type
has Str $.name is required;     # key to values and name in widgets
has Bool $.repeatable is rw;    # when value is repeatable
has Bool $.required is rw;      # when value is required
has Array $.selectlist is rw;   # when a list is displayed in e.g. combobox
has Any $.step is rw;           # optional step for scale
has Str $.title is rw;          # optional = $!name.tclc
has Str $.tooltip is rw;        # optional tooltip value for tooltip
has Str $.userwidget is rw;     # key to user widget object
has Int $.width is rw;          # optional width in pixels

#-------------------------------------------------------------------------------
submethod BUILD ( Str:D :$!name, Hash :$qa-data ) {

#note "\n", $qa-data.perl;

  # if field is defined in approprate type
  if $qa-data<fieldtype> ~~ QAFieldType {
    $!fieldtype = $qa-data<fieldtype>;
  }

  # it is a string when deserialized from json
  elsif $qa-data<fieldtype> ~~ Str {
    if QAFieldType.enums{$qa-data<fieldtype>}.defined {
      $!fieldtype = QAFieldType(QAFieldType.enums{$qa-data<fieldtype>});
    }

    else {
      die "$qa-data<fieldtype> field type does not exist";
    }
  }

  # if fieldtype is not defined (or wrong), try to find a default
  # depending on type
  else {
    $!fieldtype = QAEntry;
  }


  $!default = $qa-data<default> if $qa-data<default>.defined;
  $!description = $qa-data<description> if $qa-data<description>.defined;
  $!encode = $qa-data<encode> if $qa-data<encode>.defined;
  $!example = $qa-data<example> if $qa-data<example>.defined;
  $!tooltip = $qa-data<tooltip> if $qa-data<tooltip>.defined;
  $!callback = $qa-data<callback> if $qa-data<callback>.defined;
  $!cmpwith = $qa-data<cmpwith> if $qa-data<cmpwith>.defined;
  $!height = $qa-data<height> if $qa-data<height>.defined;
  $!hide = $qa-data<hide> if $qa-data<hide>.defined;
  $!invisible = $qa-data<invisible> if $qa-data<invisible>.defined;
  $!minimum = $qa-data<minimum> if $qa-data<minimum>.defined;
  $!maximum = $qa-data<maximum> if $qa-data<maximum>.defined;
  $!selectlist = $qa-data<selectlist> if $qa-data<selectlist>.defined;
  $!fieldlist = $qa-data<fieldlist> if $qa-data<fieldlist>.defined;
  $!required = $qa-data<required> if $qa-data<required>.defined;
  $!repeatable = $qa-data<repeatable> if $qa-data<repeatable>.defined;
  $!step = $qa-data<step> if $qa-data<step>.defined;
  $!title = $qa-data<title> // $!name.tclc;
  $!userwidget = $qa-data<userwidget> if $qa-data<userwidget>.defined;
  $!width = $qa-data<width> if $qa-data<width>.defined;

#  $!category = $qa-data<category> if $qa-data<category>.defined;
#  $!set = $qa-data<set> if $qa-data<set>.defined;
}

#-------------------------------------------------------------------------------
method qa-data ( --> Hash ) {
  my Hash $qa-data = %( :$!name, :$!fieldtype);

  $qa-data<callback> = $!callback if $!callback.defined;
  $qa-data<default> = $!default if $!default.defined;
  $qa-data<description> = $!description if $!description.defined;
  $qa-data<encode> = $!encode if $!encode.defined;
  $qa-data<example> = $!example if $!example.defined;
  $qa-data<fieldlist> = $!fieldlist if $!fieldlist.defined;
  $qa-data<height> = $!height if $!height.defined;
  $qa-data<hide> = $!hide if $!hide.defined;
  $qa-data<invisible> = $!invisible if $!invisible.defined;
  $qa-data<minimum> = $!minimum if $!minimum.defined;
  $qa-data<maximum> = $!maximum if $!maximum.defined;
  $qa-data<required> = $!required if $!required.defined;
  $qa-data<repeatable> = $!repeatable if $!repeatable.defined;
  $qa-data<selectlist> = $!selectlist if $!selectlist.defined;
  $qa-data<step> = $!step if $!step.defined;
  $qa-data<title> = $!title if $!title.defined;
  $qa-data<tooltip> = $!tooltip if $!tooltip.defined;
  $qa-data<userwidget> = $!userwidget if $!userwidget.defined;
  $qa-data<width> = $!width if $!width.defined;

#  $qa-data<set> = $!set if $!set.defined;
#  $qa-data<category> = $!category if $!category.defined;

  $qa-data
}

#-------------------------------------------------------------------------------
