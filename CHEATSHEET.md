# Markdown Cheat Sheet

Markdown Cheat Sheet for [Markdown-Writer](https://atom.io/packages/markdown-writer) Package.

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
2. List 2
```

Use command `Markdown Writer:Correct Order List Numbers` to fix any wrong order numbers.

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

**Command Palette <kbd>shift</kbd> + <kbd>cmd</kbd> + <kbd>P</kbd>:** `Markdown Writer: Insert Table`

```
First Header                | Second Header
----------------------------|-----------------------------
Content from cell 1         | Content from cell 2
Content in the first column | Content in the second column
```

Use command `Markdown Writer:Format Table` to fix cell indentations.

## Horizontal Rule

Use three or more hyphens.

```
Horizontal rule

---

Next paragraph.
```

## Footnote

_This syntax feature is not part of the standard Markdown syntax._

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

## Markdown Writer Commands

- **Command Palette <kbd>shift</kbd> + <kbd>cmd</kbd> + <kbd>P</kbd>:** `Markdown Writer`
- **Menu Bar -> Packages -> Markdown Writer**
