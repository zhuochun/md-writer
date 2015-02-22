# Markdown-Writer for Atom

Makes [Atom](https://atom.io/) a better Markdown editor!

Works great with static blogs. Try it with [Jekyll](http://jekyllrb.com/), [Octopress](http://octopress.org/), [Hexo](http://hexo.io/) and any other static blog engines.

![Insert Image](http://i.imgur.com/s9ekMns.gif)

More GIFs Here:

- [Create New Post](http://i.imgur.com/BwntxhB.gif)
- [Insert Reference Link](http://i.imgur.com/L67TqyF.gif)
- [Remove Reference Link](http://i.imgur.com/TglzeJV.gif)

## Features

- **Create new post** with front matters.
- **Create new draft** with front matters.
- **Publish draft** moves file to `_posts` directory, updates `date` and optionally renames the filename using `title` in front matter.
- **Manage blog tags and categories in front matters**.
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
- **Project specific settings**.
- **Markdown cheat sheet** (`Markdown Writer: Open Cheat Sheet`).

You can find and trigger all features in:

- Command Palette (`shift-cmd-P`), enter `Markdown Writer`
- Menu Bar `Packages -> Markdown Writer`.

## Setup

To use features like `create draft/post`, Markdown-Writer needs to be configured. E.g. to know the path to your blog.

Go to Preferences (`cmd-,`) -> Packages -> markdown-writer -> Settings.

### Basic Settings:

> If you could not see these settings (due to [Atom's bug][3ecd2daa]), please activate Markdown-Writer by activate any command (e.g. `Open Cheat Sheet`). Close and reopen Preferences.

[3ecd2daa]: https://github.com/atom/settings-view/issues/356 "Viewing a package's settings should activate it"

- **siteEngine**: The static engine of your blog.
- **siteLocalDir**: The path to the directory of your blog.
- **siteDraftsDir**: The sub-path to your drafts from the `siteLocalDir`. Default is `_draft/`.
- **sitePostsDir**: The sub-path to your posts from the `siteLocalDir`. Default is `_posts/{year}`. You can use `{year}`, `{month}` and `{day}`.
- **siteImagesDir**: The sub-path to your images from the `siteLocalDir`. Default is `images/{year}/{month}/`.
- **newPostFileName**: The filename format of new posts created. Default is `{year}-{month}-{day}-{title}{extension}`.
- **fileExtension**: The file extension of your posts/drafts. Default is `.markdown`.
- **urlForTags**: The URL to tags `JSON` file. Refer to next section.
- **urlForPosts**: The URL to posts `JSON` file. Refer to next section.
- **urlForCategories**: The URL to categories `JSON` file. Refer to next section.

### Project Specific Settings:

Create a `_mdwriter.cson` file under your project/blog. See [this commit][02399ed7] for example.

[02399ed7]: https://github.com/zhuochun/zhuochun.github.io/commit/cb34e3c16d42c52b281c34920ad55bbca223ac23 "zhuochun.github.io"

### Advance Settings:

To change these settings, you need to edit in `Atom -> Your Config` file.

- **siteLinkPath**: Define path (string) to a `.cson` file that stores all links added for automatic linking next time. Default uses `markdown-writer-links.cson` in Atom's config directory.
- **frontMatter**: Define front matter (string) used when create new post/draft.
- **codeblock**: Define fenced code block (object). Default uses GitHub's fenced code block.
- **imageTag**: Define image tag inserted (string). Default uses `![alt](img-url)`.
- **projectConfigFile**: Define the project specific `.cson` config file (string). Default uses `_mdwriter.cson`.

This is an example of advance configuration:

```coffee
'markdown-writer':
  # sync the saved links in dropbox
  'siteLinkPath': '/Users/zhuochun/Dropbox/blog/links.cson'
  # use Hexo front matter format
  'frontMatter': """
  layout: <layout>
  title: "<title>"
  date: "<date>"
  ---
  """
  # use Jekyll highlight code block
  # change this requires reload, shift-cmd-P -> Window Reload
  'codeblock':
    'before': '{% highlight %}\n'
    'after': '\n{% endhighlight %}'
    'regexBefore': '{% highlight(?: .+)? %}\n'
    'regexAfter': '\n{% endhighlight %}'
  # use Octopress img tag
  'imageTag': "{% img <align> <src> <width> <height> '{alt}' %}"
```

## Setup Tags/Categories/Posts

![Manage Tags](http://i.imgur.com/amt2m0Y.png)

To **manage tags/categories in front matter** or **search published posts when inserting links**, the Markdown-Writer needs to read `JSON` files that contains the following information of your blog:

```json
{
  "tags": [ "tag a", "tag b", "..." ],
  "categories": [ "category a", "category b", "..." ],
  "posts": [ {"title": "post a", "url": "url/to/post/a" } ]
}
```

If you use **Jekyll/Octopress**, download [these scripts](https://gist.github.com/zhuochun/fe127356bcf8c07ae1fb) to your blog, generate and upload your blog again. Setup the full URLs to these files in Settings.

If you use **Hexo**, you can install [hexo-generator-atom-markdown-writer-meta](https://github.com/timnew/hexo-generator-atom-markdown-writer-meta) (Thanks to [@timnew](https://github.com/timnew)). Generate and upload your blog again. Setup the full URLs to these files in Settings.

## FAQs

#### How to disable default key mappings, e.g. `ctrl-alt-[1-5]`?

Go to `Atom -> Open your Keymap`, paste the following:

```coffee
'.platform-darwin atom-text-editor':
  'ctrl-alt-1': 'unset!'
  'ctrl-alt-2': 'unset!'
  'ctrl-alt-3': 'unset!'
  'ctrl-alt-4': 'unset!'
  'ctrl-alt-5': 'unset!'
```

Default mappings can be found in [keymaps/md.cson](https://github.com/zhuochun/md-writer/blob/master/keymaps/keymap.cson).

A list of all commands can also be found [here](https://github.com/zhuochun/md-writer/blob/master/package.json).

## Project

- View [CHANGELOG][e45121fa] :notebook_with_decorative_cover:.
- Bugs, suggestions & feature requests, [open an issue][e6ad7ed1] :octocat:.
- License in [MIT][6a9a3773] :unlock:.
- Authored by [Zhuochun][41ae693b] :sunny:.

[e45121fa]: https://github.com/zhuochun/md-writer/blob/master/CHANGELOG.md
[e6ad7ed1]: https://github.com/zhuochun/md-writer/issues
[6a9a3773]: https://github.com/zhuochun/md-writer/blob/master/LICENSE.md
[41ae693b]: https://github.com/zhuochun

## Tips

- A light theme targets Markdown: Copy [this Gist](https://gist.github.com/zhuochun/b3659bcea98fca56cb43) to your Stylesheet.
  - Better highlights for all syntax in Markdown.
- Jumping among your posts: `Cmd-t` or `Cmd-p`.
- Markdown Preview: [markdown-preview](https://atom.io/packages/markdown-preview) package.
