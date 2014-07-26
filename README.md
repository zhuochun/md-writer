# Markdown-Writer for Atom

Using [Atom](https://atom.io/) as a Markdown blogging editor. Great for [Jekyll](http://jekyllrb.com/) blogging.

## Features

![Insert Link](http://i.imgur.com/F9dLWsH.png)

- Dialog to **create new post**.
  In Command Palette (`shift-cmd-P`), type `Md Writer: New Post`.
- Dialog to **manage tags/categories** in front matter.
  In Command Palette (`shift-cmd-P`), type `Md Writer: Manage Post Tags/Categories`
- Dialog to **insert link** (`cmd-k`) and automatically link to the text at next time (my favorite feature from Windows Live Writer).
  In Command Palette (`shift-cmd-P`), type `Md Writer: Insert Link`
- **Toggle text styles**: `code` (`cmd-'`), **bold** (`cmd-b`), _italic_ (`cmd-i`) and ~~strikethrough~~ (`cmd-h`).

## Populate Tags/Categories

![Manage Tags](http://i.imgur.com/amt2m0Y.png)

To populate tags or categories in dialog, you need to setup the `json` file in setting page.

The `json` file could contain the following information of your blog:

```json
{
  "tags": ["tag a", "tag b"],
  "categories": ["category a", "category b"],
  "posts": [{"title": "title", "url":"url"}]
}
```

If you are using Jekyll, [checkout the scripts to generate these files](https://gist.github.com/fe127356bcf8c07ae1fb.git).

Upload the `JSON` files to your website and add the URLs in `Preferences` page (search `Md Writer` package).

## Progress

The package is under its early development.

I am already using it when I blog. New features will be added along the way.

### Planning:

- Able to remove link from dialog
- Insert image
- Insert table
- Support multiple Jekyll directory

View [CHANGELOG](https://github.com/zhuochun/md-writer/blob/master/CHANGELOG.md)
