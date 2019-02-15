#!/bin/sh
echo "Begin Installing Dotfiles..."

COUNTER=0

# Create symlinks in home folder to dotfiles
for dotfile in `find $HOME/dotfiles/dots -not -type d`;
do
    COUNTER=$[COUNTER + 1]
    item=$(basename $dotfile)
    echo "$COUNTER: Creating symbolic link for $dotfile"
    ln -sf $HOME/dotfiles/dots/$item $HOME/$item
done

#Copy files to root home folder
sudo cp ~/.zshrc /root/
sudo cp ~/.bashrc /root/
cp -r ~/dotfiles/custom/ ~/.oh-my-zsh/

echo "Done"