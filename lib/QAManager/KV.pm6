use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::KV:auth<github:MARTIMM>;

use QATypes;

has Str $.name is required;
has Str $.title is rw;          # optional = $!name.tclc
has Str $.description is rw;    # optional
has QATypes $.type is rw;       # optional = QAString
has QAFieldTypes $.field is rw; # optional = QAEntry, QADialog or QACheckButton
has Any $.minimum is rw;        # optional range for string or number type
has Any $.maximum is rw;        # optional range for string or number type
has Any $.default is rw;        # optional default value
has Str $.example is rw;        # optional example value for text
has Str $.tooltip is rw;        # optional tooltip value for tooltip
has Str $.callback is rw;        # optional to check value
has Str $.cmpwith is rw;        # optional to check value against other field
has Bool $.repeatable is rw;    # when value is repeatable
has Bool $.required is rw;      # when value is required
has Bool $.encode is rw;        # when value must be encoded with sha256
has Bool $.invisible is rw;     # when value is displayed as invisible
has Str $.category is rw;       # when referring to other set
has Str $.set is rw;            # when referring to other set

#-------------------------------------------------------------------------------
submethod BUILD ( Str:D :$!name, Hash :$kv ) {

#note $kv.perl;

  # check if defined in proper type
  if $kv<type> ~~ QATypes {
    $!type = $kv<type>;
  }

  # it is a string when deserialized from json
  elsif $kv<type> ~~ Str {
    $!type = QATypes(QATypes.enums{$kv<type>});
  }

  # else pick default
  else {
    $!type = QAString;
  }


  # if field is defined in approprate type
  if $kv<field> ~~ QAFieldTypes {
    $!field = $kv<field>;
  }

  # it is a string when deserialized from json
  elsif $kv<field> ~~ Str {
    $!field = QAFieldTypes(QAFieldTypes.enums{$kv<field>});
  }


  # if field is not defined (or wrong), try to find a default depending on type
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
  $!example = $kv<example> if $kv<example>.defined;
  $!tooltip = $kv<tooltip> if $kv<tooltip>.defined;
  $!callback = $kv<callback> if $kv<callback>.defined;
  $!cmpwith = $kv<cmpwith> if $kv<cmpwith>.defined;
  $!required = $kv<required> if $kv<required>.defined;# // False;
  $!repeatable = $kv<repeatable> if $kv<repeatable>.defined;    # // False;
  $!encode = $kv<encode> if $kv<encode>.defined;# // False;
  $!invisible = $kv<invisible> if $kv<invisible>.defined;# // False;
  $!category = $kv<category> if $kv<category>.defined;
  $!set = $kv<set> if $kv<set>.defined;
}

#-------------------------------------------------------------------------------
method kv-data ( --> Hash ) {
  my Hash $kv = %(
    :$!name, :$!type, :$!field
  );

  $kv<title> = $!title if $!title.defined;
  $kv<description> = $!description if $!description.defined;
  $kv<minimum> = $!minimum if $!minimum.defined;
  $kv<maximum> = $!maximum if $!maximum.defined;
  $kv<default> = $!default if $!default.defined;
  $kv<example> = $!example if $!example.defined;
  $kv<tooltip> = $!tooltip if $!tooltip.defined;
  $kv<callback> = $!callback if $!callback.defined;
  $kv<cmpwith> = $!cmpwith if $!cmpwith.defined;

  $kv<required> = $!required if $!required.defined;
  $kv<repeatable> = $!repeatable if $!repeatable.defined;
  $kv<encode> = $!encode if $!encode.defined;
  $kv<invisible> = $!invisible if $!invisible.defined;
  $kv<category> = $!category if $!category.defined;
  $kv<set> = $!set if $!set.defined;

  $kv
}

#-------------------------------------------------------------------------------
