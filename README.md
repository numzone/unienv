# Workspace

A collection of shell scripts and configuration files for setting up a development environment on Linux and macOS.

## Features

- **Cross-platform support**: Works on Linux (Debian/Ubuntu, RHEL/CentOS) and macOS
- **Shell configuration**: Aliases, environment variables, and shell profile setup
- **Vim configuration**: Custom vimrc and plugins
- **Git configuration**: Useful git aliases and settings
- **System tools**: Installation scripts for common development tools
- **TTY autologin**: Setup serial console autologin for virtual machines

## Directory Structure

```
.
├── configs/           # Configuration files (.alias, .tmux.conf)
├── vim/               # Vim configuration files
│   ├── .vimrc         # Vim configuration
│   └── .vim/          # Vim plugins and colorschemes
├── install.sh         # Main installation script
├── pkg_common.sh      # Package installation utilities
└── tty_autologin.sh   # TTY autologin setup script
```

## Installation

### Quick Start

```bash
# Clone the repository
git clone https://github.com/numzone/worksapce.git
cd worksapce

# Install all configurations
./install.sh -a

# Or install specific components
./install.sh -c    # Copy config files only
./install.sh -v    # Install vim configuration
./install.sh -g    # Set git configuration
./install.sh -b    # Set bashrc/bash_profile
```

### Options

| Option | Long Option | Description |
|--------|-------------|-------------|
| `-a` | `--all` | Install all configurations |
| `-c` | `--copy` | Copy config files to home directory |
| `-v` | `--vim` | Install vim configuration |
| `-g` | `--gitconfig` | Set git configuration |
| `-b` | `--bashrc` | Set shell profile (bashrc on Linux, bash_profile on macOS) |
| `-t` | `--tty` | Set TTY autologin (Linux only) |
| `-s` | `--software` | Install development software |
| `-h` | `--help` | Show help information |

## Platform Support

### Linux
- Uses `~/.bashrc` for shell configuration
- Supports `yum` (RHEL/CentOS) and `apt` (Debian/Ubuntu) package managers
- TTY autologin available for virtual machines

### macOS
- Uses `~/.bash_profile` for shell configuration
- Supports Homebrew package manager
- Some system-specific tools may not be available

## Configuration Files

### .alias
Contains useful shell aliases:
- `ll`, `ls`, `grep` - Enhanced with colors
- `cls` - Clear terminal
- `fn` - Find files by name
- Custom PS1 prompt

### .tmux.conf
Tmux configuration with:
- Vi-style keybindings
- Mouse support
- Custom prefix key (Ctrl+Space)
- Pane navigation with vim-style keys

### .vimrc
Vim configuration with:
- Line numbers and syntax highlighting
- Search highlighting
- Custom colorscheme (desert)
- Useful key mappings

## License

This project is open source. See individual files for any specific licensing information.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
