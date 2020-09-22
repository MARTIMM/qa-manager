use v6.d;

use QAManager::QATypes;

#-------------------------------------------------------------------------------
unit class QAManager::Sheet:auth<github:MARTIMM>;
also does Iterable;

#-------------------------------------------------------------------------------
# sheets are filenames holding pages of sets
has Str $!sheet is required;

# this QAManager::Sheet's pages
has Hash $!pages;
has Array $!page-data;

has Hash $!sets;
has Array $!set-data;
has Iterator $!iterator;

has Hash $!page;

has QADisplayType $.display is rw;
#TODO display properties

has QAManager::QATypes $!qa-types;

#-------------------------------------------------------------------------------
# TODO , Bool :$!ro
submethod BUILD ( Str:D :$!sheet, Bool :$resource = False ) {

  # initialize types
  $!qa-types .= instance;
  self!load;
}

#-------------------------------------------------------------------------------
method !load ( ) {

  # initialize sheets
  $!pages = %();
  $!page-data = [];

  my Hash $sheet = $!qa-types.qa-load( $!sheet, :sheet);
  if ?$sheet {

    $!display =
      QADisplayType(QADisplayType.enums{$sheet<display>//''}) // QANoteBook;

    # the rest are pages
    for @($sheet<pages>) -> $h-page is copy {
      next unless ?$h-page;
      if $h-page<name>:exists and ?$h-page<name> {

        $h-page<title> //= $h-page<name>.tclc;
        $h-page<description> //= $h-page<title>;

        $!pages{$h-page<name>} = $!page-data.elems;
        $!page-data.push: $h-page;
      }

      else {
        note "Name of page not defined, page skipped";
      }
    }
  }

  else {
    $!display = QANoteBook;
  }
}

#-------------------------------------------------------------------------------
method new-page (
  Str:D :$name where ?$name, Str :$title = '', Str :$description = ''
  --> Bool
) {

  return False if $!pages{$name}:exists;

  $title //= $name.tclc;
  $description //=$title;

  $!set-data = [];
  $!page = %( :$name, :$title, :$description);
  $!page<sets> := $!set-data;

  $!pages{$name} = $!page-data.elems;
  $!page-data.push: $!page;

  True
}

#-------------------------------------------------------------------------------
method add-set (
  Str:D :$category, Str:D :$set, Str :$qa-path is copy --> Bool
) {
# TODO check existence

  my Bool $set-ok = False;

  $qa-path ~= "/$category" if ?$qa-path;
  my Hash $cat = $!qa-types.qa-load( $category, :$qa-path, :!sheet);
  if ?$cat {
    for @($cat<sets>) -> Hash $h-set {
      if $h-set<name> eq $set {
        $set-ok = True;
        last
      }
    }
  }

  $!set-data.push: %( :$category, :$set);
  $set-ok
}

#-------------------------------------------------------------------------------
method remove-set ( Str:D :$category, Str:D :$set --> Bool ) {
# TODO check existence

#TODO yes/no message using 'Bool :$gui = False' argument

  my Bool $removed = False;

  loop ( my Int $i = 0; $i < $!set-data.elems; $i++ ) {
    my Hash $h-set = $!set-data[$i];
    if ($h-set<category> eq $category) and ($h-set<set> eq $set) {
      $!set-data.splice( $i, 1);
      $removed = True;
      last;
    }
  }

  $removed
}

#-------------------------------------------------------------------------------
method save ( ) {
  $!qa-types.qa-save( $!sheet, %(:$!display, :pages($!page-data)), :sheet);
}

#-------------------------------------------------------------------------------
method save-as ( Str $new-sheet ) {

  $!qa-types.qa-save( $new-sheet, %(:$!display, :pages($!page-data)), :sheet);
  $!sheet = $new-sheet;
}

#-------------------------------------------------------------------------------
method delete-page ( :$name --> Bool ) {

#TODO yes/no message using 'Bool :$gui = False' argument

  return False unless $!pages{$name}:exists;

  $!page-data.splice( $!pages{$name}, 1);
  for $!pages.keys -> $k {
    $!pages{$k}-- if $!pages{$k} > $!pages{$name}
  }

  $!pages{$name}:delete;
  True
}


#-------------------------------------------------------------------------------
method remove ( Bool :$ignore-changes = False ) {

#TODO yes/no message using 'Bool :$gui = False' argument

  $!pages = Nil;
  $!page-data = [];
  $!qa-types.qa-remove( $!sheet, :sheet);
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

#-------------------------------------------------------------------------------
method get-sheet-list ( --> List ) {
  $!qa-types.qa-list(:sheet)
#`{{
  my @sl = ();
  for (dir $!sheet-lib-dir)>>.Str -> $sheet-path is copy {
    $sheet-path ~~ s/ ^ .*? (<-[/]>+ ) \. 'cfg' $ /$0/;
    @sl.push($sheet-path);
  }

  @sl
}}
}
