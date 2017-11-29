#!/bin/zsh
#moves selected files to newly created .dotfile/dots folder and creates symbolic

# STEPS:.
# 1. create and array of with .dotfiles elements.
# 2. create a new directory .dotfiles if this directory does not exits.
# 3. move selected .dotfiles from step 1 into directory created in step 2.
# 4. create symbolic links for all .dotfiles from step 1.
# 5. initialize a git repo.

# 1. declare an array with .dotfiles element for versioning:
local -a Dotfiles
Dotfiles=("bash_aliases" "bashrc" "gitconfig" "gitignore_global" "zshrc")

# inform the user and print the whole array on the screen:
echo 'Going to move the following selected .dotfiles:'
for item in ${Dotfiles[@]};
do
    echo $HOME/.$item
done
while true
do
    echo "Do you still wish to continue? Yes [y] No [n]"
    read "reply?Response: "
    if [[ $reply == "y" ]];
    then
    	# 2. create a variable for new directory for storing dotfiles..
		DIR=~/dotfiles
		cd ~ && mkdir -p $DIR && mkdir -p $DIR/dots
		echo 'Directory created!'
			 
		# move selected dotfiles to new directory .dotfiles
		for dotfile in ${Dotfiles[@]};
		do
            if [ -e ~/.$dotfile ] && ! [ -L ~/.$dotfile ]
            then
                echo "Moving $dotfile into directory $DIR/dots"
                mv ~/.$dotfile $DIR/dots
            fi
			echo "Creating symbolic for $dotfile"
			ln -sf $DIR/dots/.$dotfile ~/.$dotfile
		done
        break
    elif [[ $reply == "n" ]];
    then
            echo "Exiting..."
            break
    else
            echo "Invalid response, try again!!"
    fi
done