# ~/.bashrc

# abort if non-interactive shell
[[ $- != *i* ]] && return

shopt -s cmdhist autocd dotglob cdspell dirspell cdable_vars

phosphorGreen='\e[38;2;102;255;102m'
amber='\e[38;2;255;110;106m'
orange='\e[2;38;2;255;176;0m'
gitRed='\e[38;2;243;79;41m'

PROMPT_COMMAND=prompt_command
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=erasedups
HISTTIMEFORMAT="%F %T "

alias b='bash'
alias v='vim'
alias g='git'
alias ls='ls --file-type --color=auto'
alias la='ls -A'
alias ll='ls -l'
alias rm='rm -Ifr'

alias duh='du -sh * | sort -h'
alias ports='ss -tulwn'

alias winboot='systemctl reboot --boot-loader-entry=auto-windows'
alias bios='systemctl reboot --firmware-setup'

extract() {
    [[ -f $1 ]] || { printf 'Invalid file: %s\n' "$1"; return; }

    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz) tar xzf "$1" ;;
        *.tar.xz) tar xJf "$1" ;;
        *.tar.zst) tar --zstd -xf "$1" ;;
        *.bz2) bunzip2 "$1" ;;
        *.gz) gunzip "$1" ;;
        *.xz) unxz "$1" ;;
        *.zst) unzstd "$1" ;;
        *.rar) unrar x "$1" ;;
        *.zip) unzip "$1" ;;
        *.7z) 7z x "$1" ;;
        *.Z) uncompress "$1" ;;
        *) printf 'Unkown archive method: %s\n' "$1";;
    esac
}

cdls() {
    cd -- "$1" || return; ls
}

mkcd() {
  mkdir -p -- "$1" && cdls "$1"
}

prompt_command() {
    local last_cmd title branch tag

    [[ $PWD =~ ^$HOME ]]&& { PWD=${PWD#"$HOME"} PWD=~$PWD; } 

    last_cmd=$(HISTTIMEFORMAT='' history 1 | sed 's/^ *[0-9]* *//')
    title="${PWD##*/}"
    [[ $last_cmd ]] && title+=": ${last_cmd:0:50}"
    printf '\e]0;%s - foot\e' "$title"
    
    printf '%b%s\e[m' "$orange" "$PWD"

    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    tag=$(git describe --tags --abbrev=0 2>/dev/null)
    [[ $branch ]] && printf ' \e[2m%s\e[m %b\e[m \e[2m%s\e[m' "$branch" "$gitRed" "$tag"
    printf '\n'
}

[[ -f ~/.bash_config.d/functions ]] && . ~/.bash_config.d/functions
[[ -f ~/.bash_config.d/aliases ]] && . ~/.bash_config.d/aliases
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
    . ~/.local/share/blesh/ble.sh
elif [[ -f /usr/share/blesh/ble.sh ]]; then
    . /usr/share/blesh/ble.sh
fi

bleopt color_scheme=catppuccin_mocha

if (( EUID )); then
    userSymbol='$' userColor=$phosphorGreen
else
    userSymbol='#' userColor=$amber
fi

PS1="\[$userColor\]\$USER\[\e[m\]@\[$orange\]\$HOSTNAME\[\e[m\] \$((( \$? ))\
    && printf '\[$amber\]$userSymbol\[\e[m\]> '\
    || printf '\[$phosphorGreen\]$userSymbol\[\e[m\]> ')"

# debugging trace prompt
PS4="-[\e[33m${BASH_SOURCE[0]%.sh}\e[m: \e[32m$LINENO\e[m] ${FUNCNAME:+${FUNCNAME[0]}(): }"
