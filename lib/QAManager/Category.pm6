use v6.d;

use QAManager::Set;

use JSON::Fast;

#-------------------------------------------------------------------------------
unit class QAManager::Category:auth<github:MARTIMM>;

# need to know if same category is opened elsewhere
my Hash $opened-categories = %();

# catagories are filenames holding sets
has Str $!category is required;
has Str $.title is rw;
has Str $.description is rw;

# directory to store catagories
has Str $!config-dir;

has Bool $.is-changed;

# this QAManager::Category's sets
has Hash $!sets;

#-------------------------------------------------------------------------------
submethod BUILD ( Str:D :$!category, Str :$title ) {

  if $*DISTRO.is-win {
  }

  else {
    $!config-dir = "$*HOME/.config";
    mkdir( $!config-dir, 0o760) unless $!config-dir.IO.d;
    $!config-dir ~= '/QAManager';
    mkdir( $!config-dir, 0o760) unless $!config-dir.IO.d;
    $!config-dir ~= '/QA.d';
    mkdir( $!config-dir, 0o760) unless $!config-dir.IO.d;
  }

  # test self to see if .= new() is used
  self.purge if self.defined;

  # implicit load of catagories
  unless self.load {
    $!title = $title // $!category.tclc;
    $!sets = Nil;
  }
}

#-------------------------------------------------------------------------------
method load ( --> Bool ) {

  # do not lead if loaded in another Category object
  return False if $opened-categories{$!category}.defined;

  # check if Category is loaded, ok if it is
  return True if $!sets.defined;

  # check if Category file exists then load, if not, Category is created
  my Str $catfile = "$!config-dir/$!category.cfg";
  if $catfile.IO.r {
    $!sets = from-json($catfile.IO.slurp);
  }

  else {
    $!sets = %();
  }

  $!is-changed = False;
  $opened-categories{$!category} = 1;

  True
}

#-------------------------------------------------------------------------------
method is-loaded ( --> Bool ) {
  $!sets.defined
}

#-------------------------------------------------------------------------------
method save ( --> Bool ) {

  # check if Category is loaded, ok if it is
  return False unless $!sets.defined;

  # check if set name exists if not Category is created
  "$!config-dir/$!category.cfg".IO.spurt(to-json(self.category));

  $!is-changed = False;

  True
}

#-------------------------------------------------------------------------------
method category ( --> Hash ) {

  %( :$!title, :$!description, |($!sets.kv));
}

#-------------------------------------------------------------------------------
# remove from memory
method purge ( Bool :$ignore-changes = False --> Bool ) {

  # check if Category is changed
  return False if !$ignore-changes and $!is-changed;

  # check if Category is loaded
  return False unless $!sets.defined;

  $!sets = Nil;
  $opened-categories{$!category}:delete;

  True
}

#-------------------------------------------------------------------------------
# remove from memory and disk
method remove ( Bool :$ignore-changes = False --> Bool ) {

  # check if Category is changed
  return False if !$ignore-changes and $!is-changed;

#TODO yes/no message

  # check if Category is loaded
  return False unless $!sets.defined;

  $!sets = Nil;
  unlink "$!config-dir/$!category.cfg";
  $opened-categories{$!category}:delete;

  True
}

#-------------------------------------------------------------------------------
method add-set ( QAManager::Set:D $set --> Bool ) {

  # check if set exists, don't overwrite
  return False if $!sets{$set.name}.defined;

  $!sets{$set.name} = $set.set;
  $!is-changed = True;

  True
}
