#!/bin/bash

install_packages() {
    local rpmlist="$1"
    local deblist="$2"
    local brewlist="$3"
    local failed=""
    local succeed=""
    local failed_cnt=0
    local succeed_cnt=0

    if command -v yum &> /dev/null; then
        for pkg in $rpmlist; do
            if yum install -y "$pkg"; then
                succeed+=" $pkg"
                ((succeed_cnt++))
            else
                failed+=" $pkg"
                ((failed_cnt++))
            fi
        done
    fi

    if command -v apt &> /dev/null; then
        for pkg in $deblist; do
            if apt install -y "$pkg"; then
                succeed+=" $pkg"
                ((succeed_cnt++))
            else
                failed+=" $pkg"
                ((failed_cnt++))
            fi
        done
    fi

    # macOS Homebrew support
    if command -v brew &> /dev/null; then
        for pkg in $brewlist; do
            if brew install "$pkg"; then
                succeed+=" $pkg"
                ((succeed_cnt++))
            else
                failed+=" $pkg"
                ((failed_cnt++))
            fi
        done
    fi

    echo succeed $succeed_cnt:$succeed
    echo failed $failed_cnt:$failed
}

install_vim() {
    rpmlist="vim"
    deblist="vim vim-nox "
    brewlist="vim"

    install_packages "$rpmlist" "$deblist" "$brewlist"
}

install_resize() {
    rpmlist="xterm-resize" 
    deblist="xterm"
    brewlist=""  # Not needed on macOS

    install_packages "$rpmlist" "$deblist" "$brewlist"
}

install_build() {
    rpmlist="gcc gcc-c++ make autoconf automake libtool cmake build rpm-build 
    rpmdevtools bc bison flex openssl-devel ncurses-devel elfutils-devel dwarves"
    
    deblist="build-essential gcc make autoconf automake libtool cmake bc bison
    flex libssl-dev ncurses-dev libelf-dev dwarves"
    
    brewlist="gcc make autoconf automake libtool cmake bc bison flex openssl ncurses"

    install_packages "$rpmlist" "$deblist" "$brewlist"
}

install_systool() {
    rpmlist="sysstat pciutils lsscsi iotop net-tools tmux"
    deblist="sysstat pciutils lsscsi iotop net-tools tmux"
    brewlist="sysstat pciutils tmux"  # Some tools differ on macOS
    
    install_packages "$rpmlist" "$deblist" "$brewlist"
}

install_git() {
    pkglist="git tig"
    
    install_packages "$pkglist" "$pkglist" "$pkglist"
}

install_qemu() {
    rpmlist="qemu-guest-agent"
    deblist="qemu-guest-agent"
    brewlist="qemu"  # On macOS, just install qemu

    install_packages "$rpmlist" "$deblist" "$brewlist"
}


