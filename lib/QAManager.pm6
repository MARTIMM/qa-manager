use v6.d;

use JSON::Fast;

#-------------------------------------------------------------------------------
unit class QAManager:auth<github:MARTIMM>;

enum QATypes is export <QANumber QAString QABoolean QAImage QAArray QASet>;

# catagories are filenames holding sets
has Hash $!catagories;

has Str $!config-dir;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
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
}

#-------------------------------------------------------------------------------
submethod load-catagory ( Str $catagory --> Bool ) {

  # check if catagory is loaded, ok if it is
  return True if $!catagories{$catagory}:exists;

  # check if catagory file exists then load, if not, catagory is created
  my Str $catfile = "$!config-dir/$catagory.cfg";
  if $catfile.IO.r {
    $!catagories{$catagory} = from-json($catfile.IO.slurp);
  }

  else {
    $!catagories{$catagory} = { };
  }

  True
}

#-------------------------------------------------------------------------------
submethod add-set ( Str $catagory, Str $name, Hash $qa --> Bool ) {

  # check if catagory is loaded, fails if not
  return False unless $!catagories{$catagory}.defined;

  # check if set name exists, fails if it is
  return False if $!catagories{$catagory}{$name}.defined;

  # save new set
  $!catagories{$catagory}{$name} = $qa;

  True
}

#-------------------------------------------------------------------------------
submethod replace-set ( Str $catagory, Str $name, Hash $qa --> Bool ) {

  # check if catagory is loaded
  return False unless $!catagories{$catagory}:exists;

  # check if set name exists
  return False if $!catagories{$catagory}{$name}:exists;

  # save new set
  $!catagories{$catagory}{$name} = $qa;

  True
}

#-------------------------------------------------------------------------------
submethod remove-set ( Str $catagory, Str $name --> Bool ) {

  # check if catagory is loaded
  return False unless $!catagories{$catagory}:exists;

  # check if set name exists, if it is then remove
  return False unless $!catagories{$catagory}{$name}:exists;

  $!catagories{$catagory}{$name}:delete;

  True
}

#-------------------------------------------------------------------------------
submethod remove-catagory ( Str $catagory --> Bool ) {

  # check if catagory is loaded
  return False unless $!catagories{$catagory}:exists;

  $!catagories{$catagory}:delete;
  unlink "$!config-dir/$catagory.cfg";

  True
}

#-------------------------------------------------------------------------------
method save-catagory ( Str $catagory --> Bool ) {

  # check if catagory is loaded, ok if it is
  return False unless $!catagories{$catagory}:exists;

  # check if set name exists if not catagory is created
  "$!config-dir/$catagory.cfg".IO.spurt(to-json($!catagories{$catagory}));

  True
}
