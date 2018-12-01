# Markdown-Writer for Atom

[![Apm Version](https://img.shields.io/apm/v/markdown-writer.svg)](https://atom.io/packages/markdown-writer)
[![Apm Downloads](https://img.shields.io/apm/dm/markdown-writer.svg)](https://atom.io/packages/markdown-writer)
[![Travis Build Status](https://travis-ci.org/zhuochun/md-writer.svg?branch=master)](https://travis-ci.org/zhuochun/md-writer)
[![Appveyor Build status](https://ci.appveyor.com/api/projects/status/fv1unuiac1umt44f?svg=true)](https://ci.appveyor.com/project/zhuochun/md-writer)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)

Adds tons of features to make [Atom](https://atom.io/) a better Markdown/AsciiDoc editor!

Works great with static blogging as well. Try it with [Jekyll](http://jekyllrb.com/), [Octopress](http://octopress.org/), [Hexo](http://hexo.io/) or any of your favorite static blog engines.

![Insert Image](http://i.imgur.com/s9ekMns.gif)

More GIFs Here: [Create New Post](http://i.imgur.com/BwntxhB.gif), [Insert Reference Link](http://i.imgur.com/L67TqyF.gif), [Remove Reference Link](http://i.imgur.com/TglzeJV.gif).

<details>
  <summary><strong>Table of Contents</strong> (click to expand)</summary>

<!-- TOC depthFrom:2 -->
- [Features](#features)
  - [Blogging](#blogging)
  - [General](#general)
- [Installation](#installation)
- [Setup](#setup)
- [Contributing](#contributing)
- [Project](#project)
<!-- /TOC -->
</details>

## Features

### Blogging

- **Create new draft** with front matters ([setup^][ca8870d7]).
- **Create new post** with front matters ([setup^][ca8870d7]).
- **Publish draft** moves a draft to post's directory with front matters (`date`, `published`) auto updated.
- **Manage tags and categories** in front matters ([setup*][9be76601]).
- **Custom fields** in front matters ([setup*][9be76601]).
- **Project/Blog specific settings** supported ([setup+][1561ed4c]).

[ca8870d7]: https://github.com/zhuochun/md-writer/wiki/Quick-Start "Markdown-Writer Setup Guide"
[9be76601]: https://github.com/zhuochun/md-writer/wiki/Settings-for-Front-Matters "Setup Tags/Categories/Posts"
[1561ed4c]: https://github.com/zhuochun/md-writer/wiki/Settings#project-specific-settings "Project Specific Settings"

### General

- **Continue lists or table rows** when you press `enter` ([customize][adaa9527]).
  - **Correct ordered list numbers** (`markdown-writer:correct-order-list-numbers`).
- **Table of contents (TOC)** (`markdown-writer:insert-toc`), and support following options (global or inline):
  - `depthFrom`, `depthTo`: range of headings to be displayed.
  - `insertAnchor`: insert TOC with anchor link.
- **Insert link** (`shift-cmd-k`), and **automatically link to the text next time**.
  - Insert inline link.
  - Insert reference link with title. _Use `-` in title field to create an empty title reference link._
  - Remove link (and its reference) after URL is deleted.
  - Search published posts by title in your blog.
- **Insert footnote** (`markdown-writer:insert-footnote`), and edit footnote labels.
- **Insert image from file or clipboard** (`shift-cmd-i`), preview image and able to copy image to your blog's images directory.
- **Insert table** (`markdown-writer:insert-table`), and quick **jump to next table cell** (`cmd-j cmd-t`).
- **Format table** (`markdown-writer:format-table`) with table alignments.
- **Toggle headings**: `ctrl-alt-[1-5]` to switch among `H1` to `H5`.
- **Toggle text styles** ([customize styles][7ddaeaf4]):
  - `code` (`cmd-'`)
  - **bold** (`cmd-b`)
  - _italic_ (`cmd-i`)
  - ~~strike through~~ (`cmd-h`)
  - `'''code block'''` (`shift-cmd-"`)
  - `<kbd>key</kbd>` (`cmd + k`)
  - `- unordered list` (`shift-cmd-U`)
  - `0. ordered list` (`shift-cmd-O`)
  - `> blockquote` (`shift-cmd->`)
  - `- [ ] task list` (`markdown-writer:toggle-task`)
- **Jumping commands**:
  - Jump to previous heading (`cmd-j cmd-p`)
  - Jump to next heading (`cmd-j cmd-n`)
  - Jump to next table cell (`cmd-j cmd-t`)
  - Jump to reference marker/definition (`cmd-j cmd-d`)
- **Folding commands**: fold all inline links (`markdown-writer:fold-links`).
- **Open a link under cursor** in browser (`markdown-writer:open-link-in-browser`), and this works on reference links.
- **Markdown cheat sheet** (`markdown-writer:open-cheat-sheet`).
- **Toolbar for Markdown Writer** is available at [tool-bar-markdown-writer][82a2aced].
- **[CriticMarkup][f99bc01e] support**:
  - Addition `{++ ++}` (`markdown-writer:toggle-addition-text`)
  - Deletion `{-- --}` (`markdown-writer:toggle-deletion-text`)
  - Substitution `{~~ ~> ~~}` (`markdown-writer:toggle-substitution-text`)
  - Comment `{>> <<}` (`markdown-writer:toggle-comment-text`)
  - Highlight `{== ==}{>> <<}` (`markdown-writer:toggle-highlight-text`)
- **[AsciiDoc][0e2299b8] support** with [language-asciidoc][2f0cb1f9].

[82a2aced]: https://atom.io/packages/tool-bar-markdown-writer "Toobar for Markdown Writer"
[2f0cb1f9]: https://atom.io/packages/language-asciidoc "AsciiDoc Language Package for Atom"
[adaa9527]: https://github.com/zhuochun/md-writer/wiki/Settings#use-different-unordered-list-styles "Customizations"
[f99bc01e]: http://criticmarkup.com/users-guide.php "CriticMarkup"
[0e2299b8]: https://asciidoctor.org/docs/asciidoc-syntax-quick-reference/ "AsciiDoc Quick Reference"

You can find and trigger all features through:

- Open Command Palette (`shift-cmd-P`), enter `Markdown Writer`
- Or, go to menu `Packages -> Markdown Writer`.

## Installation

- In Atom, go to Settings (`cmd-,`) -> Install -> Search `Markdown Writer`.
- Or, run `apm install markdown-writer`.

> If you see errors after this plugin updates, please restart Atom so that it reloads the updated code.

## Setup

Execute command `Markdown Writer: Create Default keymaps` to add recommended keymaps to your configs, and start modifying them based on your needs ([wiki][31ebd53f]).

- `Enter`, `Tab`, `Shift-Tab` are registered by default. You can disable them in _Package's Settings > Keybindings_.

Configure your Package's Settings. Menu: _File -> Settings (`cmd-,`) -> Packages -> Markdown-Writer -> Settings_.

- To **manage tags/categories in front matter**, follow this [setup][35eb9cc2].
- To **manage all/advanced configurations (e.g. project specific settings, change italic text styles)**, follow this [setup][7ddaeaf4].

[31ebd53f]: https://github.com/zhuochun/md-writer/wiki/Settings-for-Keymaps "Settings for Keymaps"
[3ecd2daa]: https://github.com/atom/settings-view/issues/356 "Viewing a package's settings should activate it"
[35eb9cc2]: https://github.com/zhuochun/md-writer/wiki/Settings-for-Front-Matters "Settings for Front Matters"
[7ddaeaf4]: https://github.com/zhuochun/md-writer/wiki/Settings "Settings"

## Contributing

Your contributions are really appreciated. You can follow [CONTRIBUTING](https://github.com/zhuochun/md-writer/blob/master/CONTRIBUTING.md) guide to get everything started.

## Project

- View [CHANGELOG][e45121fa] :notebook_with_decorative_cover:
- Bugs, suggestions or feature requests, [open an issue][e6ad7ed1] :octocat:
- Star [GitHub repo][e8960946] and [Atom package][91a1b9c2] to support this project :+1:
- License in [MIT][6a9a3773] :unlock:
- Shipped by [Zhuochun][41ae693b] :sunny: and [contributors][f303810e] :clap:

[e45121fa]: https://github.com/zhuochun/md-writer/blob/master/CHANGELOG.md
[e6ad7ed1]: https://github.com/zhuochun/md-writer/issues
[6a9a3773]: https://github.com/zhuochun/md-writer/blob/master/LICENSE.md
[41ae693b]: https://github.com/zhuochun
[f303810e]: https://github.com/zhuochun/md-writer/graphs/contributors
[e8960946]: https://github.com/zhuochun/md-writer
[91a1b9c2]: https://atom.io/packages/markdown-writer
