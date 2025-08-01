# ~/.bash_profile

set -a # export all
# shell specific envs
PATH="$PATH:~/bin:~/.local/bin:~/.cargo/bin"
EDITOR=/usr/bin/vim
VISUAL=/usr/bin/code

[[ -f ~/.bash_config.d/env ]] && . ~/.bash_config.d/env

set +a

[[ -f ~/.bashrc ]] && . ~/.bashrc

[[ -x ~/.local/bin/session-launch ]] && ~/.local/bin/session-launch
