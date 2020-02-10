use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::TopLevel:auth<github:MARTIMM>;

use QATypes;

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
use Gnome::Gtk3::CheckButton;
use Gnome::Gtk3::RadioButton;
use Gnome::Gtk3::Button;
use Gnome::Gtk3::ToolButton;
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

has QAManager::Gui::Main $!main-handler handles <results-valid>;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  $!main .= new;          # main loop control
  $!main-handler .= new;  # signal handlers
  $!user-data = %();
  $!categories = [];

  $!gdk-screen .= new;
  $!css-provider .= new;
  $!style-context .= new;

  # setup style
  my $css-file = %?RESOURCES<QAManager-style.css>.Str;
  my Gnome::Glib::Error $e = $!css-provider.load-from-path($css-file);
  die $e.message if $e.is-valid;
  $!style-context.add_provider_for_screen(
    $!gdk-screen, $!css-provider, GTK_STYLE_PROVIDER_PRIORITY_USER
  );


  # setup basic window
  $!window .= new;
  $!window.register-signal( $!main-handler, 'exit-program', 'destroy');
  $!main-handler.set-toplevel-window($!window);

  $!grid .= new;
  $!grid.widget-set-hexpand(True);
  $!window.container-add($!grid);

  $!notebook .= new;
  $!notebook.widget-set-hexpand(True);
  $!notebook.widget-set-vexpand(True);
  $!grid.grid-attach( $!notebook, 0, 1, 1, 1);

  my Gnome::Gtk3::Grid $button-grid .= new;
  $button-grid.widget-set-hexpand(True);
  $!grid.grid-attach( $button-grid, 0, 2, 1, 1);

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
method build-invoice-page(
  Str $name, Str $!invoice-title, Str $description --> Hash ) {

  my Gnome::Gtk3::Grid $sheet .= new;
  $sheet.set-border-width(5);
  my Int $sheet-row = 0;

  # place category title in frame
  my Gnome::Gtk3::Frame $cat-frame .= new(:label($name));
  $cat-frame.set-label-align( 4e-2, 5e-1);
  $cat-frame.widget-set-hexpand(True);
  $cat-frame.widget-set-margin-bottom(3);
  $sheet.grid-attach( $cat-frame, 0, $sheet-row++, 2, 1);

  # place description as text in this frame
  my Gnome::Gtk3::Label $cat-descr .= new(:text($description));
  $cat-descr.set-line-wrap(True);
  $cat-descr.set-justify(GTK_JUSTIFY_LEFT);
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
  $set-grid.widget-set-hexpand(True);
  $set-frame.container-add($set-grid);

  # place set description on top
  my Gnome::Gtk3::Label $descr .= new(:text($set.description));
  $descr.set-line-wrap(True);
  $descr.set-justify(GTK_JUSTIFY_LEFT);
  $descr.widget-set-halign(GTK_ALIGN_START);
  $descr.widget-set-margin-bottom(3);
  $set-grid.grid-attach( $descr, 0, $set-row++, 3, 1);

  for @($set.get-kv)>>.kv-data -> Hash $kv {

    # on the left side a text label for the input field on the right
    # this text must take  the available space pressing fields to the right
    my Gnome::Gtk3::Label $l .= new(
      :text([~] '<b>', $kv<description> // $kv<title>, '</b>', ':')
    );
    $l.set-use-markup(True);
    $l.set-line-wrap(True);
    $l.widget-set-hexpand(True);
    $l.set-justify(GTK_JUSTIFY_LEFT);
    $l.widget-set-halign(GTK_ALIGN_START);
    $l.widget-set-valign(GTK_ALIGN_START);
    $set-grid.grid-attach( $l, 0, $set-row, 1, 1);

    # mark required fields with a bold star
    $l .= new(:text([~] ' <b>', $kv<required> ?? '*' !! '', '</b>', ' '));
    $l.set-use-markup(True);
    $l.widget-set-valign(GTK_ALIGN_START);
    $set-grid.grid-attach( $l, 1, $set-row, 1, 1);

    # fields come at the right side only using space for themselves
    # check widget field type
    my $w;
    if $kv<field> ~~ QAEntry {
      $set-row = self.text-entry(
        $set-grid, $set-row, $cat.name, $set, $kv
      );
    }

    elsif $kv<field> ~~ QACheckButton {
      $set-row = self.checkbutton-entry(
        $set-grid, $set-row, $cat.name, $set, $kv
      );
    }
#`{{
    # only when an input widget is created
    if $w.defined {
      # set a +/- button when a field has repeatable flag turned on
      if ? $kv<repeatable> {
        my Gnome::Gtk3::Image $image .= new(:filename(%?RESOURCES<Add.png>.Str));
        my Gnome::Gtk3::ToolButton $tb .= new(:icon($image));
        $tb.register-signal( $!main-handler, 'add-grid-row', 'clicked');
        $set-grid.grid-attach( $tb, 3, $set-row, 1, 1);

        $image .= new(:filename(%?RESOURCES<Delete.png>.Str));
        $tb .= new(:icon($image));
        $tb.register-signal( $!main-handler, 'delete-grid-row', 'clicked');
        $set-grid.grid-attach( $tb, 4, $set-row, 1, 1);
      }

      else {
        $set-grid.grid-attach(
          Gnome::Gtk3::Label.new(:text(' ')), 3, $set-row, 1, 1
        );
        $set-grid.grid-attach(
          Gnome::Gtk3::Label.new(:text(' ')), 4, $set-row, 1, 1
        );
      }
    }
}}

    $set-row++;
  }

  $bip<sheet-row> = $sheet-row;
  return True
}

#-------------------------------------------------------------------------------
method run-invoices ( ) {

  $!window.window-resize( 400, 1);
  $!window.show-all;

  $!main.gtk-main;

  $!main-handler.results
}

#-------------------------------------------------------------------------------
method text-entry (
  Gnome::Gtk3::Grid $set-grid, Int $set-row is copy,
  Str $cat-name, QAManager::Set $set, Hash $kv
  --> Int
) {

  my Str $text;

  if ?$kv<repeatable> {
    my Array $texts = $!user-data{$cat-name}{$set.name}{$kv<name>} // [];
    my Int $n-texts = +@$texts;
    loop ( my Int $i = 0; $i < $n-texts; $i++ ) {
      $text = $texts[$i];
      self.shape-entry(
        $text, $kv, $set-grid, $set-row,
        $!invoice-title, $cat-name, $set
      );

      my Gnome::Gtk3::Image $image .= new(
        :filename(%?RESOURCES<Delete.png>.Str)
      );
      my Gnome::Gtk3::ToolButton $tb .= new(:icon($image));
      $tb.widget-set-name('delete-tb-button');
      $tb.register-signal(
        $!main-handler, 'add-or-delete-grid-row', 'clicked',
        :grid($set-grid), :$!invoice-title, :$cat-name, :$set, :$kv
      );
      $set-grid.grid-attach( $tb, 3, $set-row, 1, 1);

      $set-row++;
      $text = Str;
    }
  }

  else {
    $text = $!user-data{$cat-name}{$set.name}{$kv<name>} // Str;
  }

  self.shape-entry(
    $text, $kv, $set-grid, $set-row,
    $!invoice-title, $cat-name, $set
  );

  if ?$kv<repeatable> {
    my Gnome::Gtk3::Image $image .= new(:filename(%?RESOURCES<Add.png>.Str));
    my Gnome::Gtk3::ToolButton $tb .= new(:icon($image));
    $tb.widget-set-name('add-tb-button');
    $tb.register-signal(
      $!main-handler, 'add-or-delete-grid-row', 'clicked',
      :grid($set-grid), :$!invoice-title, :$cat-name, :$set, :$kv
    );
    $set-grid.grid-attach( $tb, 3, $set-row, 1, 1);
  }

  $set-row
}

#-------------------------------------------------------------------------------
method shape-entry (
  Str $text, Hash $kv, Gnome::Gtk3::Grid $set-grid,
  Int $set-row, Str $!invoice-title, Str $cat-name, QAManager::Set $set
) {

  my Gnome::Gtk3::Entry $w .= new;
  $w.set-text($text) if ? $text;

  $w.widget-set-margin-top(3);
  $w.widget-set-name($kv<name>);
  $w.set-tooltip-text($kv<tooltip>) if ?$kv<tooltip>;

  $w.set-placeholder-text($kv<example>) if ?$kv<example>;
  $w.set-visibility(!$kv<invisible>);

  $set-grid.grid-attach( $w, 2, $set-row, 1, 1);
  $!main-handler.add-widget( $w, $!invoice-title, $cat-name, $set, $kv);
  $!main-handler.check-field( $w, $kv);

  $w.register-signal(
    $!main-handler, 'check-on-focus-change', 'focus-out-event',
    :field-spec($kv),
  );
}

#-------------------------------------------------------------------------------
method checkbutton-entry (
  Gnome::Gtk3::Grid $set-grid, Int $set-row,
  Str $cat-name, QAManager::Set $set, Hash $kv
  --> Int
) {

  my Bool $v = $!user-data{$cat-name}{$set.name}{$kv<name>} // Bool;

  my Gnome::Gtk3::CheckButton $w .= new;
  $w.set-active($v) if ?$v;

  $w.widget-set-margin-top(3);
  $w.widget-set-name($kv<name>);
  $w.set-tooltip-text($kv<tooltip>) if ?$kv<tooltip>;

  $set-grid.grid-attach( $w, 2, $set-row, 1, 1);
  $!main-handler.add-widget( $w, $!invoice-title, $cat-name, $set, $kv);

  $set-row
}

#-------------------------------------------------------------------------------
#method results-valid ( --> Bool ) {
#  $!main-handler.results-valid
#}





=finish
#-------------------------------------------------------------------------------
method do-invoice ( --> Hash ) {

  # build sheet for each category
  for @$!categories -> $c {
    my Gnome::Gtk3::Grid $sheet .= new;
    $sheet.set-border-width(5);
    my Int $sheet-row = 0;

    # place category title and description as first text at top of sheet
    my Gnome::Gtk3::Frame $cat-frame .= new(:label($c.name));
    $cat-frame.set-label-align( 4e-2, 5e-1);
    $sheet.grid-attach( $cat-frame, 0, $sheet-row++, 2, 1);

    my Gnome::Gtk3::Label $cat-descr .= new(:text($c.description));
    $cat-descr.set-line-wrap(True);
    $cat-descr.set-justify(GTK_JUSTIFY_LEFT);
    $cat-descr.widget-set-margin-bottom(3);
    $cat-frame.container-add($cat-descr);

    for $c.get-setnames -> $setname {
note "Set: $setname";
      my QAManager::Set $set = $c.get-set($setname);

      # each set is displayed in a frame with a grid. the frame is
      # only to expand horizontally so frames keep together
      my Gnome::Gtk3::Frame $set-frame .= new(:label($set.title));
      $set-frame.set-label-align( 4e-2, 5e-1);
      #$set-frame.set-border-width(5);
      $set-frame.widget-set-hexpand(True);
      $sheet.grid-attach( $set-frame, 0, $sheet-row++, 2, 1);

      # the grid is for displaying the input fields also only
      # strechable horizontally
      my Int $set-row = 0;
      my Gnome::Gtk3::Grid $set-grid .= new;
      $set-grid.set-border-width(5);
      $set-grid.widget-set-hexpand(True);
      $set-frame.container-add($set-grid);

      # place set description on top
      my Gnome::Gtk3::Label $descr .= new(:text($set.description));
      #$descr.set-use-markup(True);
      $descr.set-line-wrap(True);
      $descr.set-justify(GTK_JUSTIFY_LEFT);
      $descr.widget-set-halign(GTK_ALIGN_START);
      $descr.widget-set-margin-bottom(3);
      $set-grid.grid-attach( $descr, 0, $set-row++, 3, 1);

      for @($set.get-kv)>>.kv-data -> Hash $kv {

        # on the left side a text label for the input field on the right
        # this text must take  the available space pressing fields to the right
        my Gnome::Gtk3::Label $l .= new(
          :text([~] '<b>', $kv<description> // $kv<title>, '</b>', ':')
        );
        $l.set-use-markup(True);
        $l.set-line-wrap(True);
        $l.widget-set-hexpand(True);
        $l.set-justify(GTK_JUSTIFY_LEFT);
        $l.widget-set-halign(GTK_ALIGN_START);
        $l.widget-set-valign(GTK_ALIGN_START);
        $set-grid.grid-attach( $l, 0, $set-row, 1, 1);

        # mark required fields with a bold star
        $l .= new(:text([~] ' <b>', $kv<required> ?? '*' !! '', '</b>', ' '));
        $l.set-use-markup(True);
        $l.widget-set-valign(GTK_ALIGN_START);
        $set-grid.grid-attach( $l, 1, $set-row, 1, 1);

        # fields come at the right side only using space for themselves
        # check widget field type
        if $kv<field> ~~ QAEntry {
          my Gnome::Gtk3::Entry $e .= new;
          $e.widget-set-margin-top(3);
          $e.widget-set-name($kv<name>);
          $e.set-placeholder-text($kv<example>) if ?$kv<example>;
          $e.set-tooltip-text($kv<tooltip>) if ?$kv<tooltip>;
          $e.set-visibility(!$kv<invisible>);
          $set-grid.grid-attach( $e, 2, $set-row, 1, 1);
        }

        elsif $kv<field> ~~ QACheckButton {
          my Gnome::Gtk3::CheckButton $cb .= new;
          $cb.widget-set-name($kv<name>);
          $cb.widget-set-margin-top(3);
          $cb.set-tooltip-text($kv<tooltip>) if ?$kv<tooltip>;
          $set-grid.grid-attach( $cb, 2, $set-row, 1, 1);
        }

        $set-row++;
      }
    }

    $!notebook.append-page( $sheet, Gnome::Gtk3::Label.new(:text($c.title)));
  }

#  my N-GdkRectangle $r = $!window.get-allocation;
#  note "w 0: ", $r.perl;
  $!window.window-resize( 390, 1);
  $!window.show-all;

  $!main.gtk-main;

  $!main-handler.results
}
