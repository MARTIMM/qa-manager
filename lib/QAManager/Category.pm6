use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::Category:auth<github:MARTIMM>;

use QAManager::Set;
use QAManager::KV;

use QAManager::QATypes;

#-------------------------------------------------------------------------------
# need to know if same category is opened elsewhere
#my Hash $opened-categories = %();

# catagories are filenames holding sets
has Str $.category is required;
has Str $.description is rw;
#has Bool $!QAManager;

# directory to store categories
has Str $!category-lib-dir;

#has Bool $.is-changed;

# this QAManager::Category's sets
has Hash $!sets;
has Array $!set-data;

has QAManager::QATypes $!qa-types;

#-------------------------------------------------------------------------------
# TODO , Bool :$!ro
# TODO , Bool :$!QAManager = False ??
submethod BUILD ( Str:D :$!category, Bool :$resource = False ) {

#`{{
  if $*DISTRO.is-win {
  }

  else {
    $!category-lib-dir = "$*HOME/.config";
    mkdir( $!category-lib-dir, 0o760) unless $!category-lib-dir.IO.d;
    $!category-lib-dir ~= '/QAManager';
    mkdir( $!category-lib-dir, 0o760) unless $!category-lib-dir.IO.d;
    $!category-lib-dir ~= '/QAlib.d';
    mkdir( $!category-lib-dir, 0o760) unless $!category-lib-dir.IO.d;
  }

  # test self to see if .= new() is used
#  self.purge if self.defined;

#  # implicit load of categories, clear if it fails.
#  unless self.load {
#    $!sets = Nil;
#    $!set-data = [];
#  }
}}

  # initialize types
  $!qa-types .= instance;

  self!load
}

#-------------------------------------------------------------------------------
#method load ( --> Bool ) {
method !load ( ) {

  # do not lead if loaded in another Category object
#  return False if $opened-categories{$!category}.defined;

  # check if Category is loaded, ok if it is
  #return True if $!sets.defined;
  return if $!sets.defined;

  # initialize sets
  $!sets = %();
  $!set-data = [];

  my Hash $cat = $!qa-types.qa-load( $!category, :!sheet);
  if ?$cat {
#note "Read category definition from file $catfile";
#    my Hash $cat = from-json($catfile.IO.slurp);

    # the rest are sets
    for @($cat<sets>) -> Hash $h-set {
#note "Set: $h-set.perl()";
      if $h-set<name>:exists and ?$h-set<name> {

        my QAManager::Set $set .= new(:name($h-set<name>));

        $set.title = $h-set<title> // $h-set<name>.tclc;
        $set.description = $h-set<description>;

        # the rest are keys of this set
        for @($h-set<entries>) -> Hash $h-kv {
  #note "  Key: $h-kv.perl()";
          my QAManager::KV $kv;
          $kv .= new( :name($h-kv<name>), :kv($h-kv));

          $set.add-kv($kv);
        }

        $!sets{$h-set<name>} = $!set-data.elems;
        $!set-data.push: $set;
      }

      else {
        note "Name of page not defined, page skipped";
      }
    }

#    $!is-changed = False;
  }

  else {
#    $!is-changed = True;
  }

#`{{
  # check if Category file exists then load, if not, Category is created
#  my Str $catfile = $!QAManager ?? $!category !! "$!category-lib-dir/$!category.cfg";
#note "$!QAManager, $catfile";
  my Str $catfile = "$!category-lib-dir/$!category.cfg";
  if $catfile.IO.r {
#note "Read category definition from file $catfile";
    my Hash $cat = from-json($catfile.IO.slurp);

    # the rest are sets
    for @($cat<sets>) -> Hash $h-set {
#note "Set: $h-set.perl()";
      my QAManager::Set $set .= new(:name($h-set<name>));

      $set.title = $h-set<title> // $h-set<name>.tclc;
      $set.description = $h-set<description>;

      # the rest are keys of this set
      for @($h-set<entries>) -> Hash $h-kv {
#note "  Key: $h-kv.perl()";
        my QAManager::KV $kv;
        $kv .= new( :name($h-kv<name>), :kv($h-kv));

        $set.add-kv($kv);
      }

      $!sets{$h-set<name>} = $!set-data.elems;
      $!set-data.push: $set;
    }

    $!is-changed = False;
  }

  else {
    $!is-changed = True;
  }

#  $opened-categories{$!category} = 1;

#  True
}}
}

#`{{
#-------------------------------------------------------------------------------
method is-loaded ( --> Bool ) {
  $!sets.defined
}
}}

#-------------------------------------------------------------------------------
method save ( ) {

  $!qa-types.qa-save( $!category, self.category, :!sheet);

#`{{
  # check if Category is loaded, ok if it is
  return False unless $!sets.defined;

  # if category name does not exist, the Category is created
  "$!category-lib-dir/$!category.cfg".IO.spurt(to-json(self.category));
}}
#  $!is-changed = False;

#  True
}

#-------------------------------------------------------------------------------
method save-as ( Str $new-category --> Bool ) {

  $!qa-types.qa-save( $new-category, self.category, :!sheet);

#`{{
  # check if this new category is loaded elsewhere
#TODO is this correct? we opened it at least ourselves
#  return False if $opened-categories{$new-category}.defined;

  # if set name does not exist, the new category is created
  "$!category-lib-dir/$new-category.cfg".IO.spurt(to-json(self.category));

  # remove from categories and rename category
#  $opened-categories{$!category}:delete;
#  $opened-categories{$!category} = 1;
}}

  $!category = $new-category;
#  $!is-changed = False;

  True
}

#-------------------------------------------------------------------------------
method category ( --> Hash ) {

#  %( :$!name, :$!title, :$!description, sets => map( { .set }, @$!set-data))
  %(sets => map( { .set }, @$!set-data))
}

#`{{
#-------------------------------------------------------------------------------
# remove from memory
method purge ( Bool :$ignore-changes = False --> Bool ) {

  # check if Category is changed and we can ignore them
  return False unless !$!is-changed or $ignore-changes;

  # check if Category is loaded
  return False unless $!sets.defined;

  $!sets = Nil;
  $!set-data = [];
#  $opened-categories{$!category}:delete;

  True
}
}}

#-------------------------------------------------------------------------------
# remove from memory and disk
method remove ( Bool :$ignore-changes = False --> Bool ) {

  # check if Category is changed
#  return False if !$ignore-changes and $!is-changed;

#TODO yes/no message using 'Bool :$gui = False' argument

  # check if Category is loaded
  return False unless $!sets.defined;

  $!sets = Nil;
  $!set-data = [];
  $!qa-types.qa-remove($!category);
#  $opened-categories{$!category}:delete;
#  $!is-changed = False;

  True
}

#-------------------------------------------------------------------------------
method add-set ( QAManager::Set:D $set --> Bool ) {

  # check if set exists, don't overwrite
  return False if $!sets{$set.name}:exists;

  $!sets{$set.name} = $!set-data.elems;
  $!set-data.push: $set;
#  $!is-changed = True;

  True
}

#-------------------------------------------------------------------------------
method replace-set ( QAManager::Set:D $set --> Bool ) {

  if $!sets{$set.name}:exists {
    $!set-data[$!sets{$set.name}] = $set;
#    $!is-changed = True;
  }

  else {
    self.add-set($set);
  }

  True
}

#-------------------------------------------------------------------------------
method delete-set ( Str:D $set-name --> Bool ) {

  if $!sets{$set-name}:exists {
    for $!sets.keys -> $k {
      $!sets{$k}-- if $!sets{$k} > $!sets{$set-name};
    }

    $!set-data.splice( $!sets{$set-name}, 1);
    $!sets{$set-name}:delete;
#    $!is-changed = True;
  }

  True
}

#-------------------------------------------------------------------------------
method get-setnames ( --> Seq ) {

  # the easy way is `$!sets.keys` but it looses the order of things
  map( { .set<name> }, @$!set-data)
}

#-------------------------------------------------------------------------------
method get-set ( Str:D $setname --> QAManager::Set ) {
  $!sets{$setname}.defined ?? $!set-data[$!sets{$setname}] !! QAManager::Set
}

#-------------------------------------------------------------------------------
method get-category-list ( --> List ) {

  my @cl = ();
  for (dir $!category-lib-dir)>>.Str -> $category-path is copy {
    $category-path ~~ s/ ^ .*? (<-[/]>+ ) \. 'cfg' $ /$0/;
    @cl.push($category-path);
  }

  @cl
}
