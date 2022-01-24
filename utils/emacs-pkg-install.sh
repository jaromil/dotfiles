#!/bin/bash
#
# I wrapped the code constructed in
#
# http://hacks-galore.org/aleix/blog/archives/2013/01/08/install-emacs-packages-from-command-line
#
# in a single bash script, so I would a single code snippet.
#

if [ $# -ne 1 ]
then
  echo "Usage: `basename $0` <package>"
  exit 1
fi

# Package to be installed
pkg_name=$1
echo
echo "## $pkg_name"
echo
emacs --batch --eval "(defconst pkg-to-install '${pkg_name})" -l $HOME/.dotfiles/utils/emacs-pkg-install.el

