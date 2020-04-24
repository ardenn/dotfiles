#!/bin/sh
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
BOLD="\033[1m"
RESET="\033[m"

echo "${BLUE}Welcome, Setting up ...${RESET}\n"
cd ~

echo "\t${YELLOW}Step 1: Updating the system ...${RESET}\n"
sudo apt update && sudo apt upgrade

echo "\t${YELLOW}Step 2: Installing Ubuntu Restricted Extras ...${RESET}\n"
sudo apt install ubuntu-restricted-extras

echo "\t${YELLOW}Step 3: Installing git...${RESET}\n"
sudo apt install git

echo "\t${YELLOW}Step 4: Downloading dotfiles...${RESET}\n"
git clone https://github.com/ardenn/dotfiles.git

echo "\n\n${BLUE}Begin Installing Apps...${RESET}\n"

echo "\t${YELLOW}Step 6: Installing ZSH...${RESET}\n"
sudo apt install zsh

echo "\t${YELLOW}Step 7: Switching to ZSH...${RESET}\n"
chsh -s $(which zsh)

echo "\t${YELLOW}Step 8: Installing oh-my-zsh${RESET}\n"
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

echo "\t${YELLOW}Step 9: Installing dotfiles... ${RESET}\n"
./dotfiles/install.sh

echo "\t${YELLOW}Step 10: Installing Apps ...${RESET}\n"
sudo apt install tlp tlp-rdw postgresql postgresql-contrib htop kazam gufw python3-pip python3-dev curl gnupg

echo "\t${YELLOW}Step 11: Installing virtualenv ...${RESET}\n"
pip3 install virtualenv

echo "\t${YELLOW}Step 12: Installing Uget and Uget-Integrator ...${RESET}\n"
sudo add-apt-repository ppa:uget-team/ppa
sudo apt install uget aria2 uget-integrator

echo "\t${YELLOW}Step 13: Installing Etcher...${RESET}\n"
echo "deb https://deb.etcher.io stable etcher" | sudo tee /etc/apt/sources.list.d/balena-etcher.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
sudo apt update
sudo apt install -y balena-etcher-electron

echo "\t${YELLOW}Step 14: Installing MPV...${RESET}\n"
sudo add-apt-repository ppa:mc3man/mpv-tests
sudo apt install -y mpv

# echo "$COUNTER. Installing Mongo"
# sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
# echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
# sudo apt update
# sudo apt install -y mongodb-org
# COUNTER=$[COUNTER + 1]

echo "\t${YELLOW}Step 15: Installing node...${RESET}\n"
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt install -y nodejs

echo "\t${YELLOW}Step 16: Installing yarn...${RESET}\n"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install -y yarn

echo "\t${YELLOW}Step 17: Installing Brave...${RESET}\n"
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser

echo "\t${YELLOW}Step 18: Installing RabbitMQ...${RESET}\n"
# ## Install RabbitMQ signing key
curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc | sudo apt-key add -
# ## Install apt HTTPS transport
sudo apt install apt-transport-https

# ## Add Bintray repositories that provision latest RabbitMQ and Erlang 21.x releases
sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list <<EOF
## Installs the latest Erlang 21.x release.
## Change component to "erlang" to install the latest version (22.x or later).
deb https://dl.bintray.com/rabbitmq-erlang/debian bionic erlang
deb https://dl.bintray.com/rabbitmq/debian bionic main
EOF

# ## Update package indices
sudo apt update -y

# ## Install rabbitmq-server and its dependencies
sudo apt install rabbitmq-server -y --fix-missing

echo "\t${YELLOW}Step 19: Restore Keyboard shortcuts... ${RESET}\n"
dconf load /org/gnome/desktop/wm/keybindings/ < ./dotfiles/keybindings.dconf

echo "\t${YELLOW}Step 20: Cleaning up...${RESET}\n"
sudo apt --purge autoremove

echo "\n${GREEN}Done 😀️${RESET}\n"
