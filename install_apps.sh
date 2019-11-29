#!/bin/sh
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
BOLD="\033[1m"
RESET="\033[m"

echo "${BLUE}Welcome, Setting up ...${RESET}\n"

echo "\t${YELLOW}Step 1:${RESET} Updating the system ...\n"
sudo apt update && sudo apt upgrade

echo "\t${YELLOW}Step 2:${RESET} Installing Ubuntu Restricted Extras ..."
sudo apt install ubuntu-restricted-extras

echo "\t${YELLOW}Step 3:${RESET} Installing git"
sudo apt install git

echo "\t${YELLOW}Step 4:${RESET} Downloading dotfiles"
git clone https://github.com/ardenn/dotfiles.git

echo "\t${YELLOW}Step 5:${RESET} Installing dotfiles"
./dotfiles/install.sh


echo "\n\n${BLUE}Begin Installing Apps...${RESET}"

echo "\t${YELLOW}Step 6:${RESET} Installing ZSH..."
sudo apt install zsh

echo "\t${YELLOW}Step 7:${RESET} Switching to ZSH..."
chsh -s $(which zsh)

echo "\t${YELLOW}Step 8:${RESET} Installing oh-my-zsh"
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

echo "\t${YELLOW}Step 9:${RESET} Installing Apps ..."
sudo apt install tlp tlp-rdw gnome-tweak-tool postgresql postgresql-contrib htop kazam gufw python3-pip python3-dev curl chrome-gnome-shell gnupg

echo "\t${YELLOW}Step 10:${RESET} Installing virtualenv ..."
pip3 install virtualenv

echo "\t${YELLOW}Step 11:${RESET} Installing Uget and Uget-Integrator ..."
sudo add-apt-repository ppa:plushuang-tw/uget-stable
sudo apt install uget aria2

sudo add-apt-repository ppa:uget-team/ppa
sudo apt install uget-integrator

echo "\t${YELLOW}Step 12:${RESET} Installing Etcher..."
echo "deb https://deb.etcher.io stable etcher" | sudo tee /etc/apt/sources.list.d/balena-etcher.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
sudo apt update
sudo apt install -y balena-etcher-electron

echo "\t${YELLOW}Step 13:${RESET} Installing MPV..."
sudo add-apt-repository ppa:mc3man/mpv-tests
sudo apt install -y mpv

# echo "$COUNTER. Installing Mongo"
# sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
# echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
# sudo apt update
# sudo apt install -y mongodb-org
# COUNTER=$[COUNTER + 1]

echo "\t${YELLOW}Step 14:${RESET} Installing node..."
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt install -y nodejs

echo "\t${YELLOW}Step 15:${RESET} Installing yarn..."
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install -y yarn

# echo "\t${YELLOW}Step 16:${RESET} Installing Communitheme"
# snap install communitheme

# echo "$COUNTER. Installing Rabbitmq"
# ## Install RabbitMQ signing key
# curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc | sudo apt-key add -
# ## Install apt HTTPS transport
# sudo apt install apt-transport-https

# ## Add Bintray repositories that provision latest RabbitMQ and Erlang 21.x releases
# sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list <<EOF
# ## Installs the latest Erlang 21.x release.
# ## Change component to "erlang" to install the latest version (22.x or later).
# deb https://dl.bintray.com/rabbitmq-erlang/debian bionic erlang-21.x
# deb https://dl.bintray.com/rabbitmq/debian bionic main
# EOF

# ## Update package indices
# sudo apt update -y

# ## Install rabbitmq-server and its dependencies
# sudo apt install rabbitmq-server -y --fix-missing
echo "\t${YELLOW}Step 14:${RESET} Cleaning up..."
sudo apt --purge autoremove

echo "\n${GREEN}Done 😀️${RESET}"
