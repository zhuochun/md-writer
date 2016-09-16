# Markdown Cheat Sheet

Markdown Cheat Sheet for [Markdown-Writer](https://atom.io/packages/markdown-writer) Package.

_To use the key mappings listed, please execute command `Markdown Writer: Create Default Keymaps`. Refer to [wiki][cad8eb1b] for more details._

  [cad8eb1b]: https://github.com/zhuochun/md-writer/wiki/Settings-for-Keymaps "Settings for Keymaps"

## Headings

**Key Mapping:** <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>1-5</kbd>

```
# heading 1
## heading 2
### heading 3
#### heading 4
##### heading 5
```

## Emphasis

- _italics_: `_underscores_`. (<kbd>Cmd</kbd> + <kbd>i</kbd>)
- **Strong**: `**two asterisks**` (<kbd>Cmd</kbd> + <kbd>b</kbd>)
- ~~Strikethrough~~: `~~two tildes~~` (<kbd>Cmd</kbd> + <kbd>h</kbd>)

## Lists

### Ordered List

**Key Mapping:** <kbd>Cmd</kbd> + <kbd>Shift</kbd> + <kbd>O</kbd>

```
1. List 1
  1. Inner list 1
  2. Inner list 2
2. List 2
```

_**TIP:** Use command `Markdown Writer:Correct Order List Numbers` to correct any wrongly ordered numbers._

### Unordered List

**Key Mapping:** <kbd>Cmd</kbd> + <kbd>Shift</kbd> + <kbd>U</kbd>

```
- List 1
  - Inner list 1
- List 2
```

## Links

**Key Mapping:** <kbd>Cmd</kbd> + <kbd>Shift</kbd> + <kbd>K</kbd>

```
inline-style [link](https://www.google.com) is inline.

reference-style [link][id] uses `id`.

  [id]: https://www.google.com
```

## Images

**Key Mapping:** <kbd>Cmd</kbd> + <kbd>Shift</kbd> + <kbd>I</kbd>

```
![image](https://example.com/image.png)
```

## Blockquotes

**Key Mapping:** <kbd>Cmd</kbd> + <kbd>Shift</kbd> + <kbd>></kbd>

```
As Kanye West said:

> We're living the future so
> the present is our past.
```

## Inline Code

**Key Mapping:** <kbd>Cmd</kbd> + <kbd>'</kbd>

```
inline code snippet is `var code = 1;`
```

## Code Blocks

**Key Mapping:** <kbd>Cmd</kbd> + <kbd>Shift</kbd> + <kbd>'</kbd>

You can indent code blocks by 4 spaces or use fenced code block:

<pre>
```
$(function() {
  alert("hello world");
});
```
</pre>

## Tables

**Command:** `Markdown Writer: Insert Table` (<kbd>shift</kbd> + <kbd>cmd</kbd> + <kbd>P</kbd>)

```
First Header                | Second Header
----------------------------|-----------------------------
Content from cell 1         | Content from cell 2
Content in the first column | Content in the second column
```

_**TIP:** Use command `Markdown Writer:Format Table` to format all table cells' spacing._

## Horizontal Rule

Use three or more hyphens.

```
Horizontal rule

---

Next paragraph.
```

## Footnote

**Command:** `Markdown Writer: Insert Footnote`

```
This is some text.[^1]

  [^1]: Some *crazy* footnote definition.
```

## Inline HTML

You can also use raw HTML in your Markdown, and it'll mostly work pretty well.

```html
<dl>
  <dt>Definition list</dt>
  <dd>Is something people use sometimes.</dd>

  <dt>Markdown in HTML</dt>
  <dd>Does *not* work **very** well. Use HTML <em>tags</em>.</dd>
</dl>
```

## More

All Markdown Writer commands can be found by:

- **Command Palette** <kbd>shift</kbd> + <kbd>cmd</kbd> + <kbd>P</kbd> , type `Markdown Writer`
- **Menu Bar -> Packages -> Markdown Writer**

If you prefer to have editing buttons, please try out [Toolbar for Markdown-Writer][340d47db].

  [340d47db]: https://atom.io/packages/tool-bar-markdown-writer "Toolbar for Markdown-Writer"
