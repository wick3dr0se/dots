# ~/.bash_profile

export EDITOR='vim'

[[ -f $HOME/.bashrc ]]&& . ~/.bashrc

# include bin directories, if exists
for _ in "$HOME/.local/bin" "$HOME/bin"; do
    [[ -d $_ ]]&& { [[ $PATH =~ $_: ]]|| PATH="$_:$PATH"; }
done
