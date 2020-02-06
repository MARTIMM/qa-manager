use v6.d;

use JSON::Fast;

#-------------------------------------------------------------------------------
unit class QAManager:auth<github:MARTIMM>;

use QAManager::Category;
use QAManager::Gui::TopLevel;

#-------------------------------------------------------------------------------
# catagories are QAManager::Category classes holding sets
has Array $!categories;
has Hash $!cat-names;
has Str $!user-data-file;

has QAManager::Gui::TopLevel $!gui handles <
    build-invoice-page add-set
    >;

#-------------------------------------------------------------------------------
submethod BUILD ( Str :$!user-data-file ) {
  $!categories = [];
  $!cat-names = %();
  $!gui .= new(:$!categories);

  my Hash $user-data;
  $user-data = from-json($!user-data-file.IO.slurp) if $!user-data-file.IO.r;
  $!gui.set-user-data($user-data);
}

#-------------------------------------------------------------------------------
method load-category ( Str $category --> Bool ) {

  # check if Category is loaded, ok if it is
  return True if $!cat-names{$category}:exists;

  my QAManager::Category $c .= new(:$category);
  if $c.is-loaded {
    $!cat-names{$category} = $!categories.elems;
    $!categories.push: $c;

note "Load: $category, ", $!categories.elems, ', ', $!cat-names{$category}
  }

  $c.is-loaded;
}

#-------------------------------------------------------------------------------
method get-category ( Str:D $category --> QAManager::Category ) {

  $!cat-names{$category}.defined
      ?? $!categories[$!cat-names{$category}]
      !! QAManager::Category
}

#-------------------------------------------------------------------------------
method run-invoices ( ) {

  my QAManager::Gui::TopLevel $gui .= new(:$!categories);
  my Hash $user-data = $gui.run-invoices;
  $!user-data-file.IO.spurt(to-json($user-data)) if $gui.results-valid;
note "user data: ", $user-data.perl;

}




















=finish
#-------------------------------------------------------------------------------
#`{{
method add-set ( Str $category, Str $name, Hash $qa --> Bool ) {
  # check if Category is loaded, fails if not
  return False unless $!catagories{$category}.defined;

  # check if set name exists, fails if it is
  return False if $!catagories{$category}{$name}.defined;

  # save new set
  $!catagories{$category}{$name} = $qa;

  True
}
}}

#-------------------------------------------------------------------------------
#`{{
method replace-set ( Str $category, Str $name, Hash $qa --> Bool ) {

  # check if Category is loaded
  return False unless $!catagories{$category}:exists;

  # check if set name exists
  return False if $!catagories{$category}{$name}:exists;

  # save new set
  $!catagories{$category}{$name} = $qa;

  True
}
}}

#`{{
#-------------------------------------------------------------------------------
method purge-category ( Str $category --> Bool ) {

  # check if category is loaded, ok if it is
  return True if $!catagories{$category}:exists;

  $!catagories{$category} = QAManager::Category.new(:$category);

  True
}
}}
#-------------------------------------------------------------------------------
#`{{
method remove-set ( Str $category, Str $name --> Bool ) {

  # check if Category is loaded
  return False unless $!catagories{$category}:exists;

  # check if set name exists, if it is then remove
  return False unless $!catagories{$category}{$name}:exists;

  $!catagories{$category}{$name}:delete;

  True
}
}}

#`{{
#-------------------------------------------------------------------------------
method remove-category ( Str $category --> Bool ) {

  # check if Category is loaded
  return False unless $!catagories{$category}:exists;

  $!catagories{$category}:delete;
  unlink "$!config-dir/$category.cfg";

  True
}
}}

#-------------------------------------------------------------------------------
#`{{
method save-category ( Str $category --> Bool ) {
  # check if Category is loaded, ok if it is
  return False unless $!catagories{$category}:exists;

  # check if set name exists if not Category is created
  "$!config-dir/$category.cfg".IO.spurt(to-json($!catagories{$category}));

  True
}
}}
