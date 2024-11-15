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


# Takes two arguments
# 1: The file to update
# 2: The original line
# 3: The new line (optional, if just adding)
function updateFile(){
  local file="${1}"
  local line="${2}"
  local newLine=${3:-""}

  if [ ! -f "${file}" ]; then
    touch "${file}"
  fi

  if grep --fixed-strings --quiet "${line}" "${file}"; then
    if [[ "${newLine}" != "" ]]; then
      sed -i "s/^${line}.*/${newLine}/" "${file}"
    else
      printf "${file} already contains \n${line}\n. Doing nothing"
    fi
  else
    local temp="$(mktemp --directory)/file"
    echo "${line}" | cat - "${file}" > "${temp}"
    mv "${temp}" "${file}"
  fi
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

	if [ ! -d ${path} ]; then
		step "git" "cloning ${repo}"
		git clone "${repo}" ${path}
	fi
}

function link() {
  local original_file="$1"
  local linked_file="$2"

  if [ ! -f ${linked_file} ]; then
    step "link" "${linked_file}"
    ln -s "${original_file}" "${linked_file}"
  fi
}

function main() {

# Neovim needs a custom PPA. See https://github.com/neovim/neovim/wiki/Installing-Neovim
installPPA

declare -a packages=(
  "zsh"
  "neovim"
  "curl"
  "tmux"
  "git"
  "fzf"
  "ripgrep"
  "fonts-powerline"
  "python3-dev"
  "python3-pip"
)

for package in "${packages[@]}";
do
  aptGetInstall "${package}"
done

#declare -a pipPackages=(
#  "pynvim"
#  "pipenv"
#)
#
#for package in "${pipPackages[@]}"
#do
#  pip3 install --user "${package}"
#done

step "update shell" 'changing default shell to zsh'
chsh -s $(which zsh)

if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  step "curl" "downloading and installing oh my zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

step "update file" 'override agnoster theme'
rm /home/sara/.oh-my-zsh/themes/agnoster.zsh-theme
link "${PWD}/agnoster.zsh-theme" "${HOME}/.oh-my-zsh/themes/agnoster.zsh-theme"

link "${PWD}/gitconfig" "${HOME}/.gitconfig"
link "${PWD}/zshrc" "${HOME}/.zshrc"
link "${PWD}/aliases.zsh" "${HOME}/.oh-my-zsh/custom/aliases.zsh"
link "${PWD}/tmux.conf" "${HOME}/.tmux.conf"
link "${PWD}/coc.vim" "${HOME}/.config/nvim/coc.vim"

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
link ${PWD}/init.vim "${HOME}/.config/nvim/init.vim"

if [ ! -d  "${HOME}/workspace" ]; then
  step "mkdir" "making workspace"
  mkdir "${HOME}/workspace"
fi

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
