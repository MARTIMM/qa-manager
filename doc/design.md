[toc]

# Purpose

Questionnaires and configurations have all some form of key - value sheets serving all kinds of purposes. This library tries to help setting up a question/answer (QA from now on) sheet and store it in the managers environment.

# Setup

* Management of QA sheets. A QA sheet is build up from parts, called sets. A set can be extended with other sets. Every set is stored on disk under some key. A complete QA sheet is then also a set under which the sheet can be pulled using the key for that set.
* Check QA input. All values can be checked for its type and definedness.
* QA graphical user interface. A QA sheet can be presented and filled in. After pressing Ok, Apply or Cancel, the QA sheet is removed from display and the result returned.

## Sets

A set is a single level of key - value pairs. The key is a string of letters, digits or underscores. A set has also a name and a short and long description. All texts can be specified in other languages as long the program can access it using an extension on a key. See [freedesktop]()

Summarized
* Name
  * Used in Gui in a Frame widget. When absent, it takes the set key.
  * Referring to a set as a set key from other sets
* Description
  * Used in Gui to describe the use of a set of config settings. Empty when absent.
* key - value pairs
  * QA data. The data returned to the program using the library is a simple Hash with scalar values. The hash can have a hierargy.
  * The QA sets, maintained by the library, are more elaborate to describe the value.

## Key Value Pairs

### Keys

Summarized
* Name; Used in Gui to retrieve the data. Name is set on the input widget.

### Values

Summarized
* Description; Used in Gui to describe the value needed. Empty when absent.
* Type; Number, String, Boolean, Image, Array, Set
  * Number; Int, Rat, Num
  * String; Text, Color, Filename
  * Array; Strings
* Limits, Boolean values like required, encode and stars ar `False` if not mentioned. Default values are '' or 0 when absent. Min and Max are -Inf and Inf when absent. Encoding is using sha256 and stars means that the field will show stars instead of the text typed.
  * Numbers; Hash of required, default, minimum, maximum
  * String; Hash of required, default, encode, stars
  * Boolean; Hash of required, default
  * Image; Hash of required
  * Array; Hash of required
  * Set; Hash of required, set name
* Widget representation. Entry when absent. Each of the representations must show a clue as to whether the field is required. Default values must be filled in (light gray) when value is absent. When another set is referred, a button is placed to show a new dialog with the QA from that set. A boolean value displayed in a ComboBox has two entries with 'Yes' or 'No' as well as for two RadioButtons with 'Yes' or 'No' text.
  * Number; Entry, Scale
  * String; Entry, TextView, ComboBox
  * Boolean; ComboBox, RadioButton, CheckButton, Switch, ToggleButton
  * Image; FileChooserDialog, Drag and Drop
  * Color; ColorChooserDialog
  * File; FileChooserDialog, Drag and Drop
  * Array; ComboBox, CheckButton
  * Set; Button

# Examples

Representation of QA sheet

```
set1:
  name,
  description,
  keys: [
    key1: [ description, type, limits, representation ],
    key2: [ ... ]
  ]
```

Example of a set `credential`.
```
credential:
  name: 'Credentials',
  description: 'Name and password for account',
  keys: [
    username: [
      'Username of account',
      string,
      { :required },
    ],
    password: [
      'Password for username',
      string,
      { :encode, :stars },
    ]
  ]
```

Example of a set `database` using also above set `credential`.

```
database:
  name: 'Mongodb',
  description: 'Mongodb database server data',
  keys: [
    hostname: [
      'Server where database resides',
      string,
      { :default<localhost> },
    ],
    portnumber: [
      'Service port',
      number,
      { :default(27017) },
    ],
    user-access: [
      'Database credentials',
      set,
      { },
      Dialog
    ]
  ]
```

The data returned from the questionnaire is a hash could then be something like below if the set `database` was used.
```
{ database => {
  :hostname('mdb.example.com'),
  :portnumber(27017),
  user-access => {
    :username('mickey'),
    :password('47c5c28cae2574cdf5a194fe7717de68f8276f4bf83e653830925056aeb32a48')
  }
}
