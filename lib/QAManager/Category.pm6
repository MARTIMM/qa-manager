#tl:1:QAManager::Category

use v6.d;

#-------------------------------------------------------------------------------
=begin pod
Class B<QAManager::Category> is used to categorize sets. You can view the directory where the categories are stored as an archive where sheets can be created from. See also B<QAManager::Sheet> and B<QAManager::Set>.

=end pod

unit class QAManager::Category:auth<github:MARTIMM>;

use QAManager::Set;
use QAManager::Question;

use QAManager::QATypes;

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=end pod

#-------------------------------------------------------------------------------
=begin pod
=head2 category

Get catagory name. The name is also used for the filename with .cfg extension added.

  method category ( --> Str )

=end pod

has Str $.category-name is required;

#-------------------------------------------------------------------------------
=begin pod
=head2 description

Get description of the category.

  method description ( --> Str )

=end pod
has Str $.description is rw;

#-------------------------------------------------------------------------------
# this QAManager::Category's sets
has Hash $!sets;
has Array $!set-data;

has QAManager::QATypes $!qa-types;

#-------------------------------------------------------------------------------
# TODO , Bool :$!ro
# TODO , Bool :$!QAManager = False ??
submethod BUILD ( Str:D :$!category-name, Bool :$resource = False ) {

  # initialize types
  $!qa-types .= instance;

  self!load
}

#-------------------------------------------------------------------------------
method !load ( ) {

  # initialize sets
  $!sets = %();
  $!set-data = [];

  my Hash $cat = $!qa-types.qa-load( $!category-name, :!sheet);
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
  $!qa-types.qa-save( $!category-name, self.category, :!sheet);
}

#-------------------------------------------------------------------------------
method save-as ( Str $new-category --> Bool ) {

  $!qa-types.qa-save( $new-category, self.category, :!sheet);
  $!category-name = $new-category;
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
  $!qa-types.qa-remove($!category-name);

  True
}

#-------------------------------------------------------------------------------
method add-set ( QAManager::Set:D $set, Bool :$replace = False --> Bool ) {

  # check if we want replacement
  if $replace {
    self.replace-set($set);
    True
  }

  # check if set exists, don't overwrite
  elsif $!sets{$set.name}:exists {
    False
  }

  else {
    $!sets{$set.name} = $!set-data.elems;
    $!set-data.push: $set;
    True
  }
}

#-------------------------------------------------------------------------------
method replace-set ( QAManager::Set:D $set ) {

  if $!sets{$set.name}:exists {
    $!set-data[$!sets{$set.name}] = $set;
  }

  else {
    self.add-set( $set, :!replace);
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

  $!qa-types.qa-list(:!sheet)
#`{{
  my @cl = ();
  for (dir $!category-lib-dir)>>.Str -> $category-path is copy {
    $category-path ~~ s/ ^ .*? (<-[/]>+ ) \. 'cfg' $ /$0/;
    @cl.push($category-path);
  }

  @cl
}}
}
