# AGENTS.md

Guidance for AI coding agents working in this personal dotfiles repository.

## Repository purpose

This repo manages Jaromil's interactive shell environment, editor settings, helper commands, and machine bootstrap recipes. Changes here can affect login shells and home-directory configuration, so prefer small, reviewable edits and avoid running setup/install commands unless explicitly requested.

## Layout

- `GNUmakefile` — symlinks dotfiles into the parent home directory via `make setup`.
- `dotfiles.sh` — remote bootstrap script that clones/extracts this repo into `~/.dotfiles`.
- `loader.sh` — sourced by shell startup files; loads `system/` files in a specific order.
- `shell/` — shell entrypoints such as `bashrc`, `zshrc`, and `inputrc`.
- `system/` — shared aliases, functions, environment, path setup, prompt, completions/extensions, and platform integration.
- `bin/` — user-facing helper commands placed on `PATH` by `loader.sh`.
- `install/` — OS/package install recipes; many assume root or sudo and may change system state.
- `git/`, `vim/`, `emacs/`, `misc/`, `completions/`, `themes/`, `confs/` — app-specific config and supporting files.

## Safety rules

- Do **not** run `make`, `make setup`, or any `install/*` script unless the user explicitly asks. These can overwrite/symlink files in `$HOME` or install system packages.
- Do **not** run scripts requiring root/sudo unless explicitly requested.
- Preserve local/user-specific files and untracked artifacts. At the time this file was created, the working tree already had unrelated local changes; avoid touching files outside the requested scope.
- Never add secrets, private keys, tokens, host-specific credentials, or private environment values to this repo. Use local override files such as `~/.rclocal`, `~/.bash_local`, `~/.bashrc.local`, and `~/.zsh_local` for private configuration.
- Be careful with paths: the `GNUmakefile` computes `HOME` as the parent of the repo directory, assuming the repo lives at `~/.dotfiles`.

## Shell conventions

- Keep portable scripts POSIX `sh` when they already use `#!/bin/sh`; use Bash-only syntax only in files that already declare Bash.
- Maintain the loader order in `loader.sh`: shared functions first, then path/env/aliases/platform/prompt/extensions/jumptable.
- Prefer idempotent shell changes. Dotfiles should tolerate missing optional tools and different operating systems.
- Guard optional commands with `command -v`, `test -r`, `test -x`, or similar checks.
- Quote variable expansions in new shell code unless there is a deliberate reason not to.
- Avoid noisy output in non-interactive shell paths. `loader.sh` returns early when `$PS1` is empty; keep that behavior intact.

## Documentation conventions

- If adding a new helper in `bin/`, document it in `README.md` when it is generally useful.
- If adding a new installer under `install/`, note whether it requires root/sudo and which OS family it targets.
- Keep README commands copy-pasteable and include warnings for destructive setup steps.

## Verification

For documentation-only changes, inspect the diff:

```sh
git diff -- README.md AGENTS.md
```

For shell changes, prefer at least syntax checks on modified files, for example:

```sh
sh -n path/to/script
bash -n path/to/bash-script
```

Run `shellcheck` when available, but do not rewrite large legacy scripts solely to satisfy lint warnings unless asked.
