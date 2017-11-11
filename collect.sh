#!/bin/zsh
#is file moves selected files to newly created .dotfile folder and creates symbolic synblinks.
 
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
 echo ${Dotfiles[@]}
while true
do
    echo "Do you still wish to continue? Yes [y] No [n]"
    read "reply?Response: "
    if [[ $reply == "y" ]];
    then
    	# 2. create a variable for new directory for storing dotfiles..
		DIR=~/dotfiles
		cd ~ && mkdir -p $DIR
		echo 'Directory created!'
			 
		# move selected dotfiles to new directory .dotfiles
		for dotfile in "${Dotfiles[@]}";
		do
			echo "Moving $dotfile into directory $DIR"
			mv ~/.$dotfile $DIR/
			echo "Creating symbolic for $dotfile"
			ln -s $DIR/.$dotfile ~/.$dotfile
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