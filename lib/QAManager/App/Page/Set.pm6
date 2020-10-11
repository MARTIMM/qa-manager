use v6.d;

#-------------------------------------------------------------------------------
use Gnome::N::N-GObject;
use Gnome::N::X;

use Gnome::GObject::Type;
use Gnome::GObject::Value;

use Gnome::Gdk3::Events;
use Gnome::Gdk3::Types;
use Gnome::Gdk3::Window;

use Gnome::Gtk3::Menu;
use Gnome::Gtk3::Builder;
use Gnome::Gtk3::Grid;
use Gnome::Gtk3::TreeStore;
use Gnome::Gtk3::TreeView;
use Gnome::Gtk3::TreeViewColumn;
use Gnome::Gtk3::ScrolledWindow;
use Gnome::Gtk3::CellRendererText;
use Gnome::Gtk3::TreePath;
use Gnome::Gtk3::TreeIter;
use Gnome::Gtk3::Dialog;

use QAManager::Category;
use QAManager::Set;
use QAManager::KV;
use QAManager::Gui::YNMsgDialog;
use QAManager::Gui::Part::Set;

#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
unit class QAManager::App::Page::Set:auth<github:MARTIMM>;
also is Gnome::Gtk3::Grid;

enum set-columns < CatSetQAColumn QATypeColumn CatNameColumn SetNameColumn >;

has Gnome::Gtk3::TreeStore $!set-table-store;
has Gnome::Gtk3::TreeView $!set-table-view;
has Str $!rbase-path is required;
#has $!app;
#has $!app-window;
has Array $!selected-path;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  self.bless( :GtkGrid, |c);
}

#-------------------------------------------------------------------------------
#submethod BUILD ( :$!app, :$!app-window, :$!rbase-path ) {
submethod BUILD ( Str:D :$!rbase-path ) {

  my Gnome::Gtk3::Menu ( $set-menu, $qa-menu) = self!create-set-menus;

  # set the basic properties for the grid (=self)
  self.widget-set-hexpand(True);
  self.set-border-width(5);

  my Gnome::Gtk3::ScrolledWindow $scrolled-treeview = self!create-treeview(
    $set-menu, $qa-menu
  );
  self.gtk-grid-attach( $scrolled-treeview, 0, 0, 1, 1);
}

#-------------------------------------------------------------------------------
method !create-treeview (
  Gnome::Gtk3::Menu $set-menu, Gnome::Gtk3::Menu $qa-menu
  --> Gnome::Gtk3::ScrolledWindow
) {

  # Display a TreeView using a TreeStore model of available categories with
  # the defined sets and QA entries. The TreeView is wrapped in a scrollable
  # window. This will prevent that the window can grow larger than the
  # computer display.
  my Gnome::Gtk3::ScrolledWindow $scrolled-treeview .= new;

  $!set-table-store .= new(:field-types(
    G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING)
  );
  $!set-table-view .= new(:model($!set-table-store));
  $!set-table-view.set-hexpand(1);
  $!set-table-view.set-vexpand(1);
  $!set-table-view.set-headers-visible(1);
  $!set-table-view.set-activate-on-single-click(True);
  $!set-table-view.register-signal(
    self, 'show-menu', 'row-activated', :$set-menu, :$qa-menu
  );
  $scrolled-treeview.container-add($!set-table-view);

  self!treeview-column( CatSetQAColumn, 'Category > Set > QA Entry', 'blue');
  self!treeview-column( QATypeColumn, 'QA Entry Type', '#aa00bb');
  self!treeview-column( CatNameColumn, '');
  self!treeview-column( SetNameColumn, '');

  #my Gnome::Gtk3::TreeIter ( $set-iter, $qa-iter, $qa-child-iter);
  my Gnome::Gtk3::TreeIter ( $set-iter, $qa-iter);
  my QAManager::Category $cx .= new(:category<_NON_EXISTENT_CAT_NAME_>);
  for $cx.get-category-list.sort -> Str $category {

    # $set-iter and other iterators are used after insertions and will
    # be updated to hold the current inserted table row.
    $set-iter = $!set-table-store.insert-with-values(
      N-GtkTreePath, -1, CatSetQAColumn, $category, CatNameColumn, $category
    );

    my QAManager::Category $cat .= new(:$category);
    for $cat.get-setnames -> $set-name {

      $qa-iter = $!set-table-store.insert-with-values(
        $set-iter, -1, CatSetQAColumn, $set-name, CatNameColumn, $category,
        SetNameColumn, $set-name
      );

      my QAManager::Set $set = $cat.get-set($set-name);
      for @($set.get-kv) -> QAManager::KV $kv {

        ## $qa-child-iter is not really used but needed to clear the object.
        ## later it will be done in one go.
        #$qa-child-iter = $!set-table-store.insert-with-values(
        $!set-table-store.insert-with-values(
          $qa-iter, -1, CatSetQAColumn, $kv.name,
          QATypeColumn, ($kv.field // 'QAEntry').Str,
          CatNameColumn, $category, SetNameColumn, $set-name
        );
      }
    }
  }

  $scrolled-treeview
}

#-------------------------------------------------------------------------------
# define a column entry in the treeview. when $header is empty, the column
# will not be visible. the default $color will be black (#000).
method !treeview-column ( Int $column, Str $header, Str $color? is copy ) {

  my Gnome::Gtk3::CellRendererText $crt .= new;
  $color = '#000' unless ?$color;
  my Gnome::GObject::Value $v .= new( :type(G_TYPE_STRING), :value($color));
  $crt.set-property( 'foreground', $v);
  $v.clear-object;

  my Gnome::Gtk3::TreeViewColumn $tvc .= new;
  $tvc.set-title($header);
  $tvc.pack-end( $crt, 1);
  $tvc.add-attribute( $crt, 'text', $column);
  $tvc.set_visible(?$header);
  $!set-table-view.append-column($tvc);
}

#-------------------------------------------------------------------------------
method !create-set-menus ( --> List ) {

  # read the menu xml into the builder
  my Gnome::Gtk3::Builder $builder .= new(:resource(
      $!rbase-path ~ '/resources/g-resources/QASet-menu.xml'
    )
  );

  # get the menu objects
  my Gnome::Gtk3::Menu $set-menu .= new(:build-id<set-menu>);
  $set-menu.show-all;

  my Gnome::Gtk3::Menu $qa-menu .= new(:build-id<qa-menu>);
  $qa-menu.show-all;

  # prepare handlers for the menu
  my Hash $handlers = %(
    :show-set(self), :set-edit(self), :set-add(self), :set-delete(self),
    :qa-up(self), :qa-down(self), :qa-edit(self), :qa-add(self),
    :qa-delete(self),
  );

  # connect signals to handlers
  $builder.connect-signals-full($handlers);

  ( $set-menu, $qa-menu)
}

#-------------------------------------------------------------------------------
method !get-path-values ( --> List ) {

  my Gnome::Gtk3::TreePath $selected .= new(:indices($!selected-path));
  my Gnome::Gtk3::TreeIter $iter = $!set-table-store.get-iter($selected);

  my Array[Gnome::GObject::Value] $va = $!set-table-store.get-value(
    $iter, CatNameColumn, SetNameColumn
  );

  my Str $cat-name = $va[0].get-string;
  $va[0].clear-object;
  my Str $set-name = $va[1].get-string;
  $va[1].clear-object;

  $selected.clear-object;

note "values from \($!selected-path\): $cat-name, $set-name";
  ( $cat-name, $set-name )
}

#--[ handlers ]-----------------------------------------------------------------
method show-menu (
  N-GtkTreePath $n-tree-path, N-GObject $n-treeview-column,
  Gnome::Gtk3::Menu :$set-menu, Gnome::Gtk3::Menu :$qa-menu
  --> Int
 ) {
  # do not free path, it is owned by the caller.
  my Gnome::Gtk3::TreePath $path .= new(:native-object($n-tree-path));
  $!selected-path = $path.gtk_tree_path_get_indices;
note 'Show Menu: ', $!selected-path.Str;

  my N-GdkRectangle $rect = $!set-table-view.get-cell-area(
    $n-tree-path, $n-treeview-column
  );
#note "R: $rect.x(), $rect.y(), $rect.width(), $rect.height()";

  # expand or collapse a row
  if $!set-table-view.row-expanded($n-tree-path) {

    # if open, collapse and don't show any menu but only on top row
    $!set-table-view.collapse-row($n-tree-path)
      if $!selected-path.elems == 1;
  }

  else {
    # if collapsed, open and show a menu if any
    $!set-table-view.expand-row( $n-tree-path, True);
  }

    # entries have 3 indices, show $qa-menu
    if $!selected-path.elems == 3 {
      $qa-menu.popup-at-rect(
        $!set-table-view.get-window, $rect,
        GDK_GRAVITY_CENTER, GDK_GRAVITY_NORTH, N-GdkEvent
      );
    }

    # sets have two indices, show $set-menu
    elsif $!selected-path.elems == 2 {
      $set-menu.popup-at-rect(
        $!set-table-view.get-window, $rect,
        GDK_GRAVITY_CENTER, GDK_GRAVITY_NORTH, N-GdkEvent
      );
    }
#  }

  1
}

#-------------------------------------------------------------------------------
# $!selected-path is filled in by method show-menu() with indices after
# receiving a button click.
method show-set ( Hash :$part-user-data = %() ) {
#Gnome::N::debug(:on);

  return unless $!selected-path.defined; # and $!selected-path.elems == 1;
  note 'Show set';

  my Str ( $category, $set-name) = |(self!get-path-values);
  my QAManager::Gui::Part::Set $set-demo-dialog .= new(
    :$category, :$set-name, :$part-user-data
  );
  my Int $response = $set-demo-dialog.show-dialog;
  if $response ~~ GTK_RESPONSE_CLOSE {
    note 'dialog closed: ', $set-demo-dialog.dialog-content;
  }

  $set-demo-dialog.widget-destroy;
}

#-------------------------------------------------------------------------------
method set-edit ( ) {
  note 'Set edit';
}

#-------------------------------------------------------------------------------
method set-add ( ) {
  note 'Add set';
}

#-------------------------------------------------------------------------------
method set-delete ( ) {
  # set entries are at depth 2
  return unless $!selected-path.defined; # and $!selected-path.elems == 2;

#`{{
  my Gnome::Gtk3::TreeIter $iter = $!set-table-store.get-iter(
    Gnome::Gtk3::TreePath.new(:indices($!selected-path))
  );

  my Array[Gnome::GObject::Value] $va = $!set-table-store.get-value(
    $iter, CatNameColumn, SetNameColumn
  );

  my Str $cat-name = $va[0].get-string;
  $va[0].clear-object;
  my Str $set-name = $va[1].get-string;
  $va[1].clear-object;
}}
  my Str ( $cat-name, $set-name) = self!get-path-values;

  #
  my QAManager::Gui::YNMsgDialog $dm .= new(
    :message("set <b>$set-name\</b> from <b>$cat-name\</b>")
  );

  if GtkResponseType($dm.gtk-dialog-run) ~~ GTK_RESPONSE_YES {
    my QAManager::Category $c .= new(:category($cat-name));
    $c.delete-set($set-name);

    # save new set and clear category
    $c.save;
#    $c.purge;

    # remove entry from treeview, entries on lower level disappear too
    my Gnome::Gtk3::TreePath $path .= new(:indices($!selected-path));
    $!set-table-store.tree-store-remove($!set-table-store.get-iter($path));
    $path.clear-object;
  }

  $dm.widget-destroy;
}

#-------------------------------------------------------------------------------
method qa-up ( ) {
  note 'QA up';
}

#-------------------------------------------------------------------------------
method qa-down ( ) {
  note 'QA down';
}

#-------------------------------------------------------------------------------
method qa-edit ( ) {
  note 'Edit QA';
}

#-------------------------------------------------------------------------------
method qa-add ( ) {
  note 'Add QA';
}

#-------------------------------------------------------------------------------
method qa-delete ( ) {

  # qa entries are at depth 3
  return unless $!selected-path.defined; # and $!selected-path.elems == 3;

  my Gnome::Gtk3::TreeIter $iter = $!set-table-store.get-iter(
    Gnome::Gtk3::TreePath.new(:indices($!selected-path))
  );
  my Array[Gnome::GObject::Value] $va = $!set-table-store.get-value(
    $iter, CatSetQAColumn
  );

  my Str $qa-name = $va[0].get-string;
  $va[0].clear-object;

  my QAManager::Gui::YNMsgDialog $dm .= new(
    :message("question entry <b>$qa-name\</b>")
  );

  if GtkResponseType($dm.gtk-dialog-run) ~~ GTK_RESPONSE_YES {
    note 'remove question';
  }

  else {
    note 'question not removed';
  }

  $dm.widget-destroy;
}
