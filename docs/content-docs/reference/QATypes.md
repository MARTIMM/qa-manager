A singleton class to provide types and global variables

Types
=====

QADataFileType
--------------

QAFieldType
-----------

QAFieldType is an enumeration of field types to provide an anwer. The types are (and more to come);

  * QACheckButton; A group of checkbuttons.

  * QAComboBox; A pulldown list with items.

  * QAEntry; A single line of text.

  * QARadioButton; A group of radiobuttons.

  * QAScale; A scale for numeric input.

  * QASwitch; On/Off, Yes/No kind of input.

  * QATextView; Multy line input.

  * QAToggleButton; Like switch.

Methods
=======

!init
-----

Initialization of dynamic variables. The application can modify the variables before opening any query sheets.

The following variables are used in this program;

  * QADataFileType `$!data-file-type`; You can choose from INI, JSON or TOML. By default it saves the answers in json formatted files.

  * Hash `$!callback-objects`; User defined callback handlers. The `$!callback-objects` have two toplevel keys, `actions` to specify action like callbacks and `checks` to have callbacks for checking the input data. The next level is a name which is defined along a question/answer entry. The value of that name key is an array. The first value is the handler object, the second is the method name, the rest are obtional pairs of values which are also provided to the method. The manager will also add some parameters to the method.

Summarized

    $!callback-objects = %(
        actions => %(
          user-key => [ $handler-object, $method-name, :myval1($val1), ...],
          ...
        ),
        checks => %(
          user-key => [ $handler-object, $method-name, :myval1($val1), ...],
          ...
        ),
      );

See also subroutine `set-handler()`.

  * Str `$!cfgloc-category`; Location where categories are stored. Default is `$!HOME/.config/QAManager/Categories.d` on *nix systems.

  * Str `$!cfgloc-sheet`; Location where sheets are stored. Default is `$!HOME/.config/QAManager/Sheets.d` on *nix systems.

  * Str `$!cfgloc-resource`; Location where sheets are stored or retrieved from a resources directory for your application. Default is `./resources/Sheets` on *nix systems.

If any of `$!cfgloc-category`, `$!cfgloc-sheet` or `$!cfgloc-resource` is changed, make sure that the directories exists!

