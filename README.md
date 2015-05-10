# Markdown-Writer for Atom

Makes [Atom](https://atom.io/) a better Markdown editor with tons of features!

Works great with static blogging. Try it with [Jekyll](http://jekyllrb.com/), [Octopress](http://octopress.org/), [Hexo](http://hexo.io/) and any of your favorite static blog engines.

![Insert Image](http://i.imgur.com/s9ekMns.gif)

More GIFs Here: [Create New Post](http://i.imgur.com/BwntxhB.gif), [Insert Reference Link](http://i.imgur.com/L67TqyF.gif), [Remove Reference Link](http://i.imgur.com/TglzeJV.gif).

## Features

- **Create new post** with front matters ([setup required][ca8870d7]).
- **Create new draft** with front matters ([setup required][ca8870d7]).
- **Publish draft** moves file to `_posts` directory, updates `date` and optionally renames the filename using `title` in front matter.
- **Manage blog tags and categories in front matters** ([setup required][9be76601]).
- **Continue markdown lists** when you press `enter`.
- **Insert link** (`shift-cmd-k`) and **automatically link to the text next time** (My favorite feature from Windows Live Writer).
  - Insert inline link (by default).
  - Insert reference link if title is specified. _Use `-` in title field to create an empty title reference link._
  - Remove link (and its reference) after URL is deleted.
  - Search published posts by title.
- **Insert image** (`shift-cmd-i`), auto-detect images' heights and widths, and optionally copy images to your site's images directory.
- **Insert table** (`markdown-writer:insert-table`), and a shortcut to **jump to next table cell** (`cmd-j cmd-t`).
- **Format table** (`markdown-writer:format-table`).
- **Toggle text styles**:
  - `code` (`cmd-'`)
  - **bold** (`cmd-b`)
  - _italic_ (`cmd-i`)
  - ~~strikethrough~~ (`cmd-h`)
  - `'''codeblock'''` (`shift-cmd-"`)
  - `<kbd>key</kbd>` (`cmd + k`)
  - `- unordered list` (`shift-cmd-U`)
  - `0. ordered list` (`shift-cmd-O`)
  - `> blockquote` (`shift-cmd->`)
  - `- [ ] task list` (`markdown-writer:toggle-task`)
- **Toggle headings**: `ctrl-alt-[1-5]` to switch among `H1` to `H5`.
- **Helper commands**:
  - Jump to previous heading (`cmd-j cmd-p`)
  - Jump to next heading (`cmd-j cmd-n`)
  - Jump to next table cell (`cmd-j cmd-t`)
  - Jump to reference marker/definition (`cmd-j cmd-d`)
- Support **project specific settings** ([view setup][1561ed4c]).
- **Markdown cheat sheet** (`Markdown Writer: Open Cheat Sheet`).

  [ca8870d7]: https://github.com/zhuochun/md-writer/wiki/Quick-Start "Markdown-Writer Setup Guide"
  [9be76601]: https://github.com/zhuochun/md-writer/wiki/Settings-for-Front-Matters "Setup Tags/Categories/Posts"
  [1561ed4c]: https://github.com/zhuochun/md-writer/wiki/Settings#project-specific-settings "Project Specific Settings"

You can find and trigger all features in:

- Open Command Palette (`shift-cmd-P`), enter `Markdown Writer`
- Or, go to menubar `Packages -> Markdown Writer`.

## Installation

- In Atom, go to Settings (`cmd-,`) -> Install -> Search `Markdown Writer`.
- Or, run `apm install markdown-writer`.

## Setup

Go to Settings (`cmd-,`) -> Packages -> `markdown-writer` -> Settings.

> If you do not see any settings (due to a [Atom's bug][3ecd2daa]), please activate Markdown-Writer using command (e.g. `Open Cheat Sheet`). Close and reopen the Settings page.

[View setting explanations][7ddaeaf4] if you have any doubts.

[3ecd2daa]: https://github.com/atom/settings-view/issues/356 "Viewing a package's settings should activate it"
[7ddaeaf4]: https://github.com/zhuochun/md-writer/wiki/Settings "Settings"

To **manage tags/categories in front matter**, please [follow this setup](https://github.com/zhuochun/md-writer/wiki/Settings-for-Front-Matters).

## Project

- View [CHANGELOG][e45121fa] :notebook_with_decorative_cover:.
- Bugs, suggestions & feature requests, [open an issue][e6ad7ed1] :octocat:.
- License in [MIT][6a9a3773] :unlock:.
- Authored by [Zhuochun][41ae693b] :sunny:.

[e45121fa]: https://github.com/zhuochun/md-writer/blob/master/CHANGELOG.md
[e6ad7ed1]: https://github.com/zhuochun/md-writer/issues
[6a9a3773]: https://github.com/zhuochun/md-writer/blob/master/LICENSE.md
[41ae693b]: https://github.com/zhuochun
