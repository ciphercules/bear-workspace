#!/bin/bash -eu

set -o pipefail

default='39m'
blue='34m'
cyan='36m'
green='32m'

#Takes two arguments
# 1: Component
# 2: Message
function step() {
  local component="${1}"
  local message="${2}"

  echo -e "\e[${blue}${component}: \e[${cyan}${message}\n\e[${default}"
}


# Takes 1 argument
# 1: package to install
function aptGetInstall() {
	local package="${1}"
	if ! dpkg -s "${package}" &>/dev/null ; then
		step apt-get "installing ${package}"
		sudo apt-get install "${package}" -y
	fi
}

function installPPA() {
	aptGetInstall "software-properties-common"
	if ! grep --quiet "neovim-ppa" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
		step "add-apt-repository" "add neovim ppa"
		sudo add-apt-repository ppa:neovim-ppa/stable -y
		sudo apt-get update
	fi
}

function setNvimAsAlternatives() {
	step "update-alternatives" "setting neovim as alternatives"
	sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
	sudo update-alternatives --config vi --skip-auto
	sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
	sudo update-alternatives --config vim --skip-auto
	sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
	sudo update-alternatives --config editor --skip-auto
}

# Takes two arguments
# 1: Install Path
# 2: Git Repo
function gitClone() {
	local path="${1}"
	local repo="${2}"

	if [ ! -d "${path}" ]; then
		step "git" "cloning ${repo}"
		git clone "${repo}" "${path}"
	fi
}

function link() {
  local original_file="$1"
  local linked_file="$2"

  if [ ! -f "${linked_file}" ]; then
    step "link" "${linked_file}"
    ln -s "${original_file}" "${linked_file}"
  fi
}

function main() {

# Install curl first - needed for subsequent downloads
aptGetInstall "curl"

# Neovim needs a custom PPA. See https://github.com/neovim/neovim/wiki/Installing-Neovim
installPPA

# Install Node version 22 LTS (supported until April 2027)
# Needed by coc.vim
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -

declare -a packages=(
  "zsh"
  "neovim"
  "tmux"
  "fzf"
  "ripgrep"
  "nodejs"
  "libfuse2" # For AppImages.
  "fonts-powerline"
  "black" # Needed to install black (Python formatter).
  "xclip" # X11 clipboard integration for tmux copy/paste.
)

for package in "${packages[@]}";
do
  aptGetInstall "${package}"
done

step "update shell" 'changing default shell to zsh'
chsh -s "$(which zsh)"

if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  step "curl" "downloading and installing oh my zsh"
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

step "update file" 'override agnoster theme'
rm -f "${HOME}/.oh-my-zsh/themes/agnoster.zsh-theme"
link "${PWD}/agnoster.zsh-theme" "${HOME}/.oh-my-zsh/themes/agnoster.zsh-theme"

link "${PWD}/gitconfig" "${HOME}/.gitconfig"
link "${PWD}/zshrc" "${HOME}/.zshrc"
link "${PWD}/aliases.zsh" "${HOME}/.oh-my-zsh/custom/aliases.zsh"
link "${PWD}/tmux.conf" "${HOME}/.tmux.conf"
link "${PWD}/.env" "${HOME}/.env"

local zsh_syntax_highlighting_path="${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
gitClone "${zsh_syntax_highlighting_path}" "https://github.com/zsh-users/zsh-syntax-highlighting.git"

step "customize" "nvim"
setNvimAsAlternatives

curl -fLo "${HOME}/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if [ ! -d "${HOME}/.config/nvim" ]; then
  step "mkdir" "nvim config directory"
  mkdir -p "${HOME}/.config/nvim"
fi
link "${PWD}/init.vim" "${HOME}/.config/nvim/init.vim"
link "${PWD}/coc.vim" "${HOME}/.config/nvim/coc.vim"
link "${PWD}/coc-settings.json" "${HOME}/.config/nvim/coc-settings.json"

if [ ! -d  "${HOME}/workspace" ]; then
  step "mkdir" "making workspace"
  mkdir "${HOME}/workspace"
fi

step "dconf" "load terminal profile"
dconf load /org/gnome/terminal/ < one-half-dark-profile.txt

echo -e "\e[${green}\n"
cat <<-'EOF'
$$\     $$\                         $$$$$$$\
\$$\   $$  |                        $$  __$$\
 \$$\ $$  /$$$$$$\  $$\   $$\       $$ |  $$ | $$$$$$\   $$$$$$\  $$$$$$$\
  \$$$$  /$$  __$$\ $$ |  $$ |      $$$$$$$\ |$$  __$$\ $$  __$$\ $$  __$$\
   \$$  / $$ /  $$ |$$ |  $$ |      $$  __$$\ $$$$$$$$ |$$$$$$$$ |$$ |  $$ |
    $$ |  $$ |  $$ |$$ |  $$ |      $$ |  $$ |$$   ____|$$   ____|$$ |  $$ |
    $$ |  \$$$$$$  |\$$$$$$  |      $$$$$$$  |\$$$$$$$\ \$$$$$$$\ $$ |  $$ |
    \__|   \______/  \______/       \_______/  \_______| \_______|\__|  \__|



$$$$$$$\  $$$$$$$$\  $$$$$$\  $$$$$$$\  $$$$$$$$\ $$$$$$$\
$$  __$$\ $$  _____|$$  __$$\ $$  __$$\ $$  _____|$$  __$$\
$$ |  $$ |$$ |      $$ /  $$ |$$ |  $$ |$$ |      $$ |  $$ |
$$$$$$$\ |$$$$$\    $$$$$$$$ |$$$$$$$  |$$$$$\    $$ |  $$ |
$$  __$$\ $$  __|   $$  __$$ |$$  __$$< $$  __|   $$ |  $$ |
$$ |  $$ |$$ |      $$ |  $$ |$$ |  $$ |$$ |      $$ |  $$ |
$$$$$$$  |$$$$$$$$\ $$ |  $$ |$$ |  $$ |$$$$$$$$\ $$$$$$$  |
\_______/ \________|\__|  \__|\__|  \__|\________|\_______/

EOF
echo -e "\e[${default}"
}

main "$@"
