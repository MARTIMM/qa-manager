use v6.d;

use Gnome::Gtk3::Widget;
#use Gnome::Gtk3::ComboBoxText;
use Gnome::Gtk3::StyleContext;

use QAManager::QATypes;

#-------------------------------------------------------------------------------
=begin pod

=end pod

unit role QAManager::Gui::Value:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
has Array $!values = [];

#-------------------------------------------------------------------------------
# no typing of $data-key and $data-value because data can be any
# of text-, number- or boolean
method set-value ( $data-key, $data-value, Int $row, Bool :$overwrite ) {
  ...
}

#-------------------------------------------------------------------------------
# no typing for return value because it can be a single value, an Array of
# single values or and Array of Pairs.
method get-value ( --> Any ) {
  ...
}

#-------------------------------------------------------------------------------
method check-value ( ) {
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
method set-status-hint (
  Gnome::Gtk3::Widget $widget, InputStatusHint $status
) {
  my Gnome::Gtk3::StyleContext $context .= new(
    :native-object($widget.get-style-context)
  );

  # remove classes first
  $context.remove-class('dontcare');
  $context.remove-class('fieldOk');
  $context.remove-class('fieldFail');

#note "sts hint: {InputStatusHint($status)}";
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





=finish

#-------------------------------------------------------------------------------
method get-values ( --> Array ) {
  ...
}

#-------------------------------------------------------------------------------
method set-values ( Array $data-array, Bool :$overwrite = True ) {
  my Int $row = 0;
  for @$data-array -> $t {
    my ( $data-key, $data-value) = $t.kv;
#note 'svs: ', $data-key//'--dk--', ', ', $data-value//'--dv--';
    self.set-value(
      $data-key // 0, $data-value // '', $row, :$overwrite,
      :last-row( ($row + 1) == $data-array.elems )
    );

    $row++;
  }
}
