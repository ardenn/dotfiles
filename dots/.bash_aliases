#custom aliases Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gst='git stash'
alias gsl='git stash list'
alias gsa='git stash apply'
alias gss='git stash show -p'
alias gsp='git stash pop'
alias gsd='git stash drop'
alias gb='git branch'
alias gch='git checkout'
alias gd='git diff'
alias gr='git remote'
alias gcb='git checkout -b'

#apt
alias install='sudo apt install -y'
alias search='apt search'
alias update='sudo apt update'
alias remove='sudo apt remove'
alias purge='sudo apt purge'
alias autoremove='sudo apt autoremove'
alias upgrade='sudo apt full-upgrade -y'
alias show='apt show'
alias list='apt list'

#systemctl
alias start='sudo systemctl start'
alias restart='sudo systemctl restart'
alias stop='sudo systemctl stop'
alias status='sudo systemctl status'
alias reload='sudo systemctl reload'

#venvs
alias activate='source ../env/bin/activate'
alias activate.='source env/bin/activate'

#utilities
alias clean='sudo ~/scripts/mintcleaner.sh'
alias robo3t='/opt/robo3t/bin/robo3t &'
alias ngrok='~/ngrok/ngrok'

#quick access
alias projects='cd ~/projects'
alias exercises='cd ~/exercises'
alias learn='cd ~/learning\ centre'
alias uget='cd ~/Downloads/uget'
alias twiga-start='start postgresql && start rabbitmq-server && start redis-server'

# nocorrect
alias test='nocorrect make test'
