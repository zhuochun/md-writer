# Md-Writer for Atom

[Md-Writer](https://github.com/zhuochun/md-writer) is an [Atom](https://atom.io/) package
that assists blogging in Markdown, e.g. Jekyll.

## Features

- Create post with front matter dialog
- Manage tags dialog
- Manage categories dialog
- Add link dialog and automatically link to text
- Grammars to recognize YAML font matter

## Setup

To populate tags, categories and posts in dialogs,
you need to supply `json` files in format:

```json
{
  "tags": ["tag"]
  "categories": ["category"]
  "posts": [{"title": "title", "url":"url"}]
}
```

If you are using Jekyll, [checkout the scripts here](https://gist.github.com/fe127356bcf8c07ae1fb.git).
Upload the `JSON` files to your website and add the URLs in setting page.

## Known Issues

The package is still under early development.
However, I am using it for blogging already.

- Markdown Preview package does not recognize new grammar
- Remove existing link missing
