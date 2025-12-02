#!/bin/bash

source pkg_common.sh

# Cross-platform sed in-place editing function (ensure available when script runs standalone)
sed_inplace() {
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i "" "$@"
  else
    sed -i "$@"
  fi
}

if command -v systemd-detect-virt >/dev/null 2>&1 && [[ "$(systemd-detect-virt 2>/dev/null)" != "none" ]]; then
  echo "virtual machine, set tty autologin"
else
  echo "Is not a virtual machine, will not set tty autologin."
  exit 1
fi
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

# Append serial console auto-resize to user shell profile (idempotent)
install_resize
SHELL_PROFILE=~/.bashrc
sed_inplace '/# Serial console auto-resize start/,/# Serial console auto-resize end/d' "$SHELL_PROFILE"
cat <<'EOF' >> "$SHELL_PROFILE"
# Serial console auto-resize start
if command -v tty >/dev/null 2>&1; then
  _serial_tty=$(tty 2>/dev/null)
  case "$_serial_tty" in
    /dev/ttyS*|/dev/ttyUSB*|/dev/ttyAMA*|/dev/ttyACM*)
      if command -v resize >/dev/null 2>&1; then
        resize
      fi
      ;;
  esac
  unset _serial_tty
fi
# Serial console auto-resize end
EOF

# set autologin
if [[ -n $islxc ]]; then
  sed -i '/--autologin root/! s/ - \$/ --autologin root - \$/' \
  /lib/systemd/system/container-getty@.service
  echo /dev/lxc/$dev > /etc/rootshelltty
else
  cp /usr/lib/systemd/system/serial-getty@.service \
  /etc/systemd/system/serial-getty@$dev.service
  sed -i '/--autologin root/! s/ - \$/ --autologin root - \$/' \
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

if [[ -z "$islxc" ]]; then

  if [[ ! -f /etc/default/grub ]] || [[ ! -s /etc/default/grub ]]; then
    echo "Warning: /etc/default/grub is empty or not exist."
  fi
  cp /etc/default/grub /etc/default/grub.bak.$(date +%Y%m%d%H%M%S)

  console_grub="console=$dev,921600 earlyprintk=$dev,921600"
  
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
