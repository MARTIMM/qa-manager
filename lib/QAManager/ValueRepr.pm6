use v6.d;

use Gnome::Gtk3::ComboBoxText;

unit class QAManager::ValueRepr:auth<github:MARTIMM>;
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
method get-values ( --> Array ) {
  ...
}

#-------------------------------------------------------------------------------
method set-values ( Array $data-array, Bool :$overwrite = True ) {
  my Int $row = 0;
  for @$data-array -> $t {
    my ( $data-key, $data-value) = $t.kv;
    self.set-value(
      $data-key//0, $data-value//'', $row, :$overwrite,
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
