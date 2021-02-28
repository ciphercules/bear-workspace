#!/bin/bash -eu

set -o pipefail
# See https://www.turek.dev/post/fix-wsl-file-permissions/
function main() {
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
 		sudo bash -c "touch /etc/wsl.conf"
	fi

	if ! grep --fixed-strings --quiet "[automount]" "/etc/wsl.conf" ; then
		sudo bash -c "cat > /etc/wsl.conf <<-EOF
		[automount]
		enabled = true
		root = /
		options = \"metadata,umask=22,fmask=11\"
		EOF
		"
	fi
}

main "$@"
