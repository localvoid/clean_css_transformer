# clean_css_transformer 

> [pub](https://pub.dartlang.org/) transformer that uses
> [clean-css](https://github.com/jakubpawlowicz/clean-css) to minify
> CSS files.

## Options

## `executable`

Path to the cleancss executable. DEFAULT: `'cleancss'`

## `skip_import`

Disable @import processing.

TYPE: `bool`  
DEFAULT: `false`

## `skip_rebase`

Disable URLs rebasing.

TYPE: `bool`  
DEFAULT: `false`

## `skip_advanced`

Disable advanced optimizations - selector & property merging,
reduction, etc.

TYPE: `bool`  
DEFAULT: `false`

## `skip_aggressive_merging`

Disable properties merging based on their order.

TYPE: `bool`  
DEFAULT: `false`

## `skip_media_merging`

Disable `@media` merging.

TYPE: `bool`  
DEFAULT: `false`

## `skip_restructuring`

Disable restructuring optimizations.

TYPE: `bool`  
DEFAULT: `false`

## `skip_shorthand_compacting`

Disable shorthand compacting.

TYPE: `bool`  
DEFAULT: `false`

## `source_map`

Enables building input's source map.

TYPE: `bool`  
DEFAULT: `false`
