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
submethod BUILD ( Str:D :$!name, Str :$title, Str :$description ) {

  $!title = $title // $!name.tclc;
  $!description = $description // $title;
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
method get-kv ( --> Array ) {

  $!kv-data
}

#-------------------------------------------------------------------------------
method replace-kv ( QAManager::KV:D $kv --> Bool ) {

  $!kv-data[$!keys{$kv.name}] = $kv;

  True
}

#-------------------------------------------------------------------------------
method set ( --> Hash ) {

  %( :$!name, :$!title, :$!description,
     entries => [map {.kv-data}, @$!kv-data]
  )
}
