use v6.d;

use Gnome::Gtk3::Widget;
#use Gnome::Gtk3::ComboBoxText;
use Gnome::Gtk3::StyleContext;

use QAManager::QATypes;

#-------------------------------------------------------------------------------
unit role QAManager::Gui::ValueRepr:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
method get-values ( --> Array ) {
  ...
}

#-------------------------------------------------------------------------------
method set-values ( Array $data-array, Bool :$overwrite = True ) {
  my Int $row = 0;
  for @$data-array -> $t {
    my ( $data-key, $data-value) = $t.kv;
note 'svs: ', $data-key//'--dk--', ', ', $data-value//'--dv--';
    self.set-value(
      $data-key // 0, $data-value // '', $row, :$overwrite,
      :last-row( ($row + 1) == $data-array.elems )
    );

    $row++;
  }
}

#-------------------------------------------------------------------------------
# no typing of $data-key and $data-value because data can be any
# of text-, number- or boolean
method set-value ( $data-key, $data-value, Int $row, Bool :$overwrite ) {
  ...
}

#-------------------------------------------------------------------------------
# when called, at least one row is visible. only first row will be
# set with a default unless field is already filled in.
# subsequent calls to fill data from user configs, will overwrite the content.
method set-default ( $t ) {
  my ( $data-key, $data-value) = $t.kv;
  self.set-value( $data-key, $data-value, 0, :!overwrite, :last-row);
}

#-------------------------------------------------------------------------------
method check-values ( ) {
  ...
}

#-------------------------------------------------------------------------------
method set-status-hint (
  Gnome::Gtk3::Widget $widget, inputStatusHint $status
) {
  my Gnome::Gtk3::StyleContext $context .= new(
    :native-object($widget.get-style-context)
  );

  # remove classes first
  $context.remove-class('dontcare');
  $context.remove-class('fieldOk');
  $context.remove-class('fieldFail');

#note "sts hint: {inputStatusHint($status)}";
  # add class depending on status
  if $status ~~ QAStatusNormal {
    $context.add-class('fieldNormal');
  }

  elsif $status ~~ QAStatusOk {
    $context.add-class('fieldOk');
  }

  elsif $status ~~ QAStatusFail {
    $context.add-class('fieldFail');
  }

  else {
  }
}
