#tl:1:QATypes:

use v6.d;

use JSON::Fast;

#-------------------------------------------------------------------------------
=begin pod
A singleton class to provide types and global variables

=end pod

unit class QAManager::QATypes:auth<github:MARTIMM>;
#-------------------------------------------------------------------------------
=begin pod
=head1 Types
=end pod

#-------------------------------------------------------------------------------
=begin pod
=head2 QADataFileType
=end pod
#tt:1:QADataFileType:
enum QADataFileType is export < QAINI QAJSON QATOML >;

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
my QAManager::QATypes $instance;

has QADataFileType $.data-file-type is rw;
has Hash $.callback-objects is rw;
has Str $.cfgloc-category is rw;
has Str $.cfgloc-sheet is rw;
has Str $.cfgloc-resource is rw;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=end pod

#-------------------------------------------------------------------------------
submethod new ( ) { !!! }

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  self!init
}

#-------------------------------------------------------------------------------
method instance ( --> QAManager::QATypes ) {
  $instance //= self.bless;

  $instance
}

#-------------------------------------------------------------------------------
method qa-path( Str:D $qa-filename, Bool :$sheet = False --> Str ) {
  my Str $qa-path;
  if $sheet {
    $qa-path = "$!cfgloc-sheet/$qa-filename.cfg";
  }

  else {
    $qa-path = "$!cfgloc-category/$qa-filename.cfg";
  }

  $qa-path
}

#-------------------------------------------------------------------------------
method qa-load (
  Str:D $qa-filename, Bool :$sheet = False, Str :$qa-path is copy
  --> Hash
) {
  $qa-path //= self.qa-path( $qa-filename, :$sheet);
  my $data = from-json($qa-path.IO.slurp) if $qa-path.IO.r;
  $data // Hash
}

#-------------------------------------------------------------------------------
method qa-save (
  Str:D $qa-filename, Hash:D $qa-data, Bool :$sheet = False,
  Str :$qa-path is copy
) {
  $qa-path //= self.qa-path( $qa-filename, :$sheet);
  $qa-path.IO.spurt(to-json($qa-data));
}

#-------------------------------------------------------------------------------
method qa-remove (
  Str:D $qa-filename, Bool :$sheet = False, Str :$qa-path is copy
) {
  $qa-path //= self.qa-path( $qa-filename, :$sheet);
  unlink $qa-path;
}

#-------------------------------------------------------------------------------
method user-load ( Str $user-filename --> Hash ) {
}

#-------------------------------------------------------------------------------
method user-save ( Hash $user-data ) {
}

#-------------------------------------------------------------------------------
=begin pod
=head2 !init

Initialization of dynamic variables. The application can modify the variables before opening any query sheets.

The following variables are used in this program;

=item QADataFileType C<$!data-file-type>; You can choose from INI, JSON or TOML. By default it saves the answers in json formatted files.

=item Hash C<$!callback-objects>; User defined callback handlers. The C<$!callback-objects> have two toplevel keys, `actions` to specify action like callbacks and `checks` to have callbacks for checking the input data. The next level is a name which is defined along a question/answer entry. The value of that name key is an array. The first value is the handler object, the second is the method name, the rest are obtional pairs of values which are also provided to the method. The manager will also add some parameters to the method.

Summarized

  $!callback-objects = %(
      actions => %(
        user-key => [ $handler-object, $method-name, :myval1($val1), ...],
        ...
      ),
      checks => %(
        user-key => [ $handler-object, $method-name, :myval1($val1), ...],
        ...
      ),
    );

See also subroutine C<set-handler()>.

=item Str C<$!cfgloc-category>; Location where categories are stored. Default is C<$!HOME/.config/QAManager/Categories.d> on *nix systems.
=item Str C<$!cfgloc-sheet>; Location where sheets are stored. Default is C<$!HOME/.config/QAManager/Sheets.d> on *nix systems.
=item Str C<$!cfgloc-resource>; Location where sheets are stored or retrieved from a resources directory for your application. Default is C<./resources/Sheets> on *nix systems.

If any of C<$!cfgloc-category>, C<$!cfgloc-sheet> or C<$!cfgloc-resource> is changed, make sure that the directories exists!

=end pod

#tm:0:init:
method !init ( ) {

  $!data-file-type = QAJSON;
  $!callback-objects = %(
    actions => %(),
    checks => %(),
  );


  if $*DISTRO.is-win {
  }

  else {
    $!cfgloc-category = "$*HOME/.config/QAManager/Categories.d";
    mkdir( $!cfgloc-category, 0o760) unless $!cfgloc-category.IO.d;

    $!cfgloc-sheet = "$*HOME/.config/QAManager/Sheets.d";
    mkdir( $!cfgloc-sheet, 0o760) unless $!cfgloc-sheet.IO.d;

    $!cfgloc-resource = "./resources/Sheets";
    mkdir( $!cfgloc-resource, 0o760) unless $!cfgloc-resource.IO.d;
  }
}
