[toc]

# Purpose

Questionnaires and configurations are all some form of key - value sheets serving all kinds of purposes ranging from configuration settings, installation dialogs to household todo lists. This library tries to help you with two facilities, first, setting up a question-answer (QA from now on) sheet and store it in the managers environment and second, use this sheet to provide questions the user must answer and save the results in the users program environment.

# Setup

The program using a previously created sheet provides this sheet by showing it in a dialog on screen like this example below

![qa-invoice](Images/qa-manager-2020-02-08_12-51.png)

## Management of QA sheets.

 The created sheets are stored in some config environment of the QAManager. The QAManager needs to ask questions about how to create a user sheet. This special QA sheet is stored in the resources directory belonging to the program.

 A QA sheet is build up from parts, called sets. A series of sets is stored in a file called a category. A selection of sets from several categories can be presented to the user as a QA sheet.

All values can be checked for its type and definedness by several methods.

A QA sheet is presented and can be filled in. After pressing Finish, the QA sheet is checked against wrong input. When the input checks alright the dialog is removed from display and the result returned. If the input is in some way wrong (visual hints are already shown), a message dialog is displayed with the found problems.

## Categories

To keep all sets in a single file would perhaps become unwieldy so it is decided to have sets in different files. The sets are then categorized by these files. E.g. All internet sets in an `internet.cfg` or specific sets about politics into `politics.cfg`. The category names would be `internet` and `politics` resp.

Directory where the set categories are stored will be `$*HOME/.config/QAManager/QAlib.d` on `*ux` systems. <!-- and `$*HOME/QAManager/QAlib.d` on Windows.-->

## Sheets

A complete QA sheet consists of a set of pages with one or more sets. Each page has a title and description.

Directory where the set sheets are stored will be `$*HOME/.config/QAManager/QA.d` on `*ux` systems. <!-- and `$*HOME/QAManager/QA.d` on Windows.-->

## Sets

A set describes input fields. Each input is defined in an entry. A set has also a name and a short and long description. All texts can be specified in other languages as long the program can access it using an extension on a key.

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
The key is a string of letters, digits or underscores.

Summarized
* Name; Used in Gui to retrieve the data. Name is set on the input widget.

### Values

Summarized
* Description; Used in Gui to describe the value needed. Empty when absent.
* Type; Number, String, Boolean, Image, Array, Set
  * Number; Int, Rat, Num
  * String; Text, Color, Filename
  * Array; Strings
* Limits, Boolean values like required, encode are `False` and visible is `True` if not mentioned. Default values are '' or 0 when absent. Min and Max are -Inf and Inf when absent. Encoding is using sha256 and stars means that the field will show stars instead of the text typed.
  * Numbers; Hash of required, default, minimum, maximum
  * String; Hash of required, default, encode, stars
  * Boolean; Hash of required, default
  * Image; Hash of required
  * Array; Hash of required
  * ?? Set; Hash of required, category name, set name
* Widget representation. Entry when absent. Each of the representations must show a clue as to whether the field is required. Default values must be filled in (light gray) when value is absent. When another set is referred, a button is placed to show a new dialog with the QA from that set. A boolean value displayed in a ComboBox has two entries with 'Yes' or 'No' as well as for two RadioButtons with 'Yes' or 'No' text.
  * Number; Entry, Scale
  * String; Entry, TextView, ComboBox
  * Boolean; ComboBox, RadioButton, CheckButton, Switch, ToggleButton
  * Image; FileChooserDialog, Drag and Drop
  * Color; ColorChooserDialog
  * File; FileChooserDialog, Drag and Drop
  * Array; ComboBox, CheckButton
  * Set; Button -> Dialog, 2nd page of a Stack or a NoteBook
* Checks on input.
* Repeatability of input fields; e.g. phone numbers
* Repeatability of sets; e.g. username/password sets for more than one account.

# Todo
## Category

## Set

## KV or field specification


![image](Images/a-displayed-set.png)

### Visual clues on validity of value

* [x] Stylesheet installed in resources
* [x] Border color of entries are specified for faulty (red) and ok entries (green).
* [x] A messagebox is shown on Finish if there are errors found. Finish will then not exit.

### Field key specifications
* [ ] button; optional to create another dialog
* [x] callback; optional to check a value from text input.
* [ ] cmpwith; optional to check value against other field
* [x] default; optional default value
* [x] description; Optional. By default it uses the title. It is shown in front of the input field.
* [ ] encode; when value must be encoded with sha256
* [x] example; optional example value

* [x] field; optional. Default is QAEntry.
  * [x] QAEntry; Single line input for text and number.
        One value to get/set in user config.
  * [ ] QAScale; Number input.
        One value to get/set in user config.
  * [x] QATextView; Multiline text input.
        One value to get/set in user config.
  * [ ] QAComboBox; List selects for one selection. Values for list is provided in 'values'.
        One value to get/set in user config. An array is defined in the config to populate the combobox.
  * [x] QAComboBox; List selects for one selection.
  * [ ] QARadioButton; List selects for one selection.
  * [ ] QAList; List selects.
  * [x] QACheckButton; Boolean input.
  * [x] QASwitch; Boolean input.
  * [ ] QAToggleButton; Boolean input.
  * [ ] QAFileChooserDialog
  * [ ] QADragAndDrop
  * [ ] QAColorChooserDialog
  * [ ] QADialog
  * [ ] QAStack
  * [ ] QANoteBook
  * [ ] QAImage;

* [x] invisible; when value is displayed as invisible characters
* [x] height; optional height in pixels. Used for e.g. a TextView.
* [ ] maximum; optional. Maximum for number type or maximum number of characters for string type.
* [ ] minimum; optional. Minimum for number type or minimum number of characters for string type.
* [x] name; Required. Used as a key in returned data along with category and set. Also used as a name on the widget to find the widget.
* [ ] populate; optional to provide values for a widget.
* [x] title; Optional. By default it is the first character uppercased of the name.
* [x] tooltip; optional tooltip on input field
* [ ] repeatable; boolean value when input is repeatable. Data must be stored in an array. To repeat, field must show a **+** to the right.
* [x] required; boolean value when input is required. show as a star
* [ ] values; array of strings for (multi)select lists
* [ ] width; optional width in pixels


##### A table where field specs are shown for each field type

| Symbol | Explanation |
|-|-|
|!| Must be provided with used type |
|o| Optional |
| | Cannot be used and is ignored |

|  | Entry | CheckButton | ComboBox | Image | List | RadioButton | Scale | Switch | TextView |
|-------------|-|-|-|-|-|-|-|-|-|
|button       | | | | | | | | | |
|callback     |o| | | | | | | | |
|cmpwith      |o| | | | | | | | |
|default      |o| | | | | | | | |
|description  |o|o|o|o|o|o|o|o|o|
|encode       |o| | | | | | | | |
|example      |o| | | | | | | | |
|field        |o|!|!|!|!|!|!|!|!|
|height       | | | | | | | | |o|
|invisible    |o| | | | | | | | |
|maximum      |o| | | | | | | | |
|minimum      |o| | | | | | | | |
|name         |!|!|!|!|!|!|!|!|!|
|populate     | |o|o| |o|o| | | |
|title        |o|o|o|o|o|o|o|o|o|
|tooltip      |o|o|o|o|o|o|o|o|o|
|repeatable   |o| | |o| | | | |o|
|required     |o| | | |o| | | |o|
|values       | |!|!| |!|!| | | |
|width        | | | | | | | | | |

# Interactions

Below diagrams show the interactions between user, user programs, the QA Manager program and library and the flow of QA sheets and config data.

##### Steps to define categories (part 1)
* The user interacts with the QAManager program to edit sets.
* The sets are stored in the library as categories.

##### Steps to define sheets (part 2)
* The user interacts with the QAManager program to edit sheets. Sets are selected from categories.
* The sheets are stored in the QAManagers sheets directory.

##### The use of the sheets (part 3)
* The user program asks for the sheets from the QAManagers program library.
* The library presents the QA to the user.
* After finishing, the data from the QA is stored in the programs environment.
* Then the user program can use the data to control its behavior, layout or whatever is defined.

```plantuml
!include <tupadr3/common>
!include <tupadr3/font-awesome/archive>
!include <tupadr3/font-awesome/clone>
!include <tupadr3/font-awesome/cogs>
!include <tupadr3/font-awesome/edit>
!include <tupadr3/font-awesome/female>

title Setting up categories (part 1)

FA_ARCHIVE( qaa, Category\nLibrary) #ffefaf
FA_CLONE( ucs1, sets) #e0e0ff
FA_EDIT( ec2, edit set) #e0e0ff

FA_FEMALE( u1, user) #efffef

FA_COGS( qamp, QA Manager\nprogram)
FA_COGS( qaml, QA Manager\nlibrary)

u1 -> qamp
u1 <--> ec2
qamp <--> ec2

qamp <-> qaml
qaml <-> ucs1
ucs1 <-> qaa
```

```plantuml
!include <tupadr3/common>
!include <tupadr3/font-awesome/archive>
!include <tupadr3/font-awesome/clone>
!include <tupadr3/font-awesome/cogs>
!include <tupadr3/font-awesome/edit>
!include <tupadr3/font-awesome/female>
!include <tupadr3/font-awesome/file_code_o>

title Setting up QA sheets (part 2)

FA_ARCHIVE( qaa1, Category\nLibrary) #ffefaf
FA_ARCHIVE( qaa2, QA Sheets) #ffefaf
FA_CLONE( ucs2, sets) #e0e0ff
FA_CLONE( ucs3, sheets) #e0e0ff
FA_EDIT( ec2, edit sheet) #e0e0ff

FA_FEMALE( u1, user) #efffef

FA_COGS( qaml, QA Manager\nlibrary)
FA_COGS( qamp, QA Manager\nprogram)

u1 -> qamp
u1 <--> ec2
qamp <--> ec2

qamp <-> qaml
qaml <-> ucs3
ucs3 <-> qaa2

qaa1 --> ucs2
ucs2 --> qaml
```

```plantuml
!include <tupadr3/common>
!include <tupadr3/font-awesome/archive>
!include <tupadr3/font-awesome/clone>
!include <tupadr3/font-awesome/cogs>
!include <tupadr3/font-awesome/edit>
!include <tupadr3/font-awesome/female>
!include <tupadr3/font-awesome/file_code_o>

title Running QA sheets (part 2)

FA_ARCHIVE( qaa, QA sheets) #ffefaf
FA_CLONE( ucs2, sheets) #e0e0ff
FA_EDIT( ec1, edit\nsheet) #e0e0ff
FA_FILE_CODE_O( fc, config) #ffefaf

FA_FEMALE( u2, user) #efffef

FA_COGS( qaml, QA Manager\nlibrary)
FA_COGS( up, user\nprogram)

qaa -> ucs2
ucs2 -> qaml

qaml <-- up
qaml <--> ec1
up <- u2
u2 <-> ec1
qaml <--> fc

fc -> up
```

# API

## Defining a set

* Create an input specification
```
my QAManager::KV $un .= new(:name<username>, :kv(%(...)));
$un.required = True;

my QAManager::KV $pw .= new(:name<password>, :kv(%(...)));
$un.required = True;
$un.encode = True;
```
* Create a set and add input specs
```
my QAManager::Set $creds .= new(:name<credentials>);
$creds.add-kv($un);
$creds.add-kv($pw);
```

## Building a category

* Create a category, populate and save
```
my QAManager::Category $category .= new(:category('accounting'));
$category.add-set($creds);
$category.save;
```
* Remove a category
```
$category2.remove
```

## Building a sheet
* Create a sheet, populate and save
```
my QAManager::Sheet $sheet .= new(:sheet('login'));
$sheet.display = QADialog;
$sheet.add-page( :title<Login>, :description('MongoDB Server Login');
$sheet.add-set( :category<accounting>, :set<credentials>);
$sheet.save;
```

## Run QA Dialog
* Select a sheet and run invoice dialog
```
my QAManager $qam .= new( :sheet<Login>, :result-file<login-data>);
my Hash $data = $qam.run-invoice;
```
