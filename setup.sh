#!/bin/bash

is_yes_reply() {
    read -rp "$1 [y/N]: "
    [[ ${REPLY,,} =~ ^y(es)?$ ]]
}

get_bin_dependencies() {
    local binPrograms=(
        'hyprpaper-rand'
        'pactl-vol'
        'hypr-reload'
    )
    local binPath="$HOME/.local/bin"

    [[ -d $binPath ]]|| mkdir "$binPath"

    echo 'Getting executable dependencies...'

    for p in "${binPrograms[@]}"; do
        echo "Installing $p to $binPath..."
        curl -sLo "$binPath/$p" "https://github.com/wick3dr0se/bin/raw/main/$p"
    done
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

get_bin_dependencies
copy_configurations