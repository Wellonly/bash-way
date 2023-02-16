#!/bin/bash

function ssl-encrypt-file {
  local usage="..usage: ${FUNCNAME[0]} <file> [algo=-aes256] [openssl-options] [--help]; : encrypt the file by openssl
                                      more info: openssl enc -help"
  [[ $@ =~ '--help' ]] && echo "$usage" && return 4
  local FILE=${1:?$usage}
  local ALGO=${2:--aes256}

  local FILE_EXT="${FILE##*.}"
  local OUT="$FILE-enc.$FILE_EXT"

  echo "ALGO:$ALGO"
  echo "FILE:$FILE"
  echo "OUT:$OUT"
  openssl enc $ALGO ${@:3} -in $FILE -out $OUT
}

function ssl-decrypt-file {
  local usage="..usage: ${FUNCNAME[0]} <file> [algo=-aes256] [openssl-options] [--help]; : decrypt the file by openssl
                                      more info: openssl enc -help"
  [[ $@ =~ '--help' ]] && echo "$usage" && return 4
  local FILE=${1:?$usage}
  local ALGO=${2:--aes256}

  local FILE_EXT="${FILE##*.}"
  local OUT="$FILE-dec.$FILE_EXT"

  echo "ALGO:$ALGO"
  echo "FILE:$FILE"
  echo "OUT:$OUT"

  openssl enc -d $ALGO ${@:3} -in $FILE -out $OUT
  #openssl enc -aes-128-cbc -K $PASS -iv $IV -in $FILE -out $OUT
}

function ssl-rebuild {
  local usage="..usage: $FUNCNAME [--help]; : rebuild openssl by apt. Output: .deb"
  [[ $@ =~ '--help' ]] && echo "$usage" && return 4
  sudo apt-get build-dep openssl && apt-get source -b openssl
}