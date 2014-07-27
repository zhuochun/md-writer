# Markdown-Writer for Atom

Using [Atom](https://atom.io/) as a Markdown blogging editor. Great for [Jekyll](http://jekyllrb.com/) or static blogs.

## Features

![Insert Link](http://i.imgur.com/F9dLWsH.png)

- Dialog to **create new post**.
  In Command Palette (`shift-cmd-P`), type `Md Writer: New Post`.
- Dialog to **manage tags/categories in front matter** with selections.
  In Command Palette (`shift-cmd-P`), type `Md Writer: Manage Post Tags/Categories`
- Dialog to **insert link (`cmd-k`) and automatically link to the text next time** (my favorite feature from Windows Live Writer).
  - Insert inline link by default
  - Insert reference link if title is specified
  - Remove link (and its reference) after URL is deleted
- **Toggle text styles**: `code` (`cmd-'`), **bold** (`cmd-b`), _italic_ (`cmd-i`) and ~~strikethrough~~ (`cmd-h`).
- **Toggle headings"**: `alt-[1-5]` to switch among `H1` to `H5`.

## Setup

Go to `Preferences` page (`cmd-,`), search `md-writer` in packages.

Settings:

- **fileExtension**: The file extension of post.
- **siteLinkPath**: The path to a `.cson` file to store all links added for automatic linking next time.
- **siteLocalDir**: The root directory of your blog/jekyll
- **sitePostsDir**: The directory of your posts from the root of `localDir`. Default is `_posts/{year}`. You can also use `{year}`, `{month}` and `{day}`.
- **siteUrl**: The URL of your blog/jekyll. _not in use now_.
- **urlForTags**: The URL to your tags' `JSON` file. Refer to the next section.
- **urlForPosts**: The URL to your posts' `JSON` file. Refer to the next section.
- **urlForCategories**: The URL to your categories' `JSON` file. Refer to the next section.

## Populate Tags/Categories/Posts

![Manage Tags](http://i.imgur.com/amt2m0Y.png)

To populate tags or categories in dialog, you need to provide `JSON` files of the existing tags/categories/posts in your blog and setup them in settings.

The `JSON` files contain following information of your blog:

```json
{
  "tags": ["tag a", "tag b"],
  "categories": ["category a", "category b"],
  "posts": [{"title": "title", "url":"url"}]
}
```

If you are using Jekyll, [add these scripts](https://gist.github.com/zhuochun/fe127356bcf8c07ae1fb) to your site directory. Upload the generated `JSON` files to your website and update the settings.

## Progress

The package is under its early development.

I am already using it when I blog. New features will be added along the way.

### Planning

- Insert image
- Insert table
- Support multiple Jekyll directory

View [CHANGELOG](https://github.com/zhuochun/md-writer/blob/master/CHANGELOG.md).

Submit Issues/Pull Requests at [GitHub](https://github.com/zhuochun/md-writer/).

## Tips

- Jumping among your posts quickly: `Cmd-t` or `Cmd-p`.
- Markdown Preview: [markdown-preview](https://atom.io/packages/markdown-preview) package.
