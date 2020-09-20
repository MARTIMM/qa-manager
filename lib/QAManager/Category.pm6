use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::Category:auth<github:MARTIMM>;

use QAManager::Set;
use QAManager::Question;

use QAManager::QATypes;

#-------------------------------------------------------------------------------
# need to know if same category is opened elsewhere

# catagories are filenames holding sets
has Str $.category is required;
has Str $.description is rw;

# directory to store categories
has Str $!category-lib-dir;

# this QAManager::Category's sets
has Hash $!sets;
has Array $!set-data;

has QAManager::QATypes $!qa-types;

#-------------------------------------------------------------------------------
# TODO , Bool :$!ro
# TODO , Bool :$!QAManager = False ??
submethod BUILD ( Str:D :$!category, Bool :$resource = False ) {

  # initialize types
  $!qa-types .= instance;

  self!load
}

#-------------------------------------------------------------------------------
method !load ( ) {

  # initialize sets
  $!sets = %();
  $!set-data = [];

  my Hash $cat = $!qa-types.qa-load( $!category, :!sheet);
  if ?$cat {

    # the rest are sets
    for @($cat<sets>) -> Hash $h-set {
      if $h-set<name>:exists and ?$h-set<name> {

        my QAManager::Set $set .= new(:name($h-set<name>));

        $set.title = $h-set<title> // $h-set<name>.tclc;
        $set.description = $h-set<description>;

        # the rest are keys of this set of questions
        for @($h-set<questions>) -> Hash $question {
          my QAManager::Question $q;
          $q .= new( :name($question<name>), :kv($question));

          $set.add-question($q);
        }

        $!sets{$h-set<name>} = $!set-data.elems;
        $!set-data.push: $set;
      }

      else {
        note "Name of page not defined, page skipped";
      }
    }
  }
}

#-------------------------------------------------------------------------------
method save ( ) {
  $!qa-types.qa-save( $!category, self.category, :!sheet);
}

#-------------------------------------------------------------------------------
method save-as ( Str $new-category --> Bool ) {

  $!qa-types.qa-save( $new-category, self.category, :!sheet);
  $!category = $new-category;
  True
}

#-------------------------------------------------------------------------------
method category ( --> Hash ) {
  %(sets => map( { .set }, @$!set-data))
}

#-------------------------------------------------------------------------------
# remove from memory and disk
method remove ( Bool :$ignore-changes = False --> Bool ) {

#TODO yes/no message using 'Bool :$gui = False' argument

  # check if Category is loaded
  return False unless $!sets.defined;

  $!sets = Nil;
  $!set-data = [];
  $!qa-types.qa-remove($!category);

  True
}

#-------------------------------------------------------------------------------
method add-set ( QAManager::Set:D $set --> Bool ) {

  # check if set exists, don't overwrite
  return False if $!sets{$set.name}:exists;

  $!sets{$set.name} = $!set-data.elems;
  $!set-data.push: $set;

  True
}

#-------------------------------------------------------------------------------
method replace-set ( QAManager::Set:D $set ) {

  if $!sets{$set.name}:exists {
    $!set-data[$!sets{$set.name}] = $set;
  }

  else {
    self.add-set($set);
  }
}

#-------------------------------------------------------------------------------
method delete-set ( Str:D $set-name ) {

  if $!sets{$set-name}:exists {
    for $!sets.keys -> $k {
      $!sets{$k}-- if $!sets{$k} > $!sets{$set-name};
    }

    $!set-data.splice( $!sets{$set-name}, 1);
    $!sets{$set-name}:delete;
  }
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
