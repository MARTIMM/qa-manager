use v6.d;

use JSON::Fast;
use QAManager::QATypes;

#-------------------------------------------------------------------------------
unit class QAManager::Sheet:auth<github:MARTIMM>;
also does Iterable;

#-------------------------------------------------------------------------------
# need to know if same sheet is opened elsewhere
my Hash $opened-sheets = %();

# directory to store sheets
has Str $!sheet-lib-dir;
has Str $!category-lib-dir; # for checks

# sheets are filenames holding pages of sets
has Str $!sheet is required;
has Bool $.is-changed;

# this QAManager::Sheet's pages
has Hash $!pages;
has Array $!page-data;

has Hash $!sets;
has Array $!set-data;
has Iterator $!iterator;

has Hash $!page;

has QADisplayType $.display is rw;

#-------------------------------------------------------------------------------
# TODO , Bool :$!ro
submethod BUILD ( Str:D :$!sheet ) {

  if $*DISTRO.is-win {
  }

  else {
    $!sheet-lib-dir = "$*HOME/.config";
    mkdir( $!sheet-lib-dir, 0o760) unless $!sheet-lib-dir.IO.d;
    $!sheet-lib-dir ~= '/QAManager';
    mkdir( $!sheet-lib-dir, 0o760) unless $!sheet-lib-dir.IO.d;
    $!sheet-lib-dir ~= '/QA.d';
    mkdir( $!sheet-lib-dir, 0o760) unless $!sheet-lib-dir.IO.d;

    $!category-lib-dir = $!sheet-lib-dir;
    $!category-lib-dir ~~ s/ 'QA.d' $/QAlib.d/;
    mkdir( $!category-lib-dir, 0o760) unless $!category-lib-dir.IO.d;
  }

  # implicit load of categories, clear if it fails.
  unless self.load {
    $!pages = Nil;
    $!page-data = [];
  }
}

#-------------------------------------------------------------------------------
method load ( --> Bool ) {

  # do not lead if loaded in another Sheet object
  return False if $opened-sheets{$!sheet}.defined;

  # check if Sheet is loaded, ok if it is
  return True if $!pages.defined;

  # initialize sheets
  $!pages = %();
  $!page-data = [];

  # check if Sheet file exists then load, if not, Sheet is created
  my Str $sheetfile = "$!sheet-lib-dir/$!sheet.cfg";

  if $sheetfile.IO.r {
#note "Read sheet definition from file $sheetfile";
    my Hash $sheet = from-json($sheetfile.IO.slurp);

    $!display =
      QADisplayType(QADisplayType.enums{$sheet<display>}) // QANoteBook;

    # the rest are pages
    for @($sheet<pages>) -> $h-page is copy {
      next unless ?$h-page;
# TODO test if name is defined
      $h-page<title> //= $h-page<name>.tclc;
      $h-page<description> //= $h-page<title>;

      $!pages{$h-page<name>} = $!page-data.elems;
      $!page-data.push: $h-page;
    }

    $!is-changed = False;
  }

  else {
    $!display = QANoteBook;
    $!is-changed = True;
  }

  $opened-sheets{$!sheet} = 1;

  True
}

#-------------------------------------------------------------------------------
method is-loaded ( --> Bool ) {
  $!pages.defined
}

#-------------------------------------------------------------------------------
method new-page (
  Str:D :$name, Str :$title = '', Str :$description = ''
  --> Bool
) {

  return False unless ?$name;

  return False if $!pages{$name}:exists;

  $title //= $name.tclc;
  $description //=$title;

  $!set-data = [];
  $!page = %( :$name, :$title, :$description);
  $!page<sets> := $!set-data;

  $!pages{$name} = $!page-data.elems;
  $!page-data.push: $!page;

  $!is-changed = True;
  True
}

#-------------------------------------------------------------------------------
method add-set ( Str:D :$category, Str:D :$set --> Bool ) {
# TODO check existence

  my Bool $set-ok = False;

  if "$!category-lib-dir/$category.cfg".IO.r {
    my Hash $cat = from-json("$!category-lib-dir/$category.cfg".IO.slurp);
    for @($cat<sets>) -> Hash $h-set {
      if $h-set<name> eq $set {
        $set-ok = True;
        last
      }
    }
  }

  $!set-data.push: %( :$category, :$set);

  $!is-changed = True;
  $set-ok
}

#`{{
#-------------------------------------------------------------------------------
method set-page-sets ( ) {
  $!page<sets> = $!set-data;
  $!is-changed = True;
}
}}

#-------------------------------------------------------------------------------
method remove-set ( Str:D :$category, Str:D :$set --> Bool ) {
# TODO check existence

  my Bool $removed = False;

  loop ( my Int $i = 0; $i < $!set-data.elems; $i++ ) {
    my Hash $h-set = $!set-data[$i];
    if ($h-set<category> eq $category) and ($h-set<set> eq $set) {
      $!set-data.splice( $i, 1);
      $removed = True;
      last;
    }
  }

  $!is-changed = True;
  $removed
}

#-------------------------------------------------------------------------------
method save ( --> Bool ) {

  # check if Category is loaded, ok if it is
  return False unless $!pages.defined;

  # if set name does not exist, the Category is created
  "$!sheet-lib-dir/$!sheet.cfg".IO.spurt(
    to-json( %(:$!display, :pages($!page-data)) )
  );

  $!is-changed = False;
  True
}

#-------------------------------------------------------------------------------
method save-as ( Str $new-sheet --> Bool ) {

  # check if this new sheet is loaded elsewhere
#TODO is this correct? we opened it at least ourselves
  return False if $opened-sheets{$new-sheet}.defined;

  # if set name does not exist, the new sheet is created
  "$!sheet-lib-dir/$new-sheet.cfg".IO.spurt(
    to-json( %(:$!display, :pages($!page-data)) )
  );

  # remove from sheets and rename sheet
  $opened-sheets{$!sheet}:delete;
  $!sheet = $new-sheet;
  $opened-sheets{$!sheet} = 1;

  $!is-changed = False;
  True
}

#-------------------------------------------------------------------------------
# remove from memory
method purge ( Bool :$ignore-changes = False --> Bool ) {

  # check if sheet is changed and we can ignore them
  return False unless !$!is-changed or $ignore-changes;

  # check if sheet is loaded
  return False unless $!pages.defined;

  $!pages = Nil;
  $!page-data = [];
  $opened-sheets{$!sheet}:delete;

  True
}

#-------------------------------------------------------------------------------
method delete-page ( :$name --> Bool ) {

  return False unless $!pages{$name}:exists;

  $!page-data.splice( $!pages{$name}, 1);
  for $!pages.keys -> $k {
    $!pages{$k}-- if $!pages{$k} > $!pages{$name}
  }

  $!pages{$name}:delete;
  True
}


#-------------------------------------------------------------------------------
method remove ( Str :$sheet, Bool :$ignore-changes = False --> Bool ) {

#note "D: $!sheet-lib-dir/$sheet.cfg, ", $opened-sheets{$sheet}:exists;
  # check if this sheet is loaded here, otherwise we cannot delete it
  return False unless $opened-sheets{$sheet}:exists;

  # check if file exists
  return False unless "$!sheet-lib-dir/$sheet.cfg".IO.e;

  $!pages = Nil;
  $!page-data = [];
  unlink "$!sheet-lib-dir/$sheet.cfg";
  $opened-sheets{$sheet}:delete;

  $!is-changed = False;
  True
}


#-------------------------------------------------------------------------------
# Iterator to be used in for {} statements returning pages from this sheet
method iterator ( --> Iterator ) {

note "iter";
  # Create anonymous class which does the Iterator role
  my $c = class :: does Iterator {
    has $!count = 0;
    has Array $.pdata is rw;

    method pull-one {
note "\ncount: $!count, $!pdata[$!count].perl()";

      return $!count < $!pdata.elems
        ?? $!pdata[$!count++]
        !! IterationEnd;
    }

  # Create the object for this class and return it
}.new(:pdata($!page-data));

note "CI: ", $c.perl;
$c
}

method get-pages ( --> Array ) {

  @$!page-data;
}

#`{{ TODO}}
