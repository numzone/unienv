#!/bin/bash

source pkg_common.sh

usage() {
  cat <<- EOF
USAGE: install.sh [OPTIONS]

Options:
  -a, --all
      install all except tty and software
  -c, --copy
      copy config file
  -v, --vim
      copy vim config
  -g, --gitconfig
      set git config
  -b, --bashrc
      set bashrc
  -t, --tty
      set tty autologin
  -s, --software
      install software
  -h, --help
      show help info

EOF
  exit
}

if [[ -z "$1" ]]; then
  usage
fi

short_options=hacvgbts
long_options=help,all,copy,vim,gitconfig,bashrc,tty,software
options=$(getopt -a -o $short_options -l $long_options -- "$@")
eval set -- "$options"
while true
do
  case "$1" in
    -h | --help)        usage ;;
    -a | --all)         all=y; shift ;;
    -c | --copy)        copy=y; shift ;;
    -v | --vim)         vim=y; shift ;;
    -g | --gitconfig)   gitconfig=y; shift ;;
    -b | --bashrc)      bashrc=y; shift ;;
    -t | --tty)         tty=y; shift ;;
    -s | --software)    software=y; shift ;;
    --) shift; break ;;
    *) echo "Unexpected option: $1"; exit ;;
  esac
done

# copy file
cd $(dirname $0)

# Cross-platform sed in-place editing function
sed_inplace() {
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i "" "$@"
  else
    sed -i "$@"
  fi
}
if [[ -n "$all" ]] || [[ -n "$copy" ]]; then
  for file in $(ls -a configs)
  do
    if [ -f configs/$file ]; then
      /bin/cp -f ./configs/$file ~/
    fi
  done
fi

if [[ -n "$all" ]] || [[ -n "$vim" ]]; then
  install_vim
  /bin/cp -rf vim/.vimrc ~
  /bin/cp -rf vim/.vim ~
fi

# set gitconfig
if [[ -n "$all" ]] || [[ -n "$gitconfig" ]]; then
  install_git
  git config --global pull.rebase true
  git config --global user.name "numzone"
  git config --global user.email "numzone@outlook.com"
  git config --global core.editor vim
  git config --global color.ui true
  git config --global http.sslVerify false
  git config --global alias.co checkout
  git config --global alias.br branch
  git config --global alias.ci commit
  git config --global alias.rs restore
  git config --global alias.rss "restore --staged"
  git config --global alias.cim "commit -m"
  git config --global alias.cis "commit -s"
  git config --global alias.cism "commit -s -m"
  git config --global alias.cia "commit --amend"
  git config --global alias.st status
  git config --global alias.po "push origin"
  git config --global alias.pof "push origin -f"
  git config --global alias.fp format-patch
  git config --global alias.cp cherry-pick
  git config --global alias.lo "log --online"
  git config --global alias.unstage 'reset HEAD --'
  git config --global alias.last 'log -1 HEAD'
fi

# set .bashrc or .bash_profile (macOS)
if [[ -n "$all" ]] || [[ -n "$bashrc" ]]; then
  /bin/cp -f ./configs/.alias ~/
  
  # Detect OS type and set appropriate shell profile
  if [[ "$(uname)" == "Darwin" ]]; then
    # macOS uses .bash_profile for login shells
    SHELL_PROFILE=~/.bash_profile
  else
    # Linux uses .bashrc
    SHELL_PROFILE=~/.bashrc
  fi
  
  # Create the file if it doesn't exist
  touch "$SHELL_PROFILE"

  sed_inplace '/LOCALVERSION/d' "$SHELL_PROFILE"
  echo "export LOCALVERSION=" >> "$SHELL_PROFILE"
  sed_inplace '/TERM=/d' "$SHELL_PROFILE"
  echo "export TERM=xterm" >> "$SHELL_PROFILE"
  sed_inplace '/TMOUT=/d' "$SHELL_PROFILE"
  echo "export TMOUT=0" >> "$SHELL_PROFILE"
  sed_inplace '/HISTSIZE=/d' "$SHELL_PROFILE"
  echo "export HISTSIZE=1000" >> "$SHELL_PROFILE"
  sed_inplace '/HISTFILESIZE=/d' "$SHELL_PROFILE"
  echo "export HISTFILESIZE=50000" >> "$SHELL_PROFILE"
  sed_inplace '/\.alias/d' "$SHELL_PROFILE"
  echo "source ~/.alias" >> "$SHELL_PROFILE"
fi

# set tty autologin
if [[ -n "$tty" ]]; then
  isvirt=$(systemd-detect-virt)
  if [[ "$isvirt" == "none" ]]; then
    echo "Is not a virtual machine, will not set tty autologin."
  else
    ./tty_autologin.sh
  fi
fi

# install software
if [[ -n "$software" ]]; then
  install_build
  install_systool
fi

