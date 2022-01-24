# Jaromil's dotfiles

Support both Zsh (and optionally oh-my-zsh) and Bash.

## Usage

```
make <target>
  help             Display this help.
  install-apt      Install all distro packages on APT distros (needs root)
  setup            Setup dotfiles for the current user
  install-zsh      Install oh-my-zsh
  install-emacs    Install emacs packages
  install-vscode   Install vscode extensions

```

## Layout
```
├── bin              (my own executable scripts)
│   ├── lnxrouter
│   └── mladmin
├── dotfiles.sh      (curl installer)
├── emacs
│   └── emacs
├── git
│   ├── gitconfig
│   └── gitignore
├── install          (packaged extensions)
│   ├── emacs
│   └── vscode
├── loader.sh        (common shell entrypoint)
├── Makefile
├── misc
│   └── editorconfig
├── oh-my-zsh        (optionally cloned here)
├── shell
│   ├── bash_profile
│   ├── inputrc
│   └── zshrc
├── system           (sourced by loader.sh)
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
│   └── emacs-pkg-install.sh
├── vim
│   └── vimrc
└── zsh
    ├── plugins
    └── themes

