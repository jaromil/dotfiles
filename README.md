# Jaromil's dotfiles

Personal dotfiles and bootstrap scripts for a Unix-like working environment. The setup is centered on Bash/Zsh shells and includes configuration for Git, Vim, Emacs, tmux, direnv, fzf, WSL/Windows integration, and a collection of small command-line helpers.

> **Warning:** this repository is meant to be installed as `~/.dotfiles`. Running `make setup` creates symlinks in your home directory and may move existing dotfiles aside as `*.bck` backups.

## Quick install

```sh
curl -L https://jaromil.dyne.org/dotfiles.sh | sh
cd ~/.dotfiles
make setup
```

The bootstrap script installs this repository into `~/.dotfiles` using `git`, `curl`, or `wget`, depending on what is available.

## What `make setup` does

`make setup` symlinks files from this repository into the parent home directory. Existing non-symlink files are copied to `*.bck` before being replaced.

Managed files include:

- `~/.bashrc`, `~/.zshrc`, `~/.inputrc`
- `~/.gitconfig`, `~/.gitignore`
- `~/.vimrc`, `~/.emacs`
- `~/.editorconfig`, `~/.direnvrc`, `~/.signature`, `~/.tmux.conf`, and related files from `misc/`

It also creates `~/.zsh_local` and `~/.hushlogin` if missing.

## Repository layout

| Path | Purpose |
| --- | --- |
| `GNUmakefile` | Home-directory symlink setup. |
| `dotfiles.sh` | One-shot remote bootstrap installer. |
| `loader.sh` | Shared shell loader used by Bash and Zsh startup files. |
| `shell/` | Shell entrypoints: `bashrc`, `zshrc`, `inputrc`. |
| `system/` | Shared shell functions, aliases, environment, path setup, prompt, platform helpers, and completions/extensions. |
| `bin/` | User helper scripts added to `PATH`. |
| `install/` | Optional system/package installation recipes. Many require root. |
| `git/` | Global Git config and ignore rules. |
| `vim/` | Vim configuration. |
| `emacs/` | Emacs configuration and bundled Lisp packages/themes. |
| `misc/` | tmux, direnv, editorconfig, gdb, signature, and other miscellaneous dotfiles. |
| `completions/` | Shell completions for fzf, Git, SSH, ZFS, etc. |
| `themes/` | tmux/Nord theme support files. |
| `confs/` | System configuration snippets. |

## Shell startup model

`~/.bashrc` and `~/.zshrc` source `~/.dotfiles/loader.sh`. The loader:

1. exits early for non-interactive shells,
2. prepends `~/.dotfiles/bin` to `PATH`,
3. sources files in `system/` in this order:
   - `function`
   - `function_*`
   - `path`
   - `env`
   - `alias`
   - `windows`
   - `prompt`
   - `extensions`
   - `jumptable`
4. sources `shell/inputrc`,
5. sources `~/.rclocal` when present,
6. configures `dircolors` or BSD/Darwin `ls` behavior.

Use local override files for machine-specific or private customizations:

- `~/.rclocal` — loaded by `loader.sh`.
- `~/.bash_local` and `~/.bashrc.local` — loaded by `shell/bashrc`.
- `~/.zsh_local` — loaded by `shell/zshrc`.
- `~/.tmux_startup` — enables auto-starting tmux over SSH from Bash.
- `~/.motd` — displayed by Bash login startup when present.

Do not commit secrets or host-specific credentials; keep them in local override files.

## Install recipes

The `install/` directory contains optional setup scripts. These are intentionally separate from `make setup`. Many are designed for Debian/Devuan-like systems and several require root privileges.

Examples:

```sh
sudo ./install/apt       # base APT packages
sudo ./install/devtools  # compilers, build tools, editorconfig, act
sudo ./install/devops    # repository setup for Docker/HashiCorp/Kubernetes tools
sudo ./install/docker    # Docker-related setup
sudo ./install/firewall  # basic firewall setup
sudo ./install/nodejs    # nvm, NodeSource Node.js, Bun
sudo ./install/rust      # Rust toolchain setup
sudo ./install/pi.dev    # Pi coding-agent ecosystem tools and packages
```

Other recipes cover Emacs, LaTeX, Python, Neovim, VS Code, WezTerm, ZFS, FreeBSD/OpenBSD base setup, Windows/winget helpers, SSH key generation, locale, locate, and systemd rc-local support.

Read a script before running it. These scripts may install packages, add package repositories, change system configuration, or require elevated permissions.

## Helper scripts

Files under `bin/` are added to `PATH` by `loader.sh`. Notable helpers include:

- `adduser-remote` / `shuriken` — generate a remote user + SSH key setup script.
- `anon-pdf` — PDF anonymization helper.
- `clean-home-temp` and `prune-home` — home-directory cleanup helpers.
- `hcloud-datacenters` — list Hetzner datacenters for `hcloud` usage.
- `lnxrouter` — activate NAT masquerading from the current host.
- `mladmin` — open a Dyne.org Mailman administration page.
- `my-ip`, `proton-test`, `tor-test` — network/VPN/Tor IP checks.
- `prune-branches` — Git branch cleanup helper.
- `rd-rm-results` — `rdfind` duplicate-removal helper for `results.txt`.
- `signrelease` — release signing helper.
- `tile-goldratio` — minimal golden-ratio window tiling helper using `wmctrl`/similar tools.
- `torrent-serve` — serve files in the current directory for LAN streaming.
- `zcopy` and `zpaste` — clipboard-oriented helpers.
- `.f-install-readme`, `.f-install-nvm`, `.f-install-mise`, `.f-install-venv` — project-local setup helpers used from the shell.

## Git configuration

The repository installs a global Git config with:

- Vim as the default editor,
- colorized output,
- fast-forward-only merge behavior,
- rebase-oriented pull settings,
- convenient aliases such as `git st`, `git up`, `git br`, `git hist`, `git lg`, and `git storia`,
- `main` as the default branch name for new repositories.

Review `git/gitconfig` before using it on machines where global identity or workflow settings differ.

## Windows and WSL

The setup includes WSL-aware shell integration in `system/windows` and native Windows helper scripts under `install/`:

- `install/windows-user.bat`
- `install/windows-admin.bat`
- `install/windows-msvc-env.ps1`
- `install/winget`

For native Git for Windows usage:

```sh
winget install gnuwin32.make
winget install direnv.direnv
curl https://jaromil.dyne.org/dotfiles.sh | sh
cd .dotfiles
"C:\Program Files (x86)\GnuWin32\bin\make.exe" setup
```

Restart the Git shell after setup.

## Emacs notes

The Emacs setup uses Helm heavily, with support for Go, spell checking through Hunspell, and grammar checking through Grammarly-related packages. Some custom keybindings include:

```elisp
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "M-a") 'helm-M-x)
(global-set-key (kbd "M-k") 'kill-buffer)
(global-set-key (kbd "M-i") 'helm-imenu)
(global-set-key (kbd "M-,") 'helm-ag-project-root)
(global-set-key (kbd "M-.") 'helm-ag)
(global-set-key (kbd "C-x g") 'magit)
(global-set-key (kbd "C-x b") 'helm-buffers-list)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "C-s") 'helm-swoop)
```

See `emacs/emacs` for the full configuration.

## Cheat sheet

[![Jaromil's dotfiles cheat sheet](https://github.com/user-attachments/assets/c142e937-99ec-4058-9b40-4f0ba4274495)](https://cheatography.com/jaromil/cheat-sheets/jaromil-s-dotfiles/#downloads)

## Development notes

- Keep shell snippets portable unless a file already declares Bash.
- Guard optional integrations with checks such as `command -v`, `[ -r file ]`, or `[ -x dir ]`.
- Prefer idempotent install/setup behavior.
- Avoid committing generated caches, backups, secrets, or machine-local configuration.
- For agent-specific repository guidance, see `AGENTS.md`.
