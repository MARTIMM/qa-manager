use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::TopLevel:auth<github:MARTIMM>;

use QAManager::QATypes;
use QAManager::Gui::Main;
use QAManager::Category;
use QAManager::Set;
use QAManager::KV;

use Gnome::Glib::Error;
#use Gnome::Gdk3::Types;
use Gnome::Gdk3::Screen;
use Gnome::Gtk3::Enums;
use Gnome::Gtk3::Main;

use Gnome::Gtk3::Window;
use Gnome::Gtk3::Notebook;
use Gnome::Gtk3::Label;
use Gnome::Gtk3::Frame;
use Gnome::Gtk3::Grid;
use Gnome::Gtk3::Entry;
use Gnome::Gtk3::TextView;
use Gnome::Gtk3::TextBuffer;
use Gnome::Gtk3::CheckButton;
use Gnome::Gtk3::ComboBoxText;
use Gnome::Gtk3::RadioButton;
use Gnome::Gtk3::Button;
use Gnome::Gtk3::ToolButton;
use Gnome::Gtk3::Switch;
use Gnome::Gtk3::Image;
use Gnome::Gtk3::Widget;
use Gnome::Gtk3::CssProvider;
use Gnome::Gtk3::StyleContext;
use Gnome::Gtk3::StyleProvider;

use Gnome::N::X;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
has Gnome::Gtk3::Main $!main;
has Gnome::Gtk3::Window $!window;
has Gnome::Gtk3::Grid $!grid;
has Gnome::Gtk3::Notebook $!notebook;

has Gnome::Gdk3::Screen $!gdk-screen;
has Gnome::Gtk3::CssProvider $!css-provider;
has Gnome::Gtk3::StyleContext $!style-context;

has Array $!categories;
has Hash $!user-data;
has Str $!invoice-title;

has QAManager::Gui::Main $!main-handler handles <
    results-valid set-callback-object
    >;

#-------------------------------------------------------------------------------
#TODO type of representation QADisplayType
submethod BUILD ( ) {

  $!main .= new;          # main loop control
  $!main-handler .= new;  # signal handlers
  $!user-data = %();
  $!categories = [];

  $!gdk-screen .= new;
  $!css-provider .= new;
  $!style-context .= new;

  # setup style
  my $css-file = %?RESOURCES<g-resources/QAManager-style.css>.Str;
  my Gnome::Glib::Error $e = $!css-provider.load-from-path($css-file);
  die $e.message if $e.is-valid;
  $!style-context.add_provider_for_screen(
    $!gdk-screen, $!css-provider, GTK_STYLE_PROVIDER_PRIORITY_USER
  );

  # setup basic window
  $!window .= new;
  $!window.register-signal( $!main-handler, 'exit-program', 'destroy');
  $!main-handler.set-toplevel-window($!window);

  # a grid is placed in this window
  $!grid .= new;
  $!grid.widget-set-hexpand(True);
  $!window.container-add($!grid);

#TODO type of representation QADisplayType
  # in this grid a notebook at ( 0, 0)
  $!notebook .= new;
  $!notebook.widget-set-hexpand(True);
  $!notebook.widget-set-vexpand(True);
  $!grid.grid-attach( $!notebook, 0, 0, 1, 1);

  # and another grid for buttons at ( 0, 1)
  my Gnome::Gtk3::Grid $button-grid .= new;
  $button-grid.widget-set-hexpand(True);
  $!grid.grid-attach( $button-grid, 0, 1, 1, 1);

  # insert a space eating all available space. this will push
  # the buttons to the right
  my Gnome::Gtk3::Label $space .= new(:text(' '));
  $space.widget-set-hexpand(True);
  $button-grid.grid-attach( $space, 0, 0, 1, 1);

  my Gnome::Gtk3::Button $cancel-button .= new(:label<Cancel>);
  $cancel-button.register-signal( $!main-handler, 'cancel-program', 'clicked');
  $button-grid.grid-attach( $cancel-button, 1, 0, 1, 1);

  my Gnome::Gtk3::Button $finish-button .= new(:label<Finish>);
  $finish-button.register-signal( $!main-handler, 'finish-program', 'clicked');
  $button-grid.grid-attach( $finish-button, 2, 0, 1, 1);
}

#-------------------------------------------------------------------------------
method build-invoice-page( Str $!invoice-title, Str $description --> Hash ) {

  my Gnome::Gtk3::Grid $sheet .= new;
  $sheet.set-border-width(5);
  my Int $sheet-row = 0;

  # place category title in frame
  my Gnome::Gtk3::Frame $cat-frame .= new;
  $cat-frame.set-label-align( 4e-2, 5e-1);
  $cat-frame.widget-set-hexpand(True);
  $cat-frame.widget-set-margin-bottom(3);
  $sheet.grid-attach( $cat-frame, 0, $sheet-row++, 2, 1);

  # place description as text in this frame
  my Gnome::Gtk3::Label $cat-descr .= new(:text($description));
  $cat-descr.set-line-wrap(True);
  #$cat-descr.set-max-width-chars(60);
  #$cat-descr.set-justify(GTK_JUSTIFY_LEFT);
  $cat-descr.widget-set-halign(GTK_ALIGN_START);
  $cat-descr.widget-set-margin-bottom(3);
  $cat-descr.widget-set-margin-start(5);
  $cat-frame.container-add($cat-descr);

  $!notebook.append-page(
    $sheet, Gnome::Gtk3::Label.new(:text($!invoice-title))
  );

  # return bip which is used in add-set()
  %( :$sheet, :$sheet-row)
}

#-------------------------------------------------------------------------------
method set-user-data ( Hash $data ) {
  $!user-data = $data // %();
}

#-------------------------------------------------------------------------------
method add-set (
  Hash $bip, QAManager::Category $cat, Str $set-name
  --> Bool
) {

  my Gnome::Gtk3::Grid $sheet = $bip<sheet>;
  my Int $sheet-row = $bip<sheet-row>;

  my QAManager::Set $set = $cat.get-set($set-name);
  return False unless $set.defined;

  # each set is displayed in a frame with a grid. the frame is
  # only to expand horizontally so frames keep together
  my Gnome::Gtk3::Frame $set-frame .= new(:label($set.title));
  $set-frame.set-label-align( 4e-2, 5e-1);
  $set-frame.widget-set-margin-bottom(3);
  #$set-frame.set-border-width(5);
  $set-frame.widget-set-hexpand(True);
  $sheet.grid-attach( $set-frame, 0, $sheet-row++, 2, 1);

  # the grid is for displaying the input fields also only
  # strechable horizontally
  my Int $set-row = 0;
  my Gnome::Gtk3::Grid $set-grid .= new;
  $set-grid.set-border-width(5);
  #$set-grid.set-row-spacing(5);
  $set-grid.widget-set-hexpand(True);
  $set-frame.container-add($set-grid);

  # place set description on top
  my Gnome::Gtk3::Label $descr .= new(:text($set.description));
  $descr.set-line-wrap(True);
  #$descr.set-max-width-chars(60);
  #$descr.set-justify(GTK_JUSTIFY_LEFT);
  $descr.widget-set-halign(GTK_ALIGN_START);
  $descr.widget-set-margin-bottom(3);
  $set-grid.grid-attach( $descr, 0, $set-row++, 3, 1);

  for @($set.get-kv)>>.kv-data -> Hash $kv {

    # show a label on the left
    self.shape-label( $set-grid, $set-row, $set, $kv);

    # show a field on the right
    if $kv<field> ~~ QAEntry {
      $set-row = self.text-field( $set-grid, $set-row, $set, $kv);
    }

    elsif $kv<field> ~~ QASwitch {
      self.switch-field( $set-grid, $set-row, $set, $kv);
    }

    elsif $kv<field> ~~ QAComboBox {
      self.combobox-field( $set-grid, $set-row, $set, $kv);
    }

    elsif $kv<field> ~~ QACheckButton {
      self.checkbutton-field( $set-grid, $set-row, $set, $kv);
    }

    elsif $kv<field> ~~ QATextView {
      self.textview-field( $set-grid, $set-row, $set, $kv);
    }

    $set-row++;
  }

  $bip<sheet-row> = $sheet-row;
  return True
}

#-------------------------------------------------------------------------------
method run-invoice ( ) {

  # set maximum width and show all widgets. the size-request gets rid of too
  # much vertical space caused by multiline label widgets. the resize will set
  # the window at its proper size.
  $!window.set-size-request( 550, 1);
  $!window.window-resize( 550, 1);
  $!window.show-all;

  # start main loop
  $!main.gtk-main;

  # after returning from main loop, return the results from the callback
  # handler to the QA manager.
  $!main-handler.results
}

#-------------------------------------------------------------------------------
# on the left side a text label for the input field on the right
# this text must take  the available space pressing fields to the right
method shape-label (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::Set $set, Hash $kv
) {

  my Gnome::Gtk3::Label $l .= new(
    :text([~] '<b>', $kv<description> // $kv<title>, '</b>', ':')
  );
  $l.set-use-markup(True);
  $l.widget-set-hexpand(True);
  $l.set-line-wrap(True);
  #$l.set-max-width-chars(40);
  $l.set-justify(GTK_JUSTIFY_LEFT);
  $l.widget-set-halign(GTK_ALIGN_START);
  $l.widget-set-valign(GTK_ALIGN_START);
  $set-grid.grid-attach( $l, 0, $set-row, 1, 1);

  # mark required fields with a bold star
  $l .= new(:text([~] ' <b>', $kv<required> ?? '*' !! '', '</b>', ' '));
  $l.set-use-markup(True);
  $l.widget-set-valign(GTK_ALIGN_START);
  $set-grid.grid-attach( $l, 1, $set-row, 1, 1);
}

#-------------------------------------------------------------------------------
method text-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row is copy,
  QAManager::Set $set, Hash $kv
  --> Int
) {

  my Str $text;

  # existing entries get a 'x' toolbar button
  if ?$kv<repeatable> {
    my Array $texts = $!user-data{$set.name}{$kv<name>} // [];
    my Int $n-texts = +@$texts;
    loop ( my Int $i = 0; $i < $n-texts; $i++ ) {
      $text = $texts[$i];
      self.shape-text-field(
        $text, $kv, $set-grid, $set-row, $!invoice-title, $set
      );

      my Gnome::Gtk3::Image $image .= new(
        :filename(%?RESOURCES<Delete.png>.Str)
      );
      my Gnome::Gtk3::ToolButton $tb .= new(:icon($image));
      $tb.widget-set-name('delete-tb-button');
      $tb.register-signal(
        $!main-handler, 'add-or-delete-grid-row', 'clicked',
        :$!invoice-title, :$set, :$kv
      );
      $set-grid.grid-attach( $tb, 3, $set-row, 1, 1);

      $set-row++;
      $text = Str;
    }
  }

  else {
    $text = $!user-data{$set.name}{$kv<name>} // Str;
  }

  self.shape-text-field(
    $text, $kv, $set-grid, $set-row, $!invoice-title, $set
  );

  # last entry gets a '+' toolbar button
  if ?$kv<repeatable> {
    my Gnome::Gtk3::Image $image .= new(:filename(%?RESOURCES<Add.png>.Str));
    my Gnome::Gtk3::ToolButton $tb .= new(:icon($image));
    $tb.widget-set-name('add-tb-button');
    $tb.register-signal(
      $!main-handler, 'add-or-delete-grid-row', 'clicked',
      :$!invoice-title, :$set, :$kv
    );
    $set-grid.grid-attach( $tb, 3, $set-row, 1, 1);
  }

  $set-row
}

#-------------------------------------------------------------------------------
method shape-text-field (
  Str $text, Hash $kv, Gnome::Gtk3::Grid $set-grid,
  Int $set-row, Str $!invoice-title, QAManager::Set $set
) {

  my Gnome::Gtk3::Entry $w .= new;
  $w.set-text($text) if ? $text;

  $w.widget-set-margin-top(3);
  $w.set-size-request( 200, 1);
  $w.widget-set-name($kv<name>);
  $w.set-tooltip-text($kv<tooltip>) if ?$kv<tooltip>;

  $w.set-placeholder-text($kv<example>) if ?$kv<example>;
  $w.set-visibility(!$kv<invisible>);

  $set-grid.grid-attach( $w, 2, $set-row, 1, 1);
  $!main-handler.add-widget( $w, $!invoice-title, $set, $kv);
  $!main-handler.check-field( $w, $kv);

  $w.register-signal(
    $!main-handler, 'check-on-focus-change', 'focus-out-event', :$kv,
  );
}

#-------------------------------------------------------------------------------
method textview-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::Set $set, Hash $kv
) {

  my Gnome::Gtk3::Frame $frame .= new;
  $frame.set-shadow-type(GTK_SHADOW_ETCHED_IN);
  $frame.widget-set-margin-top(3);

  my Gnome::Gtk3::TextView $w .= new;
  $frame.container-add($w);

  #$w.widget-set-margin-top(6);
#note "set widget height: $kv.perl(), ", $kv<height> // 50;
  $w.set-size-request( 1, $kv<height> // 50);
  $w.widget-set-name($kv<name>);
  $w.set-tooltip-text($kv<tooltip>) if ?$kv<tooltip>;
  $w.set-wrap-mode(GTK_WRAP_WORD);

#  $w.set-placeholder-text($kv<example>) if ?$kv<example>;
#  $w.set-visibility(!$kv<invisible>);

  my Gnome::Gtk3::TextBuffer $tb .= new(:native-object($w.get-buffer));
  my Str $text = $!user-data{$set.name}{$kv<name>} // '';
  $tb.set-text( $text, $text.chars);

  $set-grid.grid-attach( $frame, 2, $set-row, 1, 1);
  $!main-handler.add-widget( $w, $!invoice-title, $set, $kv);
}

#-------------------------------------------------------------------------------
method switch-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::Set $set, Hash $kv
) {

  # the switch is streched to the full width of the grid cell. this is ugly!
  # to prevent this, create another grid to place the switch in. This is
  # usually enough. here however, the switch must be justified to the right,
  # so place a label in the first cell eating all available space. this will
  # push the switch to the right.
  my Gnome::Gtk3::Grid $g .= new;
  my Gnome::Gtk3::Label $l .= new(:text(''));
  $l.widget-set-hexpand(True);
  $g.grid-attach( $l, 0, 0, 1, 1);

  my Gnome::Gtk3::Switch $w .= new;
  my Bool $v = $!user-data{$set.name}{$kv<name>} // Bool;
  $w.set-active($v) if ?$v;

  $w.widget-set-margin-top(3);
  $w.widget-set-name($kv<name>);
  $w.set-tooltip-text($kv<tooltip>) if ?$kv<tooltip>;

  $g.grid-attach( $w, 1, 0, 1, 1);
  $set-grid.grid-attach( $g, 2, $set-row, 1, 1);
  $!main-handler.add-widget( $w, $!invoice-title, $set, $kv);
}

#-------------------------------------------------------------------------------
method checkbutton-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::Set $set, Hash $kv
) {

  # A series of checkbuttons are stored in a grid
  my Gnome::Gtk3::Grid $g .= new;
  $g.widget-set-name('checkbutton-grid');

  # user data is stored as a hash to make the check more easily
  my Array $v = $!user-data{$set.name}{$kv<name>} // [];
  my Hash $reversed-v = $v.kv.reverse.hash;

  my Int $rc = 0;
  for @($kv<values>) -> $vname {
    my Gnome::Gtk3::CheckButton $w .= new(:label($vname));
    $w.set-active($reversed-v{$vname}:exists);
    $w.widget-set-name($kv<name>);
    $w.widget-set-margin-top(3);
    $w.set-tooltip-text($kv<tooltip>) if ?$kv<tooltip>;
    $g.grid-attach( $w, 0, $rc++, 1, 1);
  }

  $set-grid.grid-attach( $g, 2, $set-row, 1, 1);
  $!main-handler.add-widget( $g, $!invoice-title, $set, $kv);
}

#-------------------------------------------------------------------------------
method combobox-field (
  Gnome::Gtk3::Grid $set-grid, Int $set-row, QAManager::Set $set, Hash $kv
) {

  my Gnome::Gtk3::ComboBoxText $w .= new;
  for @($kv<values>) -> $cbv {
    $w.append-text($cbv);
  }

  my Str $v = $!user-data{$set.name}{$kv<name>} // Str;
  if ?$v {
    my Int $value-index = $kv<values>.first( $v, :k) // 0;
    $w.set-active($value-index);
  }

  $w.widget-set-margin-top(3);
  $w.widget-set-name($kv<name>);
  $w.set-tooltip-text($kv<tooltip>) if ?$kv<tooltip>;

  $set-grid.grid-attach( $w, 2, $set-row, 1, 1);
  $!main-handler.add-widget( $w, $!invoice-title, $set, $kv);
}
