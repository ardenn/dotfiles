# ardenn's dotfiles

A collection of my personal dotfiles and custom plugins for zsh.

I feel bad when I type the same commands over and over :( Save me sometime with these awesome terminal awesomeness.

Heavily inspired by [Francis Addai](https://github.com/faddai/dotfiles)

## Structure
- The `custom/` directory contains customized versions of [.oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) plugins that keep my terminal awesome.
- The `dots/` diectory has copies of several dotfiles that help me bring up a familiar system configuration on a new unix-like machine.
- `collect.sh` is a utility script that collects the required dotfiles from all over the system - when creating a new dotfiles collection.
- `install.sh` is a utility script that installs the dotfiles into a new system by creating symlinks at the relevant locations to the actual dotfiles.

## Licence
[MIT](https://choosealicense.com/licenses/mit/#)