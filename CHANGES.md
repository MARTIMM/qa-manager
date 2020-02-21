# Release notes

* 2020-02-19 0.5.0
  * Add Sheet module. Categories are now in the QAlib.d directory and sheets will go into QA.d directory.
  * Moved QATypes to QAManager directory.

* 2020-02-07 0.4.0
  * Add style sheets to show faulty input. Fields now have a red or green border color to show its status.
  * Check for required fields added
  * Show example test in text input
  * Show tooltip text
  * Finish will not exit when there are errors.
  * Show message dialog on Finish when there are some errors.
  * Callback implemented to check on text input

* 2020-02-06 0.3.0
  * Invoice Gui buildup ok now
  * data can be injected in invoice fields and data can be extracted from fields

* 2020-02-02 0.2.0
  * Refactored QAManager -> QAManager::KV, QAManager::Set and QAManager::Category.
  * Bugfixes in serialization and deserialization to Json.
  * Add Gui::Main and Gui::TopLevel to present sheets to user to be filled in.

* 2020-01-29 0.1.0
  * Module QAManager

* 2020-01-28 0.0.1
  * Setup project.
  * Design
