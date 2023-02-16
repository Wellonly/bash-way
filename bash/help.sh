#!/bin/bash

function bash-reference {
  local usage="..usage: ${FUNCNAME[0]} [--help]; : install bash-doc & make Desktop link for it"
  [[ $@ =~ '--help' ]] && echo "$usage" && return 4
  local bashref='/usr/share/doc/bash-doc/bashref.pdf'

  echo '..zv: apt install bash-doc...'
  sudo apt install bash-doc

  [ -f $bashref ] && ln -s -t ~/Desktop $bashref || return 1
  echo '..success: bashref.pdf link created on ~/Desktop' 
}

function Man {
  local -r usage="..usage: $FUNCNAME <man-page>; : open man with the <man-page> content in kate editor"
  local target=${1:?$usage}
  local contentFName="/tmp/kate/$target"
  mkdir -p /tmp/kate
  man "$target" > "$contentFName" || return
  kate "$contentFName"
}
