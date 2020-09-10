---
title: Question Answer Manager
#layout: sidebar

nav_menu: default-nav
#sidebar_menu: main-sidebar
---

[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

# Question Answer Manager

# Description

Questionnaires and configurations have all some form of key - value sheets serving all kinds of purposes. This library tries to help setting up a question/answer (QA from now on) sheet and store it in the managers environment.

# Versions of involved software

* Program is tested against the latest version of **Raku** on **Rakudo** en **Moarvm**. It is also necessary to have the (almost) newest compiler, because there are some code changes which made e.g. variable argument lists to the native subs possible. Older compilers cannot handle that (before summer 2019 I believe). This means that Rakudo Star is not usable because the newest release is from March 2019.

  Some steps to follow if you want to be at the top of things. You need `git` to get software from the github site.
  1) Make a directory to work in e.g. Raku
  2) Go in that directory and run `git clone https://github.com/rakudo/rakudo.git`
  3) Then go into the created rakudo directory
  4) Run `perl Configure.pl --gen-moar --gen-nqp --backends=moar`
  5) Run `make test`
  6) And run `make install`

  Subsequent updates of the Raku compiler and moarvm can be installed with
  1) Go into the rakudo directory
  2) Run `git pull`
  then repeat steps 4 to 6 from above

  Your path must then be set to the program directories where `$Rakudo` is your  `rakudo` directory;
  `${PATH}:$Rakudo/install/bin:$Rakudo/install/share/perl6/site/bin`

  You can read the README for more details on the same site: https://github.com/rakudo/rakudo

  After this, you will notice that the `raku` command is available next to `perl6` so it is also a move forward in the renaming of perl6.

  The rakudo star installation must be removed, because otherwise there will be two raku compilers wanting to be the captain on your ship. Also all modules must be reinstalled of course and are installed at `$Rakudo/install/share/perl6/site`.

* Gtk library used **Gtk 3.24**. The versioning of GTK+ is a bit different in that there is also a 3.90 and up. This is only meant as a prelude to version 4. So do not use those versions for the perl packages.

# Installation

`zef install QAManager`

# Issues

There are always some problems! If you find one, please help by filing an issue at [my github project](https://github.com/MARTIMM/qa-manager/issues).

# License

This software is made available under the Artistic 2.0 license.

# Attribution

* An icon is used for free from https://icons8.com in the Readme, in the applications and elsewhere on the documentation site.

# Author

Name: **Marcel Timmerman**
Github account name: **MARTIMM**
