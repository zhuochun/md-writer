# Markdown-Writer for Atom

Use [Atom](https://atom.io/) as a Markdown blogging editor. Great for [Jekyll](http://jekyllrb.com/) or static blogs.

> NOTICE: Due to an earlier package name change, there were errors on getting the configurations. **Please re-install the package if you installed before v0.5.0**.

![Insert Link](http://i.imgur.com/F9dLWsH.png)

## Features

- Dialog to **create new post**.
  In Command Palette (`shift-cmd-P`), type `Markdown Writer: New Post`.
- Dialog to **create new draft**.
  In Command Palette (`shift-cmd-P`), type `Markdown Writer: New Draft`.
- **Publish draft** moves current draft to `posts` directory. It updates `date` and rename the post using `title` in front matter.
  In Command Palette (`shift-cmd-P`), type `Markdown Writer: Publish Draft`.
- Dialog to **manage tags/categories in front matter**.
  In Command Palette (`shift-cmd-P`), type `Markdown Writer: Manage Post Tags/Categories`
- Dialog to **insert link (`cmd-k`) and automatically link to the text next time** (my favorite feature from Windows Live Writer).
  - Insert inline link by default
  - Insert reference link if title is specified
  - Remove link (and its reference) after URL is deleted
- **Toggle text styles**: `code` (`cmd-'`), **bold** (`cmd-b`), _italic_ (`cmd-i`) and ~~strikethrough~~ (`cmd-h`).
- **Toggle headings"**: `alt-[1-5]` to switch among `H1` to `H5`.

## Setup

You need to setup package to use most of the features.

Go to `Preferences` (`cmd-,`), search `markdown writer` package.

### Settings Explained:

- **siteLocalDir**: The root directory of blog/jekyll
- **siteDraftsDir**: The directory of drafts from the root of `siteLocalDir`. Default is `_draft/`.
- **sitePostsDir**: The directory of posts from the root of `siteLocalDir`. Default is `_posts/{year}`. You can also use `{year}`, `{month}` and `{day}`.
- **urlForTags**: The URL to tags `JSON` file. Refer to next section.
- **urlForPosts**: The URL to posts `JSON` file. Refer to next section.
- **urlForCategories**: The URL to categories `JSON` file. Refer to next section.

### Advance Settings:

To change these settings, open your Atom config file, find or create `markdown-writer` entry.

- **siteLinkPath**: Path to a `.cson` file that stores all links added for automatic linking next time. Default is `atom-config-directory/markdown-writer-links.cson`.
- **frontMatter**: String of the front matter generated in new post/draft. You can use `<layout>`, `<title>` and `<date>`. Default is:

```text
---
layout: <layout>
title: "<title>"
date: "<date>"
---
```

## Populate Tags/Categories/Posts

![Manage Tags](http://i.imgur.com/amt2m0Y.png)

To **manage tags/categories in front matter**, you need to provide `JSON` files that list existing tags/categories/posts in your blog.

The `JSON` files contain following information of your blog:

```json
{
  "tags": ["tag a", "tag b"],
  "categories": ["category a", "category b"],
  "posts": [{"title": "title", "url":"url"}]
}
```

If you are using Jekyll, you can add [these scripts](https://gist.github.com/zhuochun/fe127356bcf8c07ae1fb) to your Jekyll directory. Upload the generated `JSON` files to website and update the settings.

### TODOs

- Insert image
- Insert table
- Insert footnote
- Support multiple blog directories

View [CHANGELOG :notebook_with_decorative_cover:](https://github.com/zhuochun/md-writer/blob/master/CHANGELOG.md).

If you found any bug, please submit an issue [here :octocat:](https://github.com/zhuochun/md-writer/issues).

License in [MIT :unlock:](https://github.com/zhuochun/md-writer/blob/master/LICENSE.md).

## Tips

- Jumping among your posts: `Cmd-t` or `Cmd-p`.
- Markdown Preview: [markdown-preview](https://atom.io/packages/markdown-preview) package.
