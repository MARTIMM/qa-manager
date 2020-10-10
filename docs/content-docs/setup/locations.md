---
title: Configuration
nav_menu: default-nav
sidebar_menu: config-sidebar
layout: sidebar
---
# Locations

There are several locations involved where questionaires and categories are stored. The results of the query is stored at a standard location if not changed.

Using definitions of [Free Desktop](https://freedesktop.org/wiki/);
* Categories are stored in a directory at `$*HOME/.config/QAManager/Categories.d`. On windows, this might become a bit different. The file is a JSON formatted file having a 'cfg' extention. The category name is the filename without the extention.
* Sheets are stored at `$*HOME/.config/QAManager/Sheets.d` and are also JSON formatted files.
* Answers returned from the sheet dialogs are stored in hashes which go into the users configuration environment `$*HOME/.config/<modified $*PROGRAM-NAME>`. Also, the sheet is filled in from this data before presentation.

However, it is possible to change the paths to other locations. This is important when you want to install a module, because the module installation program `zef` is not aware of any files from other locations than those in the `META6.json` configuration. Several options exist to install the modules sheet configurations;
* Write an installation program (`build.pl6`) which installs the sheets at the proper place.
* Keep the sheets in the resources directory and refer to it later.
