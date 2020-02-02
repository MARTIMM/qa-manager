use v6.d;

use QAManager::KV;

#-------------------------------------------------------------------------------
unit class QAManager::Set:auth<github:MARTIMM>;

has Str $.name is required;
has Str $.title is rw;
has Str $.description is rw;

# this QAManager::KV's keys and values. $!keys is to check the names and index
# into $!kv-data and $!kv-data is to keep order as it is input.
has Hash $!keys;
has Array $!kv-data;

#-------------------------------------------------------------------------------
submethod BUILD ( Str:D :$!name, Str :$title ) {

  $!title = $title // $!name.tclc;
  $!keys = %();
  $!kv-data = [];
}

#-------------------------------------------------------------------------------
method add-kv ( QAManager::KV:D $kv --> Bool ) {

  # check if key exists, don't overwrite
  return False if $!keys{$kv.name}.defined;

  $!keys{$kv.name} = $!kv-data.elems;
  $!kv-data.push: $kv;

  True
}

#-------------------------------------------------------------------------------
method replace-kv ( QAManager::KV:D $kv --> Bool ) {

  $!kv-data[$!keys{$kv.name}] = $kv;

  True
}

#-------------------------------------------------------------------------------
method set ( --> Hash ) {

  %( :$!title, :$!description, keys => [map( { .name => .kv-data; }, @$!kv-data)])
}
