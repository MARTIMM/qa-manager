use v6.d;

#-------------------------------------------------------------------------------
unit class QAManager::Category:auth<github:MARTIMM>;

use QAManager::Set;
use QAManager::KV;

use JSON::Fast;

#-------------------------------------------------------------------------------
# need to know if same category is opened elsewhere
my Hash $opened-categories = %();

# catagories are filenames holding sets
has Str $.category is required;
has Str $.title is rw;
has Str $.description is rw;

# directory to store categories
has Str $!config-dir;

has Bool $.is-changed;

# this QAManager::Category's sets
has Hash $!sets;

#-------------------------------------------------------------------------------
submethod BUILD ( Str:D :$!category ) {

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

  # implicit load of categories, clear if it fails.
  $!sets = Nil unless self.load;
}

#-------------------------------------------------------------------------------
method load ( --> Bool ) {

  # do not lead if loaded in another Category object
  return False if $opened-categories{$!category}.defined;

  # check if Category is loaded, ok if it is
  return True if $!sets.defined;

  # initialize sets
  $!sets = %();

  # check if Category file exists then load, if not, Category is created
  my Str $catfile = "$!config-dir/$!category.cfg";
  if $catfile.IO.r {
    my Hash $cat = from-json($catfile.IO.slurp);
    $!title = $cat<title>;
    $!description = $cat<description>;

    # the rest are sets
    for $cat<sets>.keys -> Str $set-key {
#note "Set: $set-key";
      my QAManager::Set $set .= new(:name($set-key));

      my Hash $h-set = $cat<sets>{$set-key};
      $set.title = $h-set<title>;
      $set.description = $h-set<description>;

      # the rest are keys of this set
      for @($h-set<keys>) -> Hash $h-kv {
#note "  Key: $h-kv.perl()";
        my QAManager::KV $kv;
        for $h-kv.keys -> Str $kv-key {
          $kv .= new( :name($kv-key), :kv($h-kv{$kv-key}));
        }

        $set.add-kv($kv);
      }

      $!sets{$set.name} = $set;
    }

    $!is-changed = False;
  }

  else {
    $!title = $!category.tclc;
    $!sets = %( :title($!title) );
    $!is-changed = True;
  }

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

  # if set name does not exist, the Category is created
  "$!config-dir/$!category.cfg".IO.spurt(to-json(self.category));

  $!is-changed = False;

  True
}

#-------------------------------------------------------------------------------
method save-as ( Str $new-category --> Bool ) {

  # check if this new category is loaded elsewhere
  return False if $opened-categories{$new-category}.defined;

  # if set name does not exist, the new category is created
  "$!config-dir/$new-category.cfg".IO.spurt(to-json(self.category));

  # rename category
  $!category = $new-category;

  $!is-changed = False;

  True
}

#-------------------------------------------------------------------------------
method category ( --> Hash ) {

  %( :$!title, :$!description,
    |( map -> $k, $v { $v ~~ QAManager::Set ?? ($k => $v.set) !! ($k => $v) },
       $!sets.kv
    )
  )
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

  $!sets{$set.name} = $set;
  $!is-changed = True;

  True
}
