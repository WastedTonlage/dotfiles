setopt appendhistory autocd
unsetopt beep
bindkey -v

# History
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
bindkey '^R' history-incremental-search-backward

#Colors
autoload -U colors && colors
#Prompt
PS1=" %F{yellow}%/%f %#> "
setopt promptsubst # Subshell expansion in the prompt, not bloated
#Completion
autoload -U compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true
zmodload zsh/complist
compinit
_comp_options+=(globdots)

# Vi mode fancy cursor
function zle-keymap-select {
   if [[ ${KEYMAP} == vicmd ]] ||
      [[ $1 == 'block' ]]; then
	echo -ne '\e[1 q'
    elif [[ ${KEYMAP} == main ]] || 
	    [[ ${KEYMAP} == viins ]] ||
	    [[ ${KEYMAP} = '' ]] ||
	    [[ $1 = 'beam' ]]; then 
    	echo -ne '\e[5 q'
    fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.
#Syntax highlighting module
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh > /dev/null

export EDITOR=nvim

# Makes java applications accept that dwm is a valid wm
export _JAVA_AWT_WM_NONREPARENTING=1

# Makes flutter find chromium
export CHROME_EXECUTABLE="/usr/bin/chromium"

# PATH setup
export PATH="$HOME/dotfiles/scripts:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/Puters/bin:$PATH"
export PATH="/usr/lib/jvm/java-11-openjdk/bin/javac:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.gem/ruby/2.7.0/bin:$PATH"
export PATH="$HOME/src/flutter/bin:$PATH"



# Completion Path
export FPATH="/home/tonlage/Puters/completions:$FPATH"
#General useful aliases (similar to debians bash defaults)
alias grep="grep --color"
alias ls="ls --color"
alias less="less -R"
alias dmenu="dmenu -sb red"
alias pingg="ping 8.8.8.8"
alias shut="sudo shutdown -h now"
alias sus="sudo systemctl suspend"
alias rm="rm -r" # NOTE: Will regret this
alias findall="sudo find / 2>/dev/null"
alias doc="man"
alias vi="nvim"
alias hd="hexdump -C"
alias sx="startx"
alias ports="sudo lsof -i -P | grep --color=never LISTEN"
alias sqlite="sqlite3"
alias cmake="cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
alias horse="for i in {1..4}; do shuf -n1 /usr/share/dict/words | tr -dc '[:alpha:]' | sed 's/.*/\u&/'  ; done"
#alias date="date --rfc-3339=seconds"

#Aliases for configuration files
alias vimrc="vim ~/.config/nvim/init.vim"
alias zshrc="vim ~/dotfiles/zshrc"
alias dwmrc="vim ~/src/dwm/config.h"
alias dwmbrc="vim ~/src/dwmblocks/blocks.h"
alias comprc="vim ~/.config/picom.conf"

# Youtube-dl aliases
alias playlist_dl='youtube-dl --extract-audio --proxy socks5://127.0.0.1:9050 -o "%(playlist_index)s - %(title)s.%(ext)s"'
alias playlist_dl_no_tor='youtube-dl --extract-audio -o "%(playlist_index)s - %(title)s.%(ext)s"'
alias vid_dl='youtube-dl --extract-audio --proxy socks5://127.0.0.1:9050 -o "%(title)s.%(ext)s"'
alias vid_dl_no_tor='youtube-dl --extract-audio -o "%(title)s.%(ext)s"'

# Aliases for not forgetting to turn TOR on
alias nc_no_tor='nc'
# alias nc='nc -x 127.0.0.1:9050'
alias nmap='nmap --proxies socks4://127.0.0.1:9050'

#Generally useful functions
function l() {
	if [ $# -eq 0 ] ; then 
        ls
    else
        cd $1 && ls
    fi
}

# Edit script in PATH
function vit() {
	vi $(which $1)
}

# Write a file with delay per line -- useful for smtp scripting
function slowcat() {
	while read; do
		sleep 0.05
		echo "$REPLY"
	done
}

function rand() {
    echo $(($RANDOM % $1))
}

fpath+=${ZDOTDIR:-~}/.zsh_functions

# Launch graphical shit if it isn't already running
ps -ef | grep -vF grep | grep -F '/usr/lib/Xorg' 2>&1 1>/dev/null || startx 
[ -f "/home/tonlage/.ghcup/env" ] && source "/home/tonlage/.ghcup/env" # ghcup-env
