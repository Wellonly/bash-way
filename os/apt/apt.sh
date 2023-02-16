#!/bin/bash

function apt-key-add {
  local usage='..usage: apt-key-add <key-url>; : curl <key-url> | sudo apt-key add -'
  local url=${1:?$usage}
  curl "$url" | sudo apt-key add -
}

function apt-key-add-google-pubkey {
  local usage="..usage: $FUNCNAME [url=https://dl-ssl.google.com/linux/linux_signing_key.pub]; : wget <key-url> | sudo apt-key add -"
  local url=${1:-https://dl-ssl.google.com/linux/linux_signing_key.pub}
  wget -O - "$url" | sudo apt-key add -
}

function apt-key-add-yarn-pubkey {
  local usage="..usage: $FUNCNAME [url=https://dl.yarnpkg.com/debian/pubkey.gpg]; : wget <key-url> | sudo apt-key add -"
  local url=${1:-https://dl.yarnpkg.com/debian/pubkey.gpg}
  wget -O - "$url" | sudo apt-key add -
}

function apt-add-repository {
  local usage='..usage: apt-add-repository <add-apt-repository params>; if not found use: apt install software-properties-common'
  sudo add-apt-repository "$@"
}

function apt-update-allow-releaseinfo-change {
  sudo apt-get update --allow-releaseinfo-change $@
}

function apt-update-allow-unauthenticated {
  sudo apt-get update --allow-unauthenticated $@
}

function apt-cache-policy {
  local usage='..usage: apt-cache-policy [pack-pattern]; : search apt packets from local cache and show its info'
  apt-cache policy $@
}

function apt-cache-show {
  local usage='..usage: apt-cache-show [pack-pattern]; : search apt packets from local cache and show its info'
  apt-cache show $@
}

function apt-show {
  local usage='..usage: apt-show <pack-pattern>; : search apt packets and show its info'
  apt show $@
}

function apt-search {
  local usage='..usage: apt-search <pack-pattern>; : search apt packets and show its info'
  apt show $@
}

function apt-add-repository-backports {
  local usage='..usage: apt-add-repository-backports; : add backports source to apt; then use: apt-install-from-backports <package>'
  local codename=$(. /etc/*-release && echo "$VERSION_CODENAME")
  [ "$codename" ] || { echo '..$VERSION_CODENAME not found'; return 1; }
  echo "deb http://deb.debian.org/debian $codename-backports main" | sudo tee /etc/apt/sources.list.d/$codename-backports.list || return
}

function apt-install-from-backports {
  local usage='..usage: apt-install-from-backports <package>; : apt-install-from-backports a package'
  local pack=${1:?$usage}
  local codename=$(. /etc/*-release && echo "$VERSION_CODENAME")
  [ "$codename" ] || { echo '..$VERSION_CODENAME not found'; return 1; }
  [ -f "/etc/apt/sources.list.d/$codename-backports.list" ] || {
    apt-add-repository-backports && sudo apt update || return
  }
  apt install -t $codename-backports $pack
}

function apt-listfiles {
  local -r usage="..usage: $FUNCNAME <installed-pack> [dpkg-options]; : list files for the installed package"
  dpkg --listfiles $@ || echo $usage
}

