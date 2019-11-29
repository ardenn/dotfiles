#!/bin/zsh
#moves selected files to newly created .dotfile/dots folder and creates symbolic

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
BOLD="\033[1m"
RESET="\033[m"

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
echo "\n${YELLOW}Going to move the following selected dotfiles:${RESET}\n"
for item in ${Dotfiles[@]};
do
    echo "\t- ${BLUE}${HOME}/.${item}${RESET}"
done
while true
do
    echo "\n${YELLOW}Do you still wish to continue? Yes [y] No [n]${RESET}"
    read "reply?Response: "
    if [[ $reply == "y" ]];
    then
    	# 2. create a variable for new directory for storing dotfiles..
		DIR=~/dotfiles
		cd ~ && mkdir -p $DIR/dots
		echo "${GREEN}Directory created!${RESET}\n"
			 
		# move selected dotfiles to new directory .dotfiles
		for dotfile in ${Dotfiles[@]};
		do
            if [ -e ~/.$dotfile ] && ! [ -L ~/.$dotfile ]
            then
                echo "${BLUE}\t - Moving $dotfile into directory $DIR/dots${RESET}"
                mv ~/.$dotfile $DIR/dots
            fi
			echo "\t- ${BLUE}Creating symbolic for $dotfile${RESET}"
			ln -sf $DIR/dots/.$dotfile ~/.$dotfile
		done
        break
    elif [[ $reply == "n" ]];
    then
            echo "${GREEN}Exiting...${RESET}"
            break
    else
            echo "${RED}Invalid response, try again!!${RESET}"
    fi
done
