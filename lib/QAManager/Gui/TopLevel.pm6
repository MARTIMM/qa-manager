use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::Gui::TopLevel:auth<github:MARTIMM>;

use QAManager::Gui::Main;

use QAManager::Category;
use QAManager::Set;
use QAManager::KV;

use Gnome::Gtk3::Main;
use Gnome::Gtk3::Window;
use Gnome::Gtk3::Notebook;
use Gnome::Gtk3::Label;
use Gnome::Gtk3::Grid;
use Gnome::Gtk3::Entry;
use Gnome::Gtk3::TextView;
use Gnome::Gtk3::Button;
use Gnome::Gtk3::CheckButton;
use Gnome::Gtk3::RadioButton;

use Gnome::N::X;
Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
has Gnome::Gtk3::Main $!main;
has Gnome::Gtk3::Window $!window;
has Gnome::Gtk3::Notebook $!notebook;

has Array $!categories = [];
has Hash $!user-data = %();

has QAManager::Gui::Main $!main-handler;

#-------------------------------------------------------------------------------
submethod BUILD ( Array :$!categories ) {

  $!main .= new;
  $!main-handler .= new;

  $!window .= new;
  $!window.register-signal( $!main-handler, 'exit-program', 'destroy');

  $!notebook .= new;
  $!window.container-add($!notebook);
}

#-------------------------------------------------------------------------------
method do-invoice ( --> Hash ) {

  # build sheet for each category
  for @$!categories -> $c {
    my Gnome::Gtk3::Grid $grid .= new;
    my Gnome::Gtk3::Label $label .= new(:text($c.title));
    $!notebook.append-page( $grid, $label);
  }


  # add each sheet to a Stack or a Notebook

  # show the starting category

  $!window.show-all;
  $!main.gtk-main;

  $!user-data
}
