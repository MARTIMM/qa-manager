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
* Sheets which are used by the program to create categories and sheets are stored in the apps resources directory.
* Answers are stored in hashes which go into the users configuration environment.
