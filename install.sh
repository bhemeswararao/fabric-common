#!/usr/bin/env bash
set -e

fcn=$1

bashProfile="$HOME/.bashrc"
remain_params=""
for ((i = 2; i <= ${#}; i++)); do
	j=${!i}
	remain_params="$remain_params $j"
done

golang() {
	if [[ "$1" == "remove" ]]; then
		if [[ $(uname) == "Darwin" ]]; then
			brew uninstall go || true
		else
			sudo apt-get -y remove golang-go
			sudo add-apt-repository --remove -y ppa:longsleep/golang-backports
		fi

	else
		if [[ $(uname) == "Darwin" ]]; then
			brew install go || true
		else
			sudo add-apt-repository -y ppa:longsleep/golang-backports
			sudo apt update
			sudo apt install -y golang-go
			GOPATH=$(go env GOPATH)
			if ! grep "$GOPATH/bin" $bashProfile; then
				echo "...To set GOPATH/bin and GOBIN"
				sudo sed -i "1 i\export PATH=\$PATH:$GOPATH/bin" $bashProfile
				sudo sed -i "1 i\export GOBIN=$GOPATH/bin" $bashProfile
			else
				echo "GOPATH/bin found in $bashProfile"
			fi
		fi
	fi
}
golang11() {
	sudo add-apt-repository ppa:gophers/archive
	sudo apt-get update
	sudo apt-get install golang-1.11-go
}
golang12() {
	sudo add-apt-repository -y ppa:longsleep/golang-backports
	sudo apt-get update
	sudo apt install golang-1.12
}
install_libtool() {
	if [[ $(uname) == "Darwin" ]]; then
		brew install libtool
	else
		sudo apt-get install -y libtool
	fi
}

golang_dep() {
	echo "install dep..."
	if [[ $(uname) == "Darwin" ]]; then
		brew install dep
	else
		if [[ -z "$GOBIN" ]]; then
			if [[ -z "$GOPATH" ]]; then
				echo install dep failed: GOPATH not found
				exit 1
			fi
			export GOBIN=$GOPATH/bin/
		fi
		mkdir -p $GOBIN
		curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
		if ! echo $PATH | grep "$GOBIN"; then
			export PATH=$PATH:$GOBIN # ephemeral
		fi
	fi
	dep version
}

java() {
	echo "[WARNING] This is to install OpenJDK, Oracle requires fee to use Java in production."
	sudo apt update
	sudo apt install -y default-jdk
}
softHSM() {
	if [[ $(uname) == "Darwin" ]]; then
		brew install softhsm
		#        A CA file has been bootstrapped using certificates from the SystemRoots
		#keychain. To add additional certificates (e.g. the certificates added in
		#the System keychain), place .pem files in
		#  /usr/local/etc/openssl/certs
		#
		#and run
		#  /usr/local/opt/openssl/bin/c_rehash
		#
		#openssl is keg-only, which means it was not symlinked into /usr/local,
		#because Apple has deprecated use of OpenSSL in favor of its own TLS and crypto libraries.
		#
		#If you need to have openssl first in your PATH run:
		#  echo 'export PATH="/usr/local/opt/openssl/bin:$PATH"' >> ~/.bash_profile
		#
		#For compilers to find openssl you may need to set:
		#  export LDFLAGS="-L/usr/local/opt/openssl/lib"
		#  export CPPFLAGS="-I/usr/local/opt/openssl/include"
	else
		sudo apt-get install -y softhsm2
	fi
}
fabricInstall() {
	curl -sSL http://bit.ly/2ysbOFE | bash -s -- 1.4.5 1.4.5 0.4.18 -s
}
sync() {
	CURRENT=$(cd $(dirname ${BASH_SOURCE}) && pwd)
	cd $CURRENT/nodejs
	npm install
	cd fabric-network
	npm install
	cd $CURRENT
}
if [[ -n "$fcn" ]]; then
	$fcn $remain_params
else
	# install home brew
	if [[ $(uname) == "Darwin" ]]; then
		if ! brew config > /dev/null; then
			/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		fi
	fi

	dockerInstall="curl --silent --show-error https://raw.githubusercontent.com/davidkhala/docker-manager/master/install.sh"
	$dockerInstall | bash -s installDocker
	$dockerInstall | bash -s installjq
	nodejsInstall="curl --silent --show-error https://raw.githubusercontent.com/davidkhala/node-utils/master/install.sh"
	$nodejsInstall | bash -s nodeGYPDependencies
	$nodejsInstall | bash -s nodeVersionManager
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

	nvm install 10
	nvm alias default 10
	nvm use 10 # work for current shell
	curl --silent --show-error https://raw.githubusercontent.com/davidkhala/node-utils/master/scripts/npm.sh | bash -s packageLock false
fi
