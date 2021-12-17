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

alias ssh="kitty +kitten ssh"
alias cat="bat"
alias du="dust"
alias df="duf"

# Antigen
source ~/antigen.zsh

# Load Oh My Zsh
antigen use oh-my-zsh

antigen bundle git
antigen bundle command-not-found
antigen bundle docker
antigen bundle docker-compose

antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zdharma-continuum/fast-syntax-highlighting

antigen theme borekb/agkozak-zsh-theme@prompt-customization

antigen apply
