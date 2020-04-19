use v6.d;

#-------------------------------------------------------------------------------
use Gnome::N::N-GObject;
use Gnome::N::X;

use Gnome::Gtk3::Grid;

use QAManager::Category;

#-------------------------------------------------------------------------------
unit class QAManager::App::Page::Category:auth<github:MARTIMM>;
also is Gnome::Gtk3::Grid;

#has $!;

#-------------------------------------------------------------------------------
submethod new ( |c ) {
  self.bless( :GtkGrid, |c);
}

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
#Gnome::N::debug(:on);
  #my N-GObject $no = self.get-native-object-no-reffing;
  note 'Category page created: ';#, $no;

  self.widget-set-hexpand(True);
  self.set-border-width(5);

  my QAManager::Category $c .= new(:category<x>);
  note $c.get-category-list.perl;
}
