#!/bin/sh

# Create symlinks in home folder to dotfiles
for dotfile in `find $HOME/dotfiles/dots`;
do
    echo "Creating symbolic link for $dotfile"
    ln -sf $HOME/dotfiles/dots $HOME/$(basename $dotfile)
done

#Copy files to root home folder
sudo cp ~/.zshrc /root/
sudo cp ~/.bashrc /root/
