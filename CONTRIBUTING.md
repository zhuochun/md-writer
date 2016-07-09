# Contributing to Markdown Writer

Thanks for taking the time to contribute!

The following is a set of guidelines for contributing to Markdown Writer.

## Submitting Issues

- Include the version of Atom and the Operating System you are using.
- Include reproducing steps, screenshots or animated GIFs whenever possible; they are immensely helpful.
- Include the behavior you expected and other places you've seen that behavior such as Vim, Sublime Text, Emacs, Xcode, etc.
- Check the dev tools (`alt-cmd-i`) for errors to include. If the dev tools are open before the error is triggered, a full stack trace for the error will be logged. If you can reproduce the error, use this approach to get the full stack trace and include it in the issue.

## Pull Requests

Issues and features are recorded in [Issues](https://github.com/zhuochun/md-writer/issues). If your issues or wanted features are not listed, feel free to raise them for discussions.

### Issues/Features

- Issues are tagged with [bug](https://github.com/zhuochun/md-writer/labels/bug). Issues always higher priority to solve.
- Features are tagged with [enhancement](https://github.com/zhuochun/md-writer/labels/enhancement).

[Milestones](https://github.com/zhuochun/md-writer/milestones) are used to group tasks that trying to be solved, based on preceived importance/difficulties.

### Project Setup

- Fork https://github.com/zhuochun/md-writer to your GitHub repository.
- Clone it to your local computer.
- Run `apm link --dev` in the repository.

### Submit a Pull Request

- Start a new branch `git checkout -b branch-name`.
- Run `atom --dev .` and edit files in Atom.
- Commit your changes, with a few tests if possible.
- Push your branch `git push -u origin branch-name` to GitHub.
- Submit a Pull Request through GitHub with a clear description.

## References

- [Contributing to Atom](https://github.com/atom/atom/blob/master/CONTRIBUTING.md)
