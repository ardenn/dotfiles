#!/bin/sh
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Setting up My Ubuntu ..."

echo "  Updating the system ..."
sudo apt update && sudo apt upgrade

# echo "  Installing Ubuntu Restricted Extras ..."
sudo apt install ubuntu-restricted-extras

echo "  Installing git"
sudo apt install git

echo "  Downloading dotfiles"
git clone git@github.com:ardenn/dotfiles.git

echo "  Installing dotfiles"
./dotfiles/install.sh


echo "Begin Installing Apps..."

echo "1. Installing ZSH..."
sudo apt install zsh

echo "      Switching to ZSH..."
chsh -s $(which zsh)

echo "2. Installing oh-my-zsh"
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

apps="tlp tlp-rdw gnome-tweak-tool postgresql postgresql-contrib htop zeal kazam gufw python3-pip curl chrome-gnome-shell gnupg"
echo "$COUNTER. Installing $apps"
sudo apt install $apps

echo "$COUNTER. Installing virtualenv"
pip3 install virtualenv
COUNTER=$[COUNTER + 1]

echo "$COUNTER. Installing Uget and Uget-Integrator"
sudo add-apt-repository ppa:plushuang-tw/uget-stable
sudo apt install uget aria2

sudo add-apt-repository ppa:uget-team/ppa
sudo apt install uget-integrator

echo "$COUNTER. Installing Etcher"
echo "deb https://deb.etcher.io stable etcher" | sudo tee /etc/apt/sources.list.d/balena-etcher.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
sudo apt update
sudo apt install -y balena-etcher-electron
COUNTER=$[COUNTER + 1]

echo "$COUNTER. Installing MPV"
sudo add-apt-repository ppa:mc3man/mpv-tests
sudo apt install -y mpv
COUNTER=$[COUNTER + 1]

# echo "$COUNTER. Installing Mongo"
# sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
# echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
# sudo apt update
# sudo apt install -y mongodb-org
# COUNTER=$[COUNTER + 1]

echo "$COUNTER. Installing node"
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt install -y nodejs
COUNTER=$[COUNTER + 1]

echo "$COUNTER. Installing yarn"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install -y yarn
COUNTER=$[COUNTER + 1]

echo "$COUNTER. Installing Communitheme"
snap install communitheme

echo "$COUNTER. Installing Rabbitmq"
## Install RabbitMQ signing key
curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc | sudo apt-key add -
## Install apt HTTPS transport
sudo apt install apt-transport-https

## Add Bintray repositories that provision latest RabbitMQ and Erlang 21.x releases
sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list <<EOF
## Installs the latest Erlang 21.x release.
## Change component to "erlang" to install the latest version (22.x or later).
deb https://dl.bintray.com/rabbitmq-erlang/debian bionic erlang-21.x
deb https://dl.bintray.com/rabbitmq/debian bionic main
EOF

## Update package indices
sudo apt update -y

## Install rabbitmq-server and its dependencies
sudo apt install rabbitmq-server -y --fix-missing


echo "Done"
