#!/bin/bash

source pkg_common.sh

# set dev, defalut is ttyS0 in x86, ttyAMA0 in arm, tty1 in lxc
islxc=$(cat /proc/1/environ | tr '\0' '\n' | grep lxc)
if [[ -n "$islxc" ]]; then
  dev=tty1
else
  isx86=$(uname -a | grep x86)
  if [[ -n "$isx86" ]]; then
    dev=ttyS0
  else
    dev=ttyAMA0
  fi
fi

# set autologin
if [[ -n $islxc ]]; then
  sed -i '/--autologin root/! s/ - \$TERM/ --autologin root - \$TERM/' \
  /lib/systemd/system/container-getty@.service
  echo /dev/lxc/$dev > /etc/rootshelltty
else
  cp /usr/lib/systemd/system/serial-getty@.service \
  /etc/systemd/system/serial-getty@$dev.service
  sed -i '/--autologin root/! s/ - \$TERM/ --autologin root - \$TERM/' \
  /etc/systemd/system/serial-getty@$dev.service
  systemctl enable serial-getty@$dev.service
  echo /dev/$dev > /etc/rootshelltty
fi
if [[ ! -f /etc/pam.d/login ]] || [[ ! -s /etc/pam.d/login ]]; then
  echo "Warning: /etc/pam.d/login is empty or not exist."
else
  cp /etc/pam.d/login /etc/pam.d/login.bak.$(date +%Y%m%d%H%M%S)
  auth='auth sufficient pam_listfile.so item=tty'
  auth+=' sense=allow file=\/etc\/rootshelltty onerr=fail apply=root'
  sed -i "/$auth/d" /etc/pam.d/login
  sed -i "1a $auth" /etc/pam.d/login
fi
# support resize command
install_resize

if [[ -z "$islxc" ]]; then

  if [[ ! -f /etc/default/grub ]] || [[ ! -s /etc/default/grub ]]; then
    echo "Warning: /etc/default/grub is empty or not exist."
  fi
  cp /etc/default/grub /etc/default/grub.bak.$(date +%Y%m%d%H%M%S)

  console_grub="console=$dev,115200 earlyprintk=$dev,115200"
  
  noexist=$(grep -c "console=$dev" /etc/default/grub)
  if [[ $noexist -eq 0 ]]; then
    sudo sed -i "s/GRUB_CMDLINE_LINUX=\"/&$console_grub /" /etc/default/grub
    echo "Console parameters added to /etc/default/grub: $console_grub"
    if command -v grub2-mkconfig >/dev/null 2>&1; then
      sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    elif command -v grub-mkconfig >/dev/null 2>&1; then
      sudo grub-mkconfig -o /boot/grub/grub.cfg
    elif command -v update-grub >/dev/null 2>&1; then
      sudo update-grub # update-grub is a wrapper for grub-mkconfig
    else
      echo "Error: No available GRUB configuration update command found."
      exit 1
    fi
  else
    echo "Console parameter console=$dev already exists. No need to add again."
  fi
fi
