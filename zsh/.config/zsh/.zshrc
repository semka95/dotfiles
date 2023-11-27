# Lines configured by zsh-newuser-install
HISTFILE="$XDG_STATE_HOME"/zsh/history
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
export PATH="${PATH}:$GOPATH/bin"
export PATH="$HOME/.radicle/bin:$PATH"
export PATH="${PATH}:$HOME/.local/bin"

alias ssh="kitty +kitten ssh"
alias du="dust"
alias df="duf"
alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
alias svn="svn --config-dir $XDG_CONFIG_HOME/subversion"
alias monerod=monerod --data-dir "$XDG_DATA_HOME"/bitmonero
alias mitmproxy="mitmproxy --set confdir=$XDG_CONFIG_HOME/mitmproxy"
alias mitmweb="mitmweb --set confdir=$XDG_CONFIG_HOME/mitmproxy"
alias code="codium"
alias less="moar"
alias sudo="doas"
# Antigen
source /usr/share/zsh/share/antigen.zsh

# Load Oh My Zsh
antigen use oh-my-zsh

antigen bundle git
antigen bundle command-not-found
# antigen bundle docker
antigen bundle docker-compose

antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

antigen bundle zdharma-continuum/fast-syntax-highlighting

antigen theme borekb/agkozak-zsh-theme@prompt-customization

antigen apply
