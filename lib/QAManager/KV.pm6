use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::KV:auth<github:MARTIMM>;

use QAManager::QATypes;

has Str $.callback is rw;       # optional to check value
#has Str $.category is rw;       # when referring to other set
has Str $.cmpwith is rw;        # optional to check value against other field
has Any $.default is rw;        # optional default value
has Str $.description is rw;    # optional
has Bool $.encode is rw;        # when value must be encoded with sha256
has Str $.example is rw;        # optional example value for text
has QAFieldType $.field is rw; # optional = QAEntry, QADialog or QACheckButton
has Int $.height is rw;         # optional height in pixels
has Bool $.invisible is rw;     # when value is displayed as invisible
has Any $.minimum is rw;        # optional range for string or number type
has Any $.maximum is rw;        # optional range for string or number type
has Any $.step is rw;           # optional step for scale
has Str $.name is required;
has Str $.tooltip is rw;        # optional tooltip value for tooltip
has Bool $.repeatable is rw;    # when value is repeatable
has Bool $.required is rw;      # when value is required
#has Str $.set is rw;            # when referring to other set
has Str $.title is rw;          # optional = $!name.tclc
has Array $.values is rw;       # when a list is displayed in e.g. combobox
has Int $.width is rw;          # optional width in pixels

#-------------------------------------------------------------------------------
submethod BUILD ( Str:D :$!name, Hash :$kv ) {

#note "\n", $kv.perl;

  # if field is defined in approprate type
  if $kv<field> ~~ QAFieldType {
    $!field = $kv<field>;
  }

  # it is a string when deserialized from json
  elsif $kv<field> ~~ Str {
    if QAFieldType.enums{$kv<field>}.defined {
      $!field = QAFieldType(QAFieldType.enums{$kv<field>});
    }

    else {
      die "$kv<field> field type does not exist";
    }
  }

  # if field is not defined (or wrong), try to find a default depending on type
  else {
    $!field = QAEntry;
  }


  $!title = $kv<title> // $!name.tclc;
  $!description = $kv<description> if $kv<description>.defined;
  $!minimum = $kv<minimum> if $kv<minimum>.defined;
  $!maximum = $kv<maximum> if $kv<maximum>.defined;
  $!step = $kv<step> if $kv<step>.defined;
  $!default = $kv<default> if $kv<default>.defined;
  $!example = $kv<example> if $kv<example>.defined;
  $!tooltip = $kv<tooltip> if $kv<tooltip>.defined;
  $!callback = $kv<callback> if $kv<callback>.defined;
  $!cmpwith = $kv<cmpwith> if $kv<cmpwith>.defined;
  $!values = $kv<values> if $kv<values>.defined;
  $!required = $kv<required> if $kv<required>.defined;# // False;
  $!repeatable = $kv<repeatable> if $kv<repeatable>.defined;    # // False;
  $!encode = $kv<encode> if $kv<encode>.defined;# // False;
  $!invisible = $kv<invisible> if $kv<invisible>.defined;# // False;
#  $!category = $kv<category> if $kv<category>.defined;
#  $!set = $kv<set> if $kv<set>.defined;
  $!height = $kv<height> if $kv<height>.defined;
  $!width = $kv<width> if $kv<width>.defined;
}

#-------------------------------------------------------------------------------
method kv-data ( --> Hash ) {
  my Hash $kv = %( :$!name, :$!field);

  $kv<title> = $!title if $!title.defined;
  $kv<description> = $!description if $!description.defined;
  $kv<minimum> = $!minimum if $!minimum.defined;
  $kv<maximum> = $!maximum if $!maximum.defined;
  $kv<step> = $!step if $!step.defined;
  $kv<default> = $!default if $!default.defined;
  $kv<example> = $!example if $!example.defined;
  $kv<tooltip> = $!tooltip if $!tooltip.defined;
  $kv<callback> = $!callback if $!callback.defined;
  $kv<values> = $!values if $!values.defined;

  $kv<required> = $!required if $!required.defined;
  $kv<repeatable> = $!repeatable if $!repeatable.defined;
  $kv<encode> = $!encode if $!encode.defined;
  $kv<invisible> = $!invisible if $!invisible.defined;
#  $kv<category> = $!category if $!category.defined;
#  $kv<set> = $!set if $!set.defined;
  $kv<height> = $!height if $!height.defined;
  $kv<width> = $!width if $!width.defined;

  $kv
}

#-------------------------------------------------------------------------------
