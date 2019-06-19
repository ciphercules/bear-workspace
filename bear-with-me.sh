#!/bin/bash -eu

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

# See https://www.turek.dev/post/fix-wsl-file-permissions/
function fixWslPermissions() {
	if [ ! -f "${HOME}/.profile" ]; then
		touch "${HOME}/.profile"
	fi

	if ! grep --fixed-strings --quiet "umask 0022" "${HOME}/.profile" ; then
		cat >> "${HOME}/.profile" <<-EOF 
		# Note: Bash on Windows does not currently apply umask properly.
		if [ "\$(umask)" = "0000" ]; then
			  umask 0022
		fi
		EOF
	fi

	if [ ! -f "/etc/wsl.conf" ]; then
		touch "/etc/wsl.conf"
	fi

	if ! grep --fixed-strings --quiet "[autoremove]" "${HOME}/.profile" ; then
		step 'create' 'add wsl.conf file with permissions fix'
		sudo bash -c "cat > /etc/wsl.conf <<-EOF
		[autoremove]
		enabled = true
		options = \"metadata,umask=22,fmask=11\"
		EOF
		"
	fi
}

function main() {
if [ -z $(which zsh) ]; then
	step apt-get "installing zsh"
	sudo apt-get update && sudo apt-get install zsh -y
fi

fixWslPermissions

step "update file" 'adding zsh to ~/.bashrc'
updateFile "${HOME}/.bashrc" 'bash -c zsh'

if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  step "curl" "downloading and installing oh my zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

step "copy" "gitconfig"
cp "${PWD}/gitconfig" "${HOME}/.gitconfig"

step "copy" "zshrc"
cp "${PWD}/zshrc" "${HOME}/.zshrc"

step "copy" "custom aliases"
cp "${PWD}/aliases.zsh" "${HOME}/.oh-my-zsh/custom/aliases.zsh"

local zsh_syntax_highlighting_path="${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
if [ ! -d ${zsh_syntax_highlighting_path} ]; then
	step "zsh" "cloning syntax highliting repo"
	git clone "git@github.com:zsh-users/zsh-syntax-highlighting.git" ${zsh_syntax_highlighting_path}
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
