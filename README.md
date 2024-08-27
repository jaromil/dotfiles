# Jaromil's dotfiles

This setup is based on the Bash shell and includes configurations for git, emacs, vim, direnv. In addition there is also a set of handy shell scripts and a level of integration with WSL host (Windows Subsystem for Linux).

Quick Install:

```
curl -L https://jaromil.dyne.org/dotfiles.sh | sh
```

Will install into `~/.dotfiles`

Go inside this directory and type `make` for a list of options.

Do `make setup` to activate, beware it will overwrite some dotfiles:
- ~/.gitconfig && ~/.gitignore
- ~/.bashrc && ~/.inputrc
- ~/.emacs && ~/.vimrc
- ~/.editorconfig
- ~/.signature
- ~/.direnvrc

## Cheat-sheet

[![image](https://github.com/user-attachments/assets/c142e937-99ec-4058-9b40-4f0ba4274495)](https://cheatography.com/jaromil/cheat-sheets/jaromil-s-dotfiles/#downloads)


## Install recipes

These scripts will auto-install commonly used setups on various distros, they need running are root (at your own risk!)

- `./install/apt`      Install base distro packages on APT distros
- `./install/devops`   Install devops tools: docker, terraform
- `./install/devtools`  Install development tools: make, gcc, lua-dev..
- `./install/firewall`  Install basic ufw firewall protection allowing only ssh
- `install-emacs`    Install emacs packages
- `install-latex`    Install latex packages
- `install-nodejs`   Install nodejs tools
- `install-winhost`  Copy WSL dotfiles to the Windows host user dir

## Shell scripts

These scripts are into the `.dotfiles/bin` and added to `$PATH` hence available from commandline:

- `tile-goldratio` :: minimal windowmanager tiling script using wmctl
- `rd-rm-results` :: rdfind helper to remove duplicate hits in results.txt
- `lnxrouter` :: shell script to activate NAT masq from current host
- `adduser-remote` :: generates script to quickly add a user and ssh key
- `mladmin` :: quickly opens the admin panel of a dyne.org mailinglist
- `hcloud-datacenters` :: list all hetzner datacenters for hcloud-cli
- `torrent-serve` :: serve files in current directory for LAN streaming
- `.f-install-readme` :: install direnv README.nfo in current dir
- `.f-install-nvm` :: install a NodeVM setup in current dir

## Emacs

The setup uses helm heavily (even swoop in place of find-file) supports golang and has support for spell-checker hunspell and english grammar-checker grammarly.

Keys are remapped for my confort as follows:

```elisp

(global-unset-key [(control x)(control z)])
(global-set-key (kbd "M-x") 'helm-M-x)
;; M-a in qwerty is soft on left hand and I use it also in tmux
(global-set-key (kbd "M-a") 'helm-M-x) ;; this overrides an ugly lowercase hotkey
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


## Code layout

At shell startup the loader.sh is sourced to load all scripts in `system/` and then the shell specific one in `shell/`.

The `install/` dir contains collections of package install scripts.

```
.
├── bin
│   ├── adduser-remote
│   ├── hcloud-datacenters
│   ├── lnxrouter
│   ├── mladmin
│   ├── prune-branches
│   ├── rd-rm-results
│   ├── shuriken -> adduser-remote
│   ├── tile-goldratio
│   └── torrent-serve
├── completions
│   ├── fzf
│   ├── git
│   ├── ssh
│   └── zfs
├── confs
│   └── always-on_logind.conf
├── dotfiles.sh
├── emacs
│   ├── doom-themes-base.el
│   ├── doom-themes.el
│   ├── emacs
│   ├── flycheck-grammarly.el
│   ├── go-mode.el
│   ├── grammarly.el
│   ├── helm-ag.el
│   ├── helm-flx.el
│   ├── helm-swoop.el
│   ├── mood-line.el
│   ├── rainbow-delimiters.el
│   ├── request-deferred.el
│   ├── request.el
│   ├── themes
│   ├── unfill.el
│   └── ws-butler.el
├── git
│   ├── gitconfig
│   └── gitignore
├── GNUmakefile
├── install
│   ├── apt
│   ├── cloudflared
│   ├── devops
│   ├── devtools
│   ├── emacs
│   ├── firewall
│   ├── freebsd-base
│   ├── keygen-ssh-root-and-user
│   ├── latex
│   ├── locale
│   ├── locate
│   ├── need-suid.sh
│   ├── need-username.sh
│   ├── neovim
│   ├── nodejs
│   ├── openbsd-base
│   ├── rust
│   ├── sudo
│   ├── systemd-rc-local
│   ├── vscode
│   ├── wezterm
│   ├── winhost
│   └── zfs
├── loader.sh
├── misc
│   ├── direnvrc
│   ├── editorconfig
│   ├── nord-tmux
│   ├── signature
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
│   ├── onedrive
│   ├── path
│   ├── prompt
│   └── startmenu
└── vim
    └── vimrc
```
