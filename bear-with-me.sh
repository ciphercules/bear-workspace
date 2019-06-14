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
      echo "${file} already contains \n${line}\n. Doing nothing"
    fi
  else
    local temp="$(mktemp --directory)/file"
    echo "${line}" | cat - "${file}" > "${temp}"
    mv "${temp}" "${file}"
  fi
}

function main() {
step apt-get "installing zsh"
sudo apt-get update && sudo apt-get install zsh -y

step "update file" 'adding zsh to ~/.bashrc'
updateFile "${HOME}/.bashrc" 'bash -c zsh'

if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  step "curl" "downloading and installing oh my zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

step "update file" "changing oh my zsh theme to agnoster"
updateFile "${HOME}/.zshrc" 'ZSH_THEME' 'ZSH_THEME\=\"agnoster\"'

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
