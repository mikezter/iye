# IYE

IYE - short for I18N YAML Editor - makes it easy to translate your Rails I18N files and
keep them up to date. Unlike a lot of other tools in this space, IYE works directly on the
YAML files instead of keeping a separate database in sync. This has several benefits:

* Branching and diffing is trivial
* It does not alter the workflow for developers etc., whom can continue editing the
  YAML files directly
* If your YAML files are organized in subfolders, this structure is kept intact

![IYE yaml editor](http://f.cl.ly/items/2K2V2i3N2R2X1L2F051F/Sk%C3%A6rmbillede%202012-09-18%20kl.%2013.36.07.png)

## Features

 * Convert all strings of a codebase to `I18n.t` calls
 * Rename a key in codebase and all locale-yamls
 * Easily edit all translations for a key
 * Manages multiple locale-yamls per language and keeps keys sorted

## Prerequisites

You need to understand a few things about IYE for it to make sense, mainly:

* IYE does not create new keys - keys must exist for at least one locale in the YAML files
 * except for when you scan a codebase for strings to convert
 * except for when you rename a key
* IYE does not create new locales - at least one key must exist for each locale in the YAML files
 * except for when you scan a codebase for strings to convert

## Workflow

1. Install IYE:

        $ gem install iye

2. Navigate to the folder containing your YAML files and start IYE:

        $ iye .

    At this point IYE loads all translation keys for all locales, and creates any
    keys that might be missing for existing locales.

3. Point browser at [http://localhost:5050](http://localhost:5050)
4. Make changes and press 'Save' - each time you do this, all the keys will be
   written to their original YAML files, which you can confirm e.g. by using
   `git diff`.

## Development

The source ships with a `config.ru` suitable for development use with [shotgun](https://github.com/rtomayko/shotgun):

    shotgun -p 5050

To run tests:

    bundle install
    bundle exec rake

## Troubleshooting

## Build status

![](https://travis-ci.org/firmafon/iye.svg?branch=master)
