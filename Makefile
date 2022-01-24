# Makefile to install dependencies and setup dotfiles

DOTFILES ?= ${HOME}/.dotfiles

installdot = for i in $$(ls ${1}/); do ln -sf ${DOTFILES}/${1}/$${i} ${HOME}/.$${i}; done

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' Makefile

install-apt: ## Install all distro packages on APT distros (needs root)
	apt-get install -y \
	 zsh fzf tmux htop iotop suckless-tools \
	 emacs-nox vim-nox git make

setup: ## Setup dotfiles for the current user
	$(call installdot,shell)
	$(call installdot,git)
	$(call installdot,vim)
	$(call installdot,emacs)
	$(call installdot,misc)

install-zsh: ZSH := ${DOTFILES}/oh-my-zsh
install-zsh: ## Install oh-my-zsh
	git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh ${ZSH}

install-emacs: ## Install emacs packages
	for i in $$(awk -v RS=' ' '{print $0}' install/emacs); do \
		bash utils/emacs-pkg-install.sh $${i}; \
	done

install-vscode: ## Install vscode extensions
	for EXT in $$(cat install/vscode); do code --install-extension $$EXT; done

