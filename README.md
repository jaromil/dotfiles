# Jaromil's dotfiles

This setup support both Bash and Zsh (and optionally oh-my-zsh) setups.

My current daily driver is bash and is therefore more maintained.

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

## Usage

```
Usage:
  make <target>
  help             Display this help.
  setup            Setup dotfiles for the current user
  install          Base setup and install of APT rules
  install-apt      Install base distro packages on APT distros (needs root)
  install-devops   Install devops tools: docker, terraform (needs root)
  install-devtools  Install development tools: make, gcc, lua-dev.. (needs root)
  install-firewall  Install basic ufw firewall protection allowing only ssh
  install-zsh      Install oh-my-zsh
  install-emacs    Install emacs packages
  install-latex    Install latex tools
  install-nodejs   Install nodejs tools
```

## Emacs

Core packages to be installed from ELPA: `ivy helm`

Handy install script on APT systems: `make install-emacs`

The setup uses helm heavily (even swoop in place of find-file) supports golang and has support for spell-checker hunspell and english grammar-checker grammarly.

Keys are remapped for my confort as follows:

```elisp

(global-unset-key [(control x)(control z)])
(global-set-key (kbd "M-x") 'helm-M-x)
;; M-l in qwerty is soft on right hand and I use it also in tmux
(global-set-key (kbd "M-l") 'helm-M-x) ;; this overrides an ugly lowercase hotkey
(global-set-key (kbd "M-k") 'kill-buffer) ;; I'm not using it to delete lower block
(global-set-key (kbd "M-i") 'helm-imenu)
(global-set-key (kbd "M-,") 'helm-ag-project-root)
(global-set-key (kbd "M-.") 'helm-ag)
(global-set-key (kbd "C-x g") 'magit)
(global-set-key (kbd "C-x b") 'helm-buffers-list)
(global-set-key (kbd "M-o") 'helm-occur)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "C-s") 'helm-swoop)
(global-set-key (kbd "M-s M-s") 'helm-multi-swoop-all)

;; because I'm sloppy
(global-set-key (kbd "C-o") 'helm-find-files)
(global-set-key (kbd "C-b") 'helm-buffers-list)
(global-set-key (kbd "C-x C-b") 'helm-buffers-list)
(global-set-key (kbd "M-p") 'helm-buffers-list) ;; right ha

(global-unset-key (kbd "M-c")) ;; sloppy and not useful

```


## Layout

At shell startup the loader.sh is sourced to load all scripts in `system/` and then the shell specific one in `shell/`.

The `install/` dir contains a bunch of collections of packages that can be quickly installed for makefile depending on the purpose for which the shell is used.





```
.
├── bin
│   ├── adduser-remote
│   ├── hcloud-datacenters
│   ├── lnxrouter
│   ├── mladmin
│   ├── rd-rm-results
│   ├── readme
│   ├── shuriken
│   ├── tile-goldratio
│   └── torrent-serve
├── dotfiles.sh
├── emacs
│   ├── emacs
│   ├── helm-flx.el
│   ├── helm-swoop.el
│   ├── nyan-mode
│   └── themes
├── git
│   ├── gitconfig
│   └── gitignore
├── install
│   ├── apt
│   ├── devops
│   ├── devtools
│   ├── emacs
│   ├── firewall
│   ├── latex
│   ├── neovim
│   ├── nodejs
│   └── vscode
├── loader.sh
├── Makefile
├── misc
│   ├── direnvrc
│   ├── editorconfig
│   ├── nord-tmux
│   └── tmux.conf
├── README.md
├── shell
│   ├── bashrc
│   ├── inputrc
│   └── zshrc
├── system
│   ├── alias
│   ├── dir_colors
│   ├── env
│   ├── extensions
│   ├── function
│   ├── function_fs
│   ├── function_network
│   ├── function_text
│   ├── grep
│   ├── path
│   └── prompt
├── vim
│   ├── nvim
│   └── vimrc
└── zsh
    ├── plugins
    └── themes
```
