#!/bin/bash

function chrome-install {
  local defprefix='/media/sf_vms/ins/chrome'
  local defplatform='amd64'
  local insprefix=${1:-$defprefix}
  local platform=${2:-$defplatform}
  local -r usage="..usage: $FUNCNAME [insprefix=$defprefix platform=$defplatform]; : download & install current chrome browser by dpkg"
  [[ $@ =~ '--help' ]] && echo "$usage" && return 4
  local distLoadDate="$(date +%Y%m%d)"
  local distfile="$insprefix/google-chrome-stable_current_$platform-$distLoadDate.deb"
  local cfgfile="$insprefix/google-chrome-config.tar"
  local cfgdir='/home/user/.config/google-chrome'
	sudo apt install libappindicator3-1 || return

  local skipDownload
  [ -s "$distfile" ] && echo "..$distfile already present, skip download" && skipDownload="skip"
  [ "$skipDownload" ] || {
    echo "..download distributive: $distfile"
    mkdir -p "$insprefix" && wget "https://dl.google.com/linux/direct/google-chrome-stable_current_$platform.deb" -O "$distfile" --directory-prefix="$insprefix" || return
  }

  [ -d "$cfgdir" ] && [ -f "$cfgfile" ] && {
    local configBak="$cfgdir-before-$(date +%Y%m%d-%H%M%S)"
    mv -f "$cfgdir" "$configBak" && echo "..fold backup ok: $cfgdir to $configBak" || return
  }

  sudo dpkg -i "$distfile" || return
  [ -f "$cfgfile" ] && tar -xf "$cfgfile" -C / && echo "..config restored ok: $cfgfile" || echo "..config NOT restored from: $cfgfile"
  echo "..$FUNCNAME ok"
}

function firefox-install {
  local defprefix='/media/sf_vms/ins/firefox'
  local defos='linux64'
  local deflang='en-US'
  local targetDir='/opt/firefox'
  local configDir='/home/user/.mozilla'
  local insprefix=${1:-$defprefix}
  local cfgfile="$insprefix/mozilla-config.tar"
  local targetos=${2:-$defos}
  local lang=${3:-$deflang}
  local -r usage="..usage: $FUNCNAME [insPrefix=$defprefix targetOs=$defos lang=$deflang]; : download & install current firefox browser by tar"
  [[ $@ =~ '--help' ]] && echo "$usage" && return 4
  local distLoadDate="$(date +%Y%m%d)"
  local distfile="$insprefix/firefox-latest-$targetos-$lang-$distLoadDate.tar.bz2"

  local skipDownload
  [ -s "$distfile" ] && echo "..$distfile already present, skip download" && skipDownload="skip"
  [ "$skipDownload" ] || {
    echo "..download distributive: $distfile"
    mkdir -p "$insprefix" && wget "https://download.mozilla.org/?product=firefox-latest-ssl&os=$targetos&lang=$lang" -O "$distfile" --directory-prefix="$insprefix" --no-check-certificate || return
  }

  [ -d "$targetDir" ] && {
    local targetBak="$targetDir-before-$(date +%Y%m%d-%H%M%S)"
    mv -f "$targetDir" "$targetBak" && echo "..fold backup ok: $targetDir to $targetBak" || return
  }
  [ -d "$configDir" ] && [ -f "$cfgfile" ] && {
    local configBak="$configDir-before-$(date +%Y%m%d-%H%M%S)"
    mv -f "$configDir" "$configBak" && echo "..fold backup ok: $configDir to $configBak" || return
  }

  mkdir -p "$targetDir" && echo "..unpack tar to: $(dirname $targetDir)" && tar -xf "$distfile" --directory "$(dirname $targetDir)" || return

  [ -f "$cfgfile" ] && tar -xf "$cfgfile" -C / && echo "..config restored ok: $cfgfile" || echo "..config NOT restored from: $cfgfile"

  local exe="$targetDir/firefox" && [ -x "$exe" ] || { echo "..file not found: $exe"; return 1; }
  local desktopEntryData=(
    Comment=firefox
    Exec=$exe
    Icon=/opt/firefox/browser/chrome/icons/default/default48.png
    Name=firefox
    Type=Application
  )
  desktop-entry-from-array firefox "${desktopEntryData[@]}"
  echo "..$FUNCNAME ok"
}

