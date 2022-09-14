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

install: setup install-apt ## Base setup and install of APT rules

install-apt: ## Install base distro packages on APT distros (needs root)
	sh install/apt ${SUDO_USER}

install-devops: ## Install devops tools: docker, terraform (needs root)
	sh install/devops ${DISTRO}

install-devtools: ## Install development tools: make, gcc, lua-dev.. (needs root)
	sh install/devtools ${DISTRO}

install-firewall: ## Install basic ufw firewall protection allowing only ssh
	sh install/firewall

install-zsh: ZSH := ${DOTFILES}/oh-my-zsh
install-zsh: ## Install oh-my-zsh
	@if [ $(shell id -u) = 0 ]; then echo "make install-zsh is not meant to be run as root"; \
		else git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh ${ZSH}; fi

install-emacs: ## Install emacs packages
	sh install/emacs

install-neovim: # Install neovim and plugins
	sh install/neovim
	if [ -d ${HOME}/.config/nvim ]; then mv ${HOME}/.config/nvim ${HOME}/.config/nvim.bck; fi
	ln -s ${DOTFILES}/vim/nvim ${HOME}/.config/

install-vscode: # Install vscode (needs root)
	curl -sSL https://packages.microsoft.com/keys/microsoft.asc \
	 | apt-key add -
	echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
	apt update -y && apt install code

install-vscode-ext: # Install vscode extensions
	for EXT in $$(cat install/vscode); do code --install-extension $$EXT; done

install-latex: ## Install latex tools
	sh install/latex

install-nodejs: ## Install nodejs tools
	sh install/nodejs
