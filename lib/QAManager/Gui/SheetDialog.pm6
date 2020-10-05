#tl:1:QAManager::Gui::SheetDialog
use v6.d;

use Gnome::Gtk3::Widget;
use Gnome::Gtk3::Enums;
use Gnome::Gtk3::ScrolledWindow;
use Gnome::Gtk3::Dialog;
use Gnome::Gtk3::Grid;
use Gnome::Gtk3::Label;
use Gnome::Gtk3::Button;
use Gnome::Gtk3::Notebook;
use Gnome::Gtk3::Stack;
use Gnome::Gtk3::Assistant;

use QAManager::Gui::Set;
use QAManager::Gui::Question;
use QAManager::Gui::Dialog;
use QAManager::Gui::Frame;
use QAManager::Set;
#use QAManager::Category;
#use QAManager::Question;
use QAManager::Sheet;
use QAManager::QATypes;

#-------------------------------------------------------------------------------
=begin pod
=head1 QAManager::Gui::SheetDialog

This module shows a dialog wherein a sheet configuration is displayed. Several ways to display the sheet are available
=end pod

unit class QAManager::Gui::SheetDialog:auth<github:MARTIMM>;
also is QAManager::Gui::Dialog;

#-------------------------------------------------------------------------------
has QAManager::Sheet $!sheet;
has Hash $!user-data;
has Hash $.result-user-data;
has Array $!sets = [];

#-------------------------------------------------------------------------------
# must repeat this new call because it won't call the one of
# QAManager::Gui::SetDemoDialog
submethod new ( |c ) {
  self.bless( :GtkDialog, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD ( Str :$sheet-name, Hash :$!user-data = %() ) {
  $!sheet .= new(:$sheet-name);

  self!init-dialog;
}

#-------------------------------------------------------------------------------
method !init-dialog {

note 'sheet: ', $!sheet.perl;
  self.set-dialog-size( $!sheet.width, $!sheet.height);

#  my Int ( $total-width, $total-height) = ( 0, 0);
#  my N-GtkAllocation $alloc;

  given $!sheet.display {
    when QADialog {
    }

    when QANoteBook {
      my Gnome::Gtk3::Grid $grid = self.dialog-content;

      my Gnome::Gtk3::Notebook $notebook .= new;
      $notebook.widget-set-hexpand(True);
      $notebook.widget-set-vexpand(True);
#      $notebook.set-name();
      $grid.grid-attach( $notebook, 0, 0, 1, 1);

      self!create-button( 'cancel', 'cancel-dialog', GTK_RESPONSE_CANCEL);
      self!create-button( 'finish', 'finish-dialog', GTK_RESPONSE_OK);

      # for each page ...
#      my Int ( $max-width, $max-height) = ( 0, 0);
      my $pages := $!sheet.clone;
      for $pages -> Hash $page {

#note 'PD: ', $page.keys;
        my Hash $grid-data = self!create-page( '', $page<description>);

        # add the created page to the notebook
        $notebook.append-page(
          $grid-data<page>, Gnome::Gtk3::Label.new(:text($page<title>))
        );

        # for each set in the page ...
        my Int $grid-row = $grid-data<page-row>;
        for @($page<sets>) -> Hash $set-data {
          # set data consists of a category name and set name. Both are needed
          # to get the set data we need.
          my Str $category-name = $set-data<category>;
          my Str $set-name = $set-data<set>;
#note 'SD: ', $set-data<category>, ', ', $set-data<set>;

#note "ud: $!user-data.perl()";
#note "keys needed: $page<name>, $category-name, $set-name";
          # display the set
          my QAManager::Gui::Set $set .= new(
            :grid($grid-data<page-grid>), :$grid-row,
            :$category-name, :$set-name,
            :user-data-set-part(
              $!user-data{$page<name>}{$category-name}{$set-name}
            )
          );
          $!sets.push: $set;
          $grid-row++;
        }

#        self.show-all;
#        $alloc = $notebook.get-allocation;
#        $max-width = max( $max-width, $alloc.width);
#        $max-height = max( $max-height, $alloc.height);
#note "max w & h: $max-width, $max-height";
CATCH {.note;}
      }

#      ( $total-width, $total-height) = ( $max-width, $max-height);
    }

    when QAStack {
    }

    when QAAssistant {
    }
  }

#  self.show-all;
#  my Int ( $w, $h);
#  my List $sizes = self.dialog-content.get-preferred-size;
#note 'szs: ', $sizes.perl;
#  my N-GtkRequisition $nat-size = $sizes[0];
#  $w = $nat-size.width;
#  $h = $nat-size.height;

#  $alloc = self.get-allocation;
#  $total-width = max( $total-width, $alloc.width);
#  $total-height += $alloc.height;
#note 'alloc: ', $alloc.perl;
#  self.set-dialog-size( $total-width, $total-height);



#  $w = self.dialog-content.get-allocated-width;
#  $h = self.dialog-content.get-allocated-height;
#  self.set-dialog-size( $w, $h);
}

#-------------------------------------------------------------------------------
method !create-button (
  Str $widget-name, Str $method-name, GtkResponseType $response-type
) {
  my Hash $button-map = $!sheet.button-map // %();
  my Gnome::Gtk3::Button $button .= new;
  my Str $button-text = $widget-name;
  $button-text = $button-map{$widget-name} if ?$button-map{$widget-name};

  $button.set-name($widget-name);
  $button.set-label($button-text.tc);
  $button.register-signal( self, $method-name, 'clicked');
  self.add-action-widget( $button, $response-type)
}

#-------------------------------------------------------------------------------
method !create-page( Str $title, Str $description --> Hash ) {

  my Gnome::Gtk3::ScrolledWindow $page .= new;
  my Gnome::Gtk3::Grid $page-grid .= new;
  $page.container-add($page-grid);
  $page-grid.set-border-width(5);
  my Int $page-row = 0;

  # place page title in frame
  my QAManager::Gui::Frame $page-frame .= new(:label($title));
#  $cat-frame.set-label-align( 4e-2, 5e-1);
#  $cat-frame.widget-set-hexpand(True);
#  $cat-frame.widget-set-margin-bottom(3);
  $page-grid.grid-attach( $page-frame, 0, $page-row++, 2, 1);

  # place description as text in this frame
  given my Gnome::Gtk3::Label $page-descr .= new(:text($description)) {
    .set-line-wrap(True);
    #.set-max-width-chars(60);
    #.set-justify(GTK_JUSTIFY_LEFT);
    .widget-set-halign(GTK_ALIGN_START);
    .widget-set-margin-bottom(3);
    .widget-set-margin-start(5);
  }
  $page-frame.container-add($page-descr);

  # return bip which is used in add-set()
  %( :$page, :$page-grid, :$page-row)
}

#-------------------------------------------------------------------------------
method cancel-dialog ( ) {
  note 'dialog cancelled';
}

#-------------------------------------------------------------------------------
method finish-dialog ( ) {
  note 'dialog finished';
  $!result-user-data = $!user-data;
}
