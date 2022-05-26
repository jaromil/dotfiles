# If not running interactively, don't do anything

[ -z "$PS1" ] && return

DOTFILES_DIR="$HOME/.dotfiles"

# Make utilities available

PATH="$DOTFILES_DIR/bin:$PATH"

# Source the dotfiles (order matters)

for DOTFILE in "$DOTFILES_DIR"/system/{function,function_*,path,env,alias,grep,prompt}; do
  [ -f "$DOTFILE" ] && . "$DOTFILE"
done

. ${DOTFILES_DIR}/shell/inputrc

# Set LSCOLORS

eval "$(dircolors -b "$DOTFILES_DIR"/system/dir_colors)"
