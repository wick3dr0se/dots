#!/bin/bash

set -euo pipefail

# MAKE PARU INSTALL FROM CHAOTIC IF INSTALLED
# ADD MESSAGES

chaotic_aur_installed=0
paru_installed=0
blesh_installed=0

_info()  { printf '\e[1;32m[INFO]\e[m %s\n' "$*"; }

_has_cmd() { command -v "$1" 2>/dev/null; }
_prompt_yes_no() { read -rp "$1 [y/N]: "; [[ "$REPLY" =~ ^[yY]$ ]]; }

check_tools() {
    _info "Checking existing tools"

    grep -q '^\[chaotic-aur\]' /etc/pacman.conf && chaotic_aur_installed=1
    _has_cmd paru && paru_installed=1
    _has_cmd blesh || [[ -d ~/.local/share/blesh ]] && blesh_installed=1; :
}

install_chaotic_aur() {
    (( chaotic_aur_installed )) && return
    _info "Installing Chaotic AUR"

    local key='3056513887B78AEB' cdn='https://cdn-mirror.chaotic.cx/chaotic-aur'

    # https://aur.chaotic.cx/docs
    pacman-key --recv-key "$key" --keyserver keyserver.ubuntu.com
    pacman-key --lsign-key "$key"
    pacman --noconfirm -U "$cdn/chaotic-keyring.pkg.tar.zst"
    pacman --noconfirm -U "$cdn/chaotic-mirrorlist.pkg.tar.zst"

    cat <<EOF >>/etc/pacman.conf

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF

    _info "Chaotic AUR installed. Updating packages..."
    pacman -Syu
}


install_paru() {
    (( paru_installed )) && return

    if (( chaotic_aur_installed )); then
        _info "Installing paru from Chaotic AUR"
        sudo pacman -S --needed paru
    else
        _info "Building paru from AUR"
        # https://github.com/Morganamilo/paru#installation
        sudo pacman -S --needed base-devel git
        git clone https://aur.archlinux.org/paru /tmp/paru
        makepkg -siD /tmp/paru
    fi
}

# shellcheck disable=SC2046
install_packages() {
    _info "Installing base packages from setup_packages.txt"
    sudo pacman -Syu --needed $(< bootstrap_packages.txt)
}

install_blesh() {
    (( blesh_installed )) && return
    _info "Installing ble.sh"

    if (( chaotic_aur_installed )); then
        sudo pacman -S --needed blesh
    elif (( paru_installed )); then
        paru -S --needed blesh
    else
        _info "Building ble.sh manually"
        # https://github.com/akinomyoga/ble.sh#quick-instructions
        sudo pacman -S --needed make git
        git clone --recursive --depth 1 --shallow-submodules \
            https://github.com/akinomyoga/ble.sh "/tmp/blesh"
        make -C /tmp/blesh install PREFIX=~/.local
    fi
}

setup_autologin() {
    _info "Setting up TTY1 autologin for $USER"

    local conf='/etc/systemd/system/getty@tty1.service.d/autologin.conf'
    
    mkdir -p "${conf%/*}"
    cat <<EOF >"$conf"
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin $USER %I $TERM
EOF
}

setup_audio() {
    _info "Enabling PipeWire + WirePlumber"
    systemctl --user enable --now pipewire wireplumber
}

check_tools

_prompt_yes_no 'Install chaotic-aur (pre-built AUR binaries)?' && install_chaotic_aur
_prompt_yes_no 'Install paru (AUR helper)?' && install_paru
install_packages
_prompt_yes_no 'Install ble.sh (Bash suggestions & completions)?' && install_blesh

_prompt_yes_no 'Enable autologin on TTY1?' && setup_autologin
_prompt_yes_no 'Enable PipeWire + WirePlumber audio services?' && setup_audio

_info "Done bootstrapping!"