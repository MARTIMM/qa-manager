---
title: Configuration
nav_menu: default-nav
sidebar_menu: config-sidebar
layout: sidebar
---
# Structures

Some raw structures are shown to have an idea how the files are defined;

* Category files. A category description is not needed because it is only for archiving sets.

```
sets [
  set1
    set name
    title
    description
    entries [
      entry1
        question1
        question2
        ...

      entry2
        ...
    ]

  set2
    ...
]

template sets [
  template1
    ...
]
```

* Sheet files.

```
pages [
  display type
  display properties
  page1
    page name
    title
    description
    sets [
      set1
        qa location
        category name
        set name

      set2
        ...
    ]

    template sets [
      template1
        ...
]

  page2
    ...
]

template pages [
  template1
    ...
]
```

* Result configuration returned from presented sheet is a **Hash**.

```
page1 => {
  set1 => {
    question1 => [value1, ...]        ??
    question2 => [value2, ...]        ??
    ...
  },
  set2 => {
    ...
  }
},

page2 => {
  ...
}
```
Values of questions must be looked into. At least it must be the same for all type of questions I think.
