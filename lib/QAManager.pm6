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
has QAManager::Gui::TopLevel $!gui handles <
    build-invoice-page add-set set-callback-object
    >;

has QAManager::Sheet $!sheet; # handles <>;

#-------------------------------------------------------------------------------
submethod BUILD ( ) { }
#-------------------------------------------------------------------------------
method run-invoice (
  Str :$sheet, :$callback-handlers,
  Str :$result-file is copy, Bool :$use-filename-as-is = False,
  Bool :$save = True, Bool :$ini = False, Bool :$toml = False,
  Bool :$json is copy = True
  --> Hash
) {

  if $save {
    # keep only one type of input
    $toml = $json = False if $ini;
    $json = False if $toml;

    # extend filename with extension
    unless $use-filename-as-is {
      $result-file ~= '.ini' if $ini;
      $result-file ~= '.toml' if $toml;
      $result-file ~= '.json' if $json;

      unless any( $ini, $toml, $json) {
        $result-file ~= '.json';
        $json = True;
      }
    }
  }

  my Str $category-lib-dir = "$*HOME/.config/QAManager/QAlib.d";
  my Hash $cat-hashes = %();
  my Hash $user-data;

  # load sheet
  $!sheet .= new(:$sheet);
note "Sheet: $sheet";
  if $!sheet.is-loaded {

#TODO type of representation QADisplayType
    $!gui .= new;
    for $!sheet.get-pages -> Hash $page {
note "Bip: $page<name>, $page<title>, $page<description>";
      my Hash $bip = $!gui.build-invoice-page(
        $page<name>, $page<title>, $page<description>
      );

      for @($page<sets>) -> Hash $set {
        my Str $cat-name = $set<category>;
        my Str $set-name = $set<set>;

        $cat-hashes{$cat-name} = QAManager::Category.new(:category($cat-name))
          if $cat-hashes{$cat-name}:!exists;

        $!gui.add-set( $bip, $cat-hashes{$cat-name}, $set-name);
      }
    }

    $!gui.set-callback-object($callback-handlers) if ?$callback-handlers;

    $user-data = $!gui.run-invoice;

    if $!gui.results-valid and $save {
      $result-file.IO.spurt(Config::INI::Writer::dump($user-data)) if $ini;
      $result-file.IO.spurt(to-toml($user-data)) if $toml;
      $result-file.IO.spurt(to-json($user-data)) if $json;
    }
  }

  $!gui.results-valid ?? $user-data !! Hash
}




=finish
#-------------------------------------------------------------------------------
# catagories are QAManager::Category classes holding sets
has Array $!categories;
has Hash $!cat-names;
has Str $!result-file;
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
  Str :$!result-file, Bool :$use-filename-as-is = False,
  Bool :$!ini = False, Bool :$!toml = False, Bool :$!json = True,
  Bool :$!qa-manager-sheet = False
) {

  # keep only one type of input
  $!toml = $!json = False if $!ini;
  $!json = False if $!toml;

  # extend filename with extension
  unless $use-filename-as-is {
    $!result-file ~= '.ini' if $!ini;
    $!result-file ~= '.toml' if $!toml;
    $!result-file ~= '.json' if $!json;

    $!result-file ~= '.json' unless any( $!ini, $!toml, $!json);
  }

  $!categories = [];
  $!cat-names = %();
  $!gui .= new(:$!categories);

  unless ? $use-filename-as-is {
    my Str $pdir = $*PROGRAM-NAME.IO.basename;
    $pdir ~~ s/ \. <-[.]>+ $ //;
    $!result-file = "$pdir.cfg" unless ? $!result-file;
    mkdir( "$*HOME/.config", 0o760) unless "$*HOME/.config".IO.e;
    mkdir( "$*HOME/.config/$pdir", 0o760) unless "$*HOME/.config/$pdir".IO.e;
    $!result-file = "$*HOME/.config/$pdir/$!result-file";
  }

  my Hash $user-data;
  if $!result-file.IO.r {
    note "Read user data from file $!result-file";
    $user-data = Config::INI::parse($!result-file.IO.slurp) if $!ini;
    $user-data = from-toml($!result-file.IO.slurp) if $!toml;
    $user-data = from-json($!result-file.IO.slurp) if $!json;
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
    $!result-file.IO.spurt(Config::INI::Writer::dump($user-data)) if $!ini;
    $!result-file.IO.spurt(to-toml($user-data)) if $!toml;
    $!result-file.IO.spurt(to-json($user-data)) if $!json;
  }
}
