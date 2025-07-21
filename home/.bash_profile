# ~/.bash_profile

set -a # export all
# shell specific envs
PATH="$PATH:~/bin:~/.local/bin:~/.cargo/bin"
EDITOR=/usr/bin/vim
VISUAL=/usr/bin/code
set +a

[[ -f ~/.bashrc ]] && . ~/.bashrc

[[ -x ~/.local/bin/session-launch ]] && ~/.local/bin/session-launch

