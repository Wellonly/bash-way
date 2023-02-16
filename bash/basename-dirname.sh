#!/bin/bash

function basename-dirname {
  local usage="..usage: ${FUNCNAME[0]} ; : examples of path parsing"
  local EXAMPLE=${1:-/tmp/example.tar.gz}
  local BASENAME="${EXAMPLE##*/}" || return
  
  echo "..\$EXAMPLE==\$1   : $EXAMPLE"             ### /tmp/example.tar.gz
  echo "..\$(dirname  \$1) : $(dirname $EXAMPLE)"  ### /tmp
  echo "..\$(basename \$1) : $(basename $EXAMPLE)" ### example.tar.gz
  echo '..or just bash...'
  echo "..\${EXAMPLE%/*}  : ${EXAMPLE%/*}"         ### /tmp
  echo "..\${EXAMPLE##*/} : ${EXAMPLE##*/}"        ### example.tar.gz
  echo "..\${EXAMPLE#*.}  : ${EXAMPLE#*.}"         ### tar.gz
  echo "..\${EXAMPLE##*.} : ${EXAMPLE##*.}"        ### gz
  echo "..\${BASENAME%%.*}: ${BASENAME%%.*}"       ### example
  echo "..\${BASENAME%.*} : ${BASENAME%.*}"        ### example.tar
}

function script-location {
  local usage="..usage: ${FUNCNAME[0]} [DIR=\$(cd \$( dirname \${BASH_SOURCE[0]} ) && pwd )]; : get script location example, no matter from where it was called"
  local SCRIPT_DIR=${1:-$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}
  echo $usage
  echo "..SCRIPT DIR==\$1   : $SCRIPT_DIR"
  echo "..\${BASH_SOURCE[@]}: ${BASH_SOURCE[@]}"
  echo "..\$(pwd)           : $(pwd)"
  echo "..\${PWD}           : ${PWD}"
}

function is-directory-empty {
  [ "$(ls -A "$1")" ] && echo "DIR: is NOT empty" || echo "DIR: is empty"
}
