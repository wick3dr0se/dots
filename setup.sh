#!/bin/bash

is_yes_reply() {
    read -rp "$1 [y/N]: "
    [[ ${REPLY,,} =~ ^y(es)?$ ]]
}

git_get() {
    curl -sLo "$3" "https://github.com/wick3dr0se/$1/raw/main/$2"
}

copy_configurations() {
    for configPath in configs/.*; do
        config="${configPath#configs/}"
        
        is_yes_reply "Copy $config to $HOME?"&& {
            [[ -e $HOME/$config ]]&& {
                is_yes_reply "File $config already exists. Do you want to replace it?"|| continue
            }

            cp -r "$configPath" "$HOME"
            echo "Copied."
        }
    done
}

get_bin_dependencies() {
    local binPrograms=(
        'hyprpaper-rand'
        'pactl-vol'
        'hypr-reload'
        'grimcap'
    )
    local binPath="$HOME/.local/bin"

    [[ -d $binPath ]]|| mkdir "$binPath"

    echo 'Getting executable dependencies...'

    for p in "${binPrograms[@]}"; do
        if [[ $p == 'grimcap' ]]; then
            repo="$p"
        else
            repo="bin"
        fi

        echo "Installing $p to $binPath..."
        git_get "$repo" "$p" "$binPath/$p"
    done

    chmod +x "$binPath/"*
    
    "$binPath/hypr-reload"
    sleep .5
    "$binPath/hyprpaper-rand"
}

set_shell_prompt() {
    local p='bashrc'

    echo "Setting shell prompt..."
    git_get "$p" ".$p" "$HOME/.$p"
}

copy_configurations
get_bin_dependencies
set_shell_prompt