use v6.d;

use QAManager::Question;

#-------------------------------------------------------------------------------
unit class QAManager::Set:auth<github:MARTIMM>;

has Str $.name is required;
has Str $.title is rw;
has Str $.description is rw;
has Str $.hide is rw;

# this QAManager::KV's keys and values. $!keys is to check the names and index
# into $!questions and $!questions is to keep order as it is input.
has Hash $!keys;
has Array $!questions;

#-------------------------------------------------------------------------------
submethod BUILD ( Str:D :$!name, Str :$title, Str :$description ) {

  $!title = $title // $!name.tclc;
  $!description = $description // $title;
  $!keys = %();
  $!questions = [];
  $!hide = False;
}

#-------------------------------------------------------------------------------
method add-question ( QAManager::Question:D $question --> Bool ) {

  # check if key exists, don't overwrite
  return False if $!keys{$question.name}.defined;

  $!keys{$question.name} = $!questions.elems;
  $!questions.push: $question;

  True
}

#-------------------------------------------------------------------------------
method get-questions ( --> Array ) {

  $!questions
}

#-------------------------------------------------------------------------------
method replace-question ( QAManager::Question:D $question ) {

  $!questions[$!keys{$question.name}] = $question;
}

#-------------------------------------------------------------------------------
method set ( --> Hash ) {

  %( :$!name, :$!title, :$!description, :$!hide,
     questions => [map {.qa-data}, @$!questions]
  )
}
