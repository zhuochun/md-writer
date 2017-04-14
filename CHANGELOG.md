## 2.6.5

* Support open cheatsheet in `markdown-preview-plus`

## 2.6.4

* Fix jump to reference spec failure in Atom v1.14.2
* Minor improvements to insert footnote

## 2.6.3

* Fix correct irregular order list numbers
* Retain style text selection as needed

## 2.6.2

* Fix deprecated `remote.require` in insert-image view
* Fix `path.extname` must be a string

## 2.6.1

* Fix `bufferRangeForScope` return `undefined` in a specific corner case
* Improve `jump-to-reference-definition` to handle more cases

## 2.6.0

* Fix Atom deprecation warning in package
* Bump minimum Atom version to v1.9.0
* Add command `markdown-writer:open-link-in-browser`
* Improve cheatsheet format and content

## 2.5.1

* Fix create project config regression bug

## 2.5.0

* Add footnote support, works better with [language-markdown][ed5837b4]
* Support overwriting existing image when copy image

  [ed5837b4]: https://atom.io/packages/language-markdown "language-markdown package"

## 2.4.0

* Add alpha order list support with `enter` continue list
* Add [filetype config][304ca626] support
  * Along with AsciiDoc filetype support
* Fix parsing image tag in a link
* Fix events not disposed correctly in views
* Add `renameImageOnCopy` config when copy image to local directories
* Add display of copy image destination path in dialog

  [304ca626]: https://github.com/zhuochun/md-writer/pull/156 "How to add your filetype support"

## 2.3.6

* Fix open cheat sheet path in Windows
* Add `source.gfm.nvatom` grammar support

## 2.3.5

* Fix menu ordered list command

## 2.3.4

* Minor bug fixes in insert image

## 2.3.3

* Fix home directory '~' is not recognized in config siteLocalDir
* Fix loading empty project config file error
* Log project config file loading errors at dev mode

## 2.3.2

* Fix insert image path not in forward slashes (Windows)

## 2.3.1

* Update Travis/Appveyor build scripts
* Fix generated project config contains invalid line
* Refactoring `config.coffee`

## 2.3.0

* Add command `markdown-writer:create-project-configs`
* Fix format table not working properly on lines with trailing spaces
* More fields for template `{category}`, `{tag}`, `{directory}`
* Fix exception when some user templates are not escaped

## 2.2.0

* Refactoring frontMatter and template
  * Change to use `{slug}` instead of `{title}` in directory templates
  * Add config `slugSeparator`
  * Add config `templateVariables` for custom static variables
  * Add config `frontMatterDate` for front matter date format
* Add `language-markdown` package filetype to supported grammars
* Support customization of link tags using template

## 2.1.1

* Abort key mapping event if action not performable
* Fix key mapping conflicts with `autocomplete-plus`

## 2.1.0

* Add default project support directory
* Add `relativeImagePath` configuration for insert image

## 2.0.1

* Fix publish draft in new buffers
* Use `atom.confirm` for better confirm UIs
* Add tabindex to view dialogs
* Catch YAML parse error in FrontMatter
* Fix ul/ol regex to restrict at least an empty space

## 2.0.0

* Reorganize codebase
  * Separate codes into views, commands, helpers
  * Rename `main.coffee` to `markdown-writer.coffee`
* Add a lot of tests, from 127 -> 219 tests
* Add `regexMatchBefore` to lists' line styles in config
* Improve `insert-new-line` behaviors
  * Add new config `inlineNewLineContinuation`
  * Support more lists continuation
* Improve `correct-order-list-numbers` to correct all levels
* Improve `format-table` behaviors
  * Format on non-table text does not raise error
  * Format table multiple times is idempotent
* Change `jump-between-reference-definition` to `jump-to-reference-definition`

## 1.9.3

* Fix publish-draft require missing file

## 1.9.2
## 1.9.1

* Fix insert link exception when try to get a saved link
* Fix insert link not saving links when the CSON file does not exists
* Add tests for insert link view

## 1.9.0

* Refactoring code
* Fix bug when edit tags/categories in files without front matter
* Add travis for testing
* Improve create draft, allow more customization as create post
* Fix bug publish draft where destination path does not exists

## 1.8.1

* Fix table columnWidths bug

## 1.8.0

* Fix table format with extra pipes
* Fix handle single column tables
* Improve table format to handle alignments
* Improve table format to handle double-width characters
* Add table default alignment, extra pipes configurations

## 1.7.1

* Fix remove top/bottom link definition would access out of bound lines
* Fix toggle multiple text styles, text become missing

## 1.7.0

* Improve text selection for link/image/text styles
* Support edit link from reference link definition
* Improve search reference link/definition logic

## 1.6.0

* Support customization on styles, refer to [wiki][2b17f5ff]

  [2b17f5ff]: https://github.com/zhuochun/md-writer/wiki/Settings-for-individual-projects "Settings for individual projects"

## 1.5.1

* Add missing command to Menu

## 1.5.0

* Remove default keymaps, refer to [wiki][72346d33].
* Add command `markdown-writer:create-default-keymaps`

  [72346d33]: https://github.com/zhuochun/md-writer/wiki/Settings-for-Keymaps "Settings for Keymaps"

## 1.4.0

* Fix cursor position after empty codeblock insertion
* Fix `Tab` behavior with range selections
* Modified some default setting values
* Updated cheatsheet

## 1.3.4

* Fix deprecated API `lineLengthForBufferRow`

## 1.3.3

* Update Atom engine version to mark it Atom v1.0.0 compatible

## 1.3.2

* Fix list continuation on `Enter` to only happens at the end of line

## 1.3.1

* Outdent when `Enter` on a empty line
* Improve indent tab line behavior

## 1.3.0

* Support correct order list numbers

## 1.2.0

* Support reference link insertion at the end of article
* Simplify reference link insertion logic
* `Tab` to indent list items

## 1.1.2

* Remove Array#contains API usage
* Fix publish post 'published' front matter bug

## 1.1.1

* Fix links no longer saved regression
* Improve insert image open dialog location logic

## 1.1.0

* Remove dependency on `request` module
* Change plugin styles to follow users' themes

## 1.0.0

* Support project specific settings
* Support copy image to project directory

## 0.10.3

* Fix table insert and format bugs
* Update package activation commands

## 0.10.2

* Fix package's atom engine version
* Fix tag RegExp escape

## 0.10.1

* Fix deprecated APIs
* Improve link reference insertion

## 0.10.0

* Use new config API
* Use `TextEditorView` API

## 0.9.1

* Improve table separator RegExp

## 0.9.0

* Add an option to set static engine
* Add `litcoffee` to grammars
* No more reload for `codeblock` style change

## 0.8.1

* Move all configurations to a central class
* Support alignment in insert image

## 0.8.0

* Enhance table format command
* Add insert new line continue markdown list
* Set default search query when insert link
* Change open new post/draft in same window

## 0.7.5

* Enhance jump table cell behavior
* Change key mappings of jump headings
* Mention Gist to markdown specific styles

## 0.7.4

* Change key mappings of headings to `Ctrl-Alt-[1-5]`
* Add new key mappings for jump-* commands
* Insert reference link with empty title

## 0.7.3

* Rename move-* commands to jump-*
* Add jump-between-reference-definition command
* Fix aborted key bindings

## 0.7.2

* Publish Draft takes care of date prefix

## 0.7.1

* Update cheat sheet
* Fix some menu commands not updated

## 0.7.0

* Insert table dialog
* Add new commands:
  * move to previous/next heading
  * move to next table cell
  * format table
* Changed cheat sheet command
* Re-organize package menus
* Improve insert local image's path

## 0.6.4

* Markdown cheat sheet
* Fix insert reference link at EOF buffer position
* Fix template empty key
* Fix fenced code block regex
* Re-focus editor after cursor action in dialogs

## 0.6.3

* Support customize new post filename

## 0.6.2

* Modify some key mappings
* Improve toggle headings/blockquote on selection
* Async load links.cson in insert link dialog
* Indent link reference by 2 spaces
* Add toggle ul, ol, task list and keystroke styles

## 0.6.1

* Fix key mappings not working
* Add settings for publish draft
* Add toggle block quote
* Support multiple cursors

## 0.6.0

* Insert image dialog
* Add toggle code blocks
* Add keymaps in Windows/Linux

## 0.5.5

* Support Hexo front matters format
* Fix single tag/category in front matters
* Add Hexo generator description in README

## 0.5.4

* Fix auto link check
* Improve reference link insertion position
* Fix last reference link removal

## 0.5.3

* Fix toggle empty headings
* Fix link search box not shown up

## 0.5.2

* Fix add headings on empty line
* Support customizing front matters in new post/draft
* Clean up default settings

## 0.5.1

* Fix consecutive spaces in title
* Restrict commands in Markdown/Text
* Cache fetched posts in memory

## 0.5.0

* Make sure package name is CORRECT! (**require re-install**)
* Create new draft dialog
* Publish draft

## 0.4.3

* Improve tags/categories update
* Fix reference link insertion position

## 0.4.2

* Fix losing manual added tags/categories

## 0.4.1

* Improve front matter matching
* Fix reference link update
* Fix date/time output

## 0.4.0

* Add inline link removal
* Add reference link insertion
* Add reference link removal

## 0.3.0

* Add toggle headings
* Enhance toggle text styles

## 0.2.0

* Add toggle text styles
* Add new key maps
* Remove grammars/snippets
* Clean up code
* Improve insert link dialog

## 0.1.0 - First Release

* Create new post dialog
* Manage tags/categories dialog
* Add link dialog
