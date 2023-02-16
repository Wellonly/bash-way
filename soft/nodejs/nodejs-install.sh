#/bin/bash

function nodejs-install-by-script {
  local usage="..usage: ${FUNCNAME[0]} <nodejs-major-version-only>; : install node from nodesource.com"
  local node_version=${1:?$usage}
  local node_ins_script="/tmp/nodejs-v$node_version-install.sh"
  curl -sL https://deb.nodesource.com/setup_$node_version.x >$node_ins_script || return
  read -p "..zv warning: check the script for security: $node_ins_script; and press y if everything is ok:" isok
  [ "$isok" == "y" ] && echo "..continue install..." || { echo "..install aborted by press: $isok" && return 1; }
  sudo sh "$node_ins_script" || return
  sudo apt-get install -y nodejs && echo "... nodejs v$node_version installed ok!"
  node -v
}

function nodejs-install-from--distributive {
  local usage="..usage: ${FUNCNAME[0]} <nodej-distributive-file.tar.gz> [DEST_FOLD=/usr/]; : install node from dist file"
  local DISTRIBUTE=${1:?$usage}
  local DEST_FOLD=${2:-/usr/}
  echo "..extract $DISTRIBUTE to $DEST_FOLD ..."
  sudo tar -f "$DISTRIBUTE" -C "$DEST_FOLD" --strip-components 1 --wildcards -x node*/bin node*/include node*/lib node*/share || return
  echo '..all done'
  node -v
}