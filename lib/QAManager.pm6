use v6.d;

use JSON::Fast;
use Config::TOML;
use Config::INI;
use Config::INI::Writer;

#-------------------------------------------------------------------------------
unit class QAManager:auth<github:MARTIMM>;

use QAManager::Category;
use QAManager::Sheet;
use QAManager::Gui::TopLevel;

#-------------------------------------------------------------------------------
# catagories are QAManager::Category classes holding sets
has Array $!categories;
has Hash $!cat-names;
has Str $!user-data-file;
has Bool $!ini;
has Bool $!toml;
has Bool $!json;

has Bool $!qa-manager-sheet;
has QAManager::Gui::TopLevel $!gui handles <
    build-invoice-page add-set set-callback-object
    >;

has QAManager::Sheet $!sheet handles <>;

#-------------------------------------------------------------------------------
submethod BUILD (
  Str :$!user-data-file, Bool :$use-filename-as-is = False,
  Bool :$!ini = False, Bool :$!toml = False, Bool :$!json = True,
  Bool :$!qa-manager-sheet = False
) {

  # keep only one type of input
  $!toml = $!json = False if $!ini;
  $!json = False if $!toml;

  # extend filename with etension
  unless $use-filename-as-is {
    $!user-data-file ~= '.ini' if $!ini;
    $!user-data-file ~= '.toml' if $!toml;
    $!user-data-file ~= '.json' if $!json;

    $!user-data-file ~= '.json' unless any( $!ini, $!toml, $!json);
  }

  $!categories = [];
  $!cat-names = %();
  $!gui .= new(:$!categories);

  unless ? $use-filename-as-is {
    my Str $pdir = $*PROGRAM-NAME.IO.basename;
    $pdir ~~ s/ \. <-[.]>+ $ //;
    $!user-data-file = "$pdir.cfg" unless ? $!user-data-file;
    mkdir( "$*HOME/.config", 0o760) unless "$*HOME/.config".IO.e;
    mkdir( "$*HOME/.config/$pdir", 0o760) unless "$*HOME/.config/$pdir".IO.e;
    $!user-data-file = "$*HOME/.config/$pdir/$!user-data-file";
  }

  my Hash $user-data;
  if $!user-data-file.IO.r {
    note "Read user data from file $!user-data-file";
    $user-data = Config::INI::parse($!user-data-file.IO.slurp) if $!ini;
    $user-data = from-toml($!user-data-file.IO.slurp) if $!toml;
    $user-data = from-json($!user-data-file.IO.slurp) if $!json;
  }

  $!gui.set-user-data($user-data);
}

#-------------------------------------------------------------------------------
method load-category (
  Str $category? is copy, Bool :$QAManager = False
  --> Bool
) {

  # get sheet from the qa managers resources if $QAManager is set True
  $category = %?RESOURCES<QAManager-sheets.cfg>.Str if $QAManager;
note $category;

  # check if Category is loaded, ok if it is
  return True if $!cat-names{$category}:exists;

  my QAManager::Category $c .= new( :$category, :$QAManager);
  if $c.is-loaded {
    $!cat-names{$category} = $!categories.elems;
    $!categories.push: $c;

  }

  $c.is-loaded
}

#-------------------------------------------------------------------------------
method get-category (
  Str $category?, UInt :$cat-index = 0
  --> QAManager::Category
) {

  if ?$category and  $!cat-names{$category}.defined {
    $!categories[$!cat-names{$category}]
  }

  elsif $cat-index < $!categories.elems {
    $!categories[$cat-index]
  }

  else {
    QAManager::Category
  }
}

#-------------------------------------------------------------------------------
method run-invoices ( ) {

  my Hash $user-data = $!gui.run-invoices;

  if $!gui.results-valid {
#TODO problems with too deep hash levels and arrays
    $!user-data-file.IO.spurt(Config::INI::Writer::dump($user-data)) if $!ini;
    $!user-data-file.IO.spurt(to-toml($user-data)) if $!toml;
    $!user-data-file.IO.spurt(to-json($user-data)) if $!json;
  }
}
