#!/bin/zsh

# Create symlinks in home folder to dotfiles
for dotfile in `find $HOME/dotfiles/dots`;
do
    then
        echo "Creating symbolic link for $dotfile"
        ln -sf $HOME/dotfiles/dots/$dotfile $HOME/$(basename $dotfile)
    fi
done

#Copy files to root home folder
sudo cp ~/.zshrc /root/
sudo cp ~/.bashrc /root/
