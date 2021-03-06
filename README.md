# Jaromil's dotfiles

Support both Zsh (and optionally oh-my-zsh) and Bash.

Quick Install:

```
curl -L https://jaromil.dyne.org/dotfiles.sh | sh
```

Will install this into `~/.dotfiles`

Type `make -C ~/.dotfiles` for a list of options.

Do `make setup -C ~/.dotfiles` to activate, beware it will overwrite your
dotfiles:
- ~/.zshrc
- ~/.bash_profile
- ~/.inputrc
. ~/.emacs
. ~/.vimrc
. ~/.editorconfig

To pimp your Zsh type `make install-zsh -C ~/.dotfiles` this will install
oh-my-zsh with a nice prompt and a bunch of useful extensions and completion
packages.

## Usage

```
Usage:
  make <target>
  help             Display this help.
  install-apt      Install all distro packages on APT distros (needs root)
  setup            Setup dotfiles for the current user
  install-zsh      Install oh-my-zsh
  install-emacs    Install emacs packages
  install-vscode   Install vscode (needs root)
  install-vscode-ext  Install vscode extensions
```

## Layout
```
.
├── bin
│   ├── adduser-remote
│   ├── lnxrouter
│   └── mladmin
├── dotfiles.sh
├── emacs
│   ├── emacs
│   └── nyan-mode
├── git
│   ├── gitconfig
│   └── gitignore
├── install
│   ├── apt
│   ├── devops
│   ├── devtools
│   ├── emacs
│   ├── neovim
│   └── vscode
├── loader.sh
├── Makefile
├── misc
│   └── editorconfig
├── README.md
├── shell
│   ├── bash_profile
│   ├── inputrc
│   └── zshrc
├── system
│   ├── alias
│   ├── dir_colors
│   ├── env
│   ├── function
│   ├── function_fs
│   ├── function_network
│   ├── function_text
│   ├── grep
│   ├── path
│   └── prompt
├── utils
│   ├── emacs-pkg-install.el
│   └── emacs-pkg-install.sh
├── vim
│   └── vimrc
└── zsh
    ├── plugins
    └── themes
```