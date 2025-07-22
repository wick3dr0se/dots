#!/bin/bash
# A simple, lightweight dotfiles installer; kinda like GNU Stow
#
# Features:
# - Supports multiple environments (niri, hyprland)
# - Lets you choose between symlinking or copying files
# - Overwrite via prompt or backup existing files with timestamped .bak* suffixes
# - Installs dotfiles & scripts into ~/, ~/.config & ~/.local/bin
#
# Why not Stow?
# - This script avoids Stow's nested symlink structure
# - Easier to add logic (sourcing .bashrc or per-env tweaks)
# - Better control and visibility over what gets installed & how
#
# Depends: bash, coreutils
# Usage: Just run & follow the prompts

set -euo pipefail

env=
install_mode=
overwrite_mode=

_prompt_yes_no() { read -rp "$1 [y/N]: "; [[ "$REPLY" =~ ^[yY]$ ]]; }

_info()  { printf '\e[1;32m[INFO]\e[m %s\n' "$*"; }

set_environment() {
    read -rp 'Choose env [niri/hyprland]: '
    env="env/${REPLY,,}"

    [[ ${env#env/} =~ ^niri$|^hyprland$ ]] || {
        printf 'Unknown env: %s\n' "$env" >&2; exit 1
    }

    _info "Environment set to: ${env#env/}"
}

should_overwrite() {
    local dst="$1"

    case $overwrite_mode in
        ask) read -rp "Overwrite $dst? [y/N]: "; [[ ${REPLY,,} == y ]];;
        yes) return;;
        no) return 1;;
    esac

    _info "Install mode: $install_mode, Overwrite: $overwrite_mode"
}

select_install_mode() {
    read -rp 'Install files as [l]ink or [c]opy? '
    case ${REPLY,,} in
        l) install_mode='link';;
        c) install_mode='copy';;
        *) printf 'Invalid choice. Aborting..\n' >&2; exit 1;;
    esac

    read -rp "Overwrite existing files? [a]sk/[y]es/[n]o: "
    case ${REPLY,,} in
        a) overwrite_mode="ask";;
        y) overwrite_mode="yes";;
        n) overwrite_mode="no";;
        *) printf 'Invalid choice. Aborting..\n' >&2; exit 1;;
    esac
}

install_file() {
    local src="$1" dst="$2" backup

    # make sure src is absolute
    [[ $src != /* ]] && src="$PWD/$src"

    # skip if symlink exists or copy destination is newer
    [[ $install_mode == link && -h $dst ]] ||
        [[ $install_mode == copy && -e $dst && $dst -nt $src ]] && return

    # file or symlink exists
    [[ -e $dst || -h $dst ]] && {
        should_overwrite "$dst" || {
            printf 'Skipped: %s\n' "$dst"
            return
        }

        backup="${dst}.bak.$(date +%Y%m%d-%H%M%S)"
        mv "$dst" "$backup"
        printf 'Backup: %s → %s\n' "$dst" "$backup"
    }

    case "$install_mode" in
        copy) cp -r "$src" "$dst"; printf 'Copied: %s → %s\n' "$src" "$dst";;
        link) ln -sf "$src" "$dst"; printf 'Linked: %s → %s\n' "$dst" "$src";;
    esac
}

install_dotfiles() {
    local dot

    _info "Installing dotfiles..."

    mkdir -p "$HOME/.config"
    for dot in home/.* config/* "$env/config/"*; do
        case $dot in
            home/*) install_file "$dot" "$HOME/${dot#home/}";;
            *) install_file "$dot" "$HOME/.${dot#"$env"/}";;
        esac
    done
}

install_scripts() {
    local script
    
    _info "Installing scripts..."

    mkdir -p "$HOME/.local/bin"
    for script in "$env/bin/"*; do
        install_file "$script" "$HOME/.local/${script#"$env"/}"
    done
}

install_packages() {
    local pkg_file="$env/packages.txt"

    [[ -f $pkg_file ]] || return

    _info "Installing packages from $pkg_file"

    if command -v pacman &>/dev/null; then
        # shellcheck disable=SC2046
        sudo pacman -Syu --needed $(<"$pkg_file")
    else
        printf 'No supported package manager found.\n' >&2
    fi
}

set_environment
select_install_mode

install_dotfiles
install_scripts

printf 'Dotfiles installed for "%s" using "%s" mode\n' "$env" "$install_mode"

install_packages

_prompt_yes_no 'Run system bootstrap script?' && bash bootstrap.sh
