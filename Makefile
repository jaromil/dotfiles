# Makefile to install dependencies and setup dotfiles

DOTFILES ?= ${HOME}/.dotfiles

installdot = for i in $$(ls ${1}/); do \
	if [ -r ${HOME}/.$${i} ] && ! [ -L ${HOME}/.$${i} ]; then \
		cp -r ${HOME}/.$${i} ${HOME}/.$${i}.bck; \
		echo >&2 "Saved backup of ~/.$$i in ~/.$$i.bck"; \
	 fi; \
	 ln -sf ${DOTFILES}/${1}/$${i} ${HOME}/.$${i}; done

# retrieve calling user, if not sudo then assumes /home/user/.dotfiles
SUDO_USER ?= $(shell echo $(dir $(shell pwd)) | cut -d/ -f3 )

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' Makefile

setup: ## Setup dotfiles for the current user
	$(info Installing into ~/.dotfiles)
	@$(call installdot,shell)
	@$(call installdot,git)
	@$(call installdot,vim)
	@$(call installdot,misc)
	@ln -sf ${DOTFILES}/emacs/emacs ${HOME}/.emacs
	@touch ${HOME}/.zsh_local
