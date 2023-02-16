#!/bin/bash
#to debug a shell function use: set -x && shell_function

#to interactive debug use next command:
#trap 'debug-trap' DEBUG or trap 'echo "# $BASH_COMMAND";read' DEBUG
#to stop interactive debug use next command: trap DEBUG

[ "$DEBUG" ] && set -x && echo "DEBUG enabled. Option -x: print trace info. $(date)"
[ "$DEBUG" == 'v' ] && set -v && echo 'DEBUG=v Option -v: print input lines'

[ "$RED" ] || readonly RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[0;33m' RESET='\033[0m' NORM='\033[0m'

function debug-trap {
  local -r usage="..usage: $FUNCNAME [prompt]; insert: trap '$FUNCNAME' DEBUG; stop using: trap DEBUG"
  [[ $@ =~ '--help' ]] && echo "$usage" && return 4
  local prom=${1:-"debug-trap>"}
  echo "# $BASH_COMMAND";
  while read -p "$prom>" _cmnd; do
      if [ "$_cmnd" ]; then
          eval "$_cmnd";
      else
          break;
      fi;
  done
}

function debug-show-call-stack {
  local usage="..usage: ${FUNCNAME[0]}; : call it from a function to be debugging"
  [ "${FUNCNAME[1]}" ] || { echo $usage; return 1; }
  echo -e "\033[0;33m..${FUNCNAME[0]}:\033[0m ${FUNCNAME[@]:1}; line numbers: ${BASH_LINENO[@]} from ${BASH_SOURCE[@]:1}"
}

function echo-err {
  echo -e "${RED}$(date) ERROR: $@ ${RESET}"
}

function echo-info {
  echo -e "${GREEN}$(date) INFO: $@ ${RESET}"
}

function echo-warn {
  echo -e "${YELLOW}$(date) WARN: $@ ${RESET}"
}

function debug-enable {
  [ ! "$DEBUG" ] && echo "For debug usage: env DEBUG=1 $0"
  if [ "${DEBUG}" ]; then
    echo_info "Turning debugging on.."
    export PS4='+(${BASH_SOURCE}:${LINENO})> ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    set -x
  fi
}

function shopt-extdebug-enable {
  shopt -s extdebug
}
function shopt-extdebug-disable {
  shopt -u extdebug
}