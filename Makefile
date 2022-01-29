# Makefile to install dependencies and setup dotfiles

DOTFILES ?= ${HOME}/.dotfiles

installdot = for i in $$(ls ${1}/); do ln -sf ${DOTFILES}/${1}/$${i} ${HOME}/.$${i}; done

# retrieve calling user, if not sudo then assumes /home/user/.dotfiles
SUDO_USER ?= $(shell echo $(dir $(shell pwd)) | cut -d/ -f3 )

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' Makefile

install-apt: ## Install base distro packages on APT distros (needs root)
	sh install/apt ${SUDO_USER}

install-devops: DISTRO ?= chimaera
install-devops: ## Install devops tools: docker, terraform (needs root)
	sh install/devops ${DISTRO}

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

install-vscode: ## Install vscode (needs root)
	curl -sSL https://packages.microsoft.com/keys/microsoft.asc \
	 | apt-key add -
	echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
	apt update -y && apt install code

install-vscode-ext: ## Install vscode extensions
	for EXT in $$(cat install/vscode); do code --install-extension $$EXT; done
