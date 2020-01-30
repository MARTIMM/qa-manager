use v6.d;

use JSON::Fast;

#-------------------------------------------------------------------------------
unit class QAManager:auth<github:MARTIMM>;

use QAManager::Category;

# catagories are QAManager::Category classes holding sets
has Hash $!catagories;

#has Str $!config-dir;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
#`{{
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
}}
}

#-------------------------------------------------------------------------------
method load-category ( Str $category --> Bool ) {

  # check if Category is loaded, ok if it is
  return True if $!catagories{$category}:exists;

  my QAManager::Category $c .= new(:$category);
  $!catagories{$category} = $c if $c.is-loaded;

  True

#`{{
  # check if Category is loaded, ok if it is
  return True if $!catagories{$category}:exists;

  # check if Category file exists then load, if not, Category is created
  my Str $catfile = "$!config-dir/$category.cfg";
  if $catfile.IO.r {
    $!catagories{$category} = from-json($catfile.IO.slurp);
  }

  else {
    $!catagories{$category} = { };
  }
}}
}

#-------------------------------------------------------------------------------
method add-set ( Str $category, Str $name, Hash $qa --> Bool ) {
#`{{
  # check if Category is loaded, fails if not
  return False unless $!catagories{$category}.defined;

  # check if set name exists, fails if it is
  return False if $!catagories{$category}{$name}.defined;

  # save new set
  $!catagories{$category}{$name} = $qa;

  True
}}
}

#-------------------------------------------------------------------------------
method replace-set ( Str $category, Str $name, Hash $qa --> Bool ) {
#`{{

  # check if Category is loaded
  return False unless $!catagories{$category}:exists;

  # check if set name exists
  return False if $!catagories{$category}{$name}:exists;

  # save new set
  $!catagories{$category}{$name} = $qa;

  True
}}
}


#-------------------------------------------------------------------------------
method purge-category ( Str $category --> Bool ) {

  # check if category is loaded, ok if it is
  return True if $!catagories{$category}:exists;

  $!catagories{$category} = QAManager::Category.new(:$category);

  True
}

#-------------------------------------------------------------------------------
method remove-set ( Str $category, Str $name --> Bool ) {
#`{{

  # check if Category is loaded
  return False unless $!catagories{$category}:exists;

  # check if set name exists, if it is then remove
  return False unless $!catagories{$category}{$name}:exists;

  $!catagories{$category}{$name}:delete;

  True
}}
}

#-------------------------------------------------------------------------------
method remove-category ( Str $category --> Bool ) {

#`{{
  # check if Category is loaded
  return False unless $!catagories{$category}:exists;

  $!catagories{$category}:delete;
  unlink "$!config-dir/$category.cfg";

  True
}}
}

#-------------------------------------------------------------------------------
method save-category ( Str $category --> Bool ) {
#`{{
  # check if Category is loaded, ok if it is
  return False unless $!catagories{$category}:exists;

  # check if set name exists if not Category is created
  "$!config-dir/$category.cfg".IO.spurt(to-json($!catagories{$category}));

  True
}}
}
