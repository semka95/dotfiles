# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/semyonz/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Path
export GOPATH="$HOME/go"
export PATH="${PATH}:$GOPATH/bin"
export PATH="$HOME/.radicle/bin:$PATH"

# Antigen
source ~/antigen.zsh

# Load Oh My Zsh
antigen use oh-my-zsh

antigen bundle git
antigen bundle command-not-found
antigen bundle docker
antigen bundle docker-compose
antigen bundle golang
antigen bundle heroku
antigen bundle httpie


antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions

antigen theme borekb/agkozak-zsh-theme@prompt-customization
#antigen theme denysdovhan/spaceship-prompt

antigen apply
