#!/bin/bash

function setcap-nethogs {
  local -r usage="..usage: $FUNCNAME ; : set capability for nethogs after that it may be used wo sudo"
  sudo setcap cap_net_admin,cap_net_raw+ep /usr/sbin/nethogs
}

function getcap-nethogs {
  local -r usage="..usage: $FUNCNAME ; : get capability for nethogs"
  getcap /usr/sbin/nethogs
}

function nethogs-capability {
  local -r usage="..usage: $FUNCNAME [cap='cap_net_admin,cap_net_raw+ep']; : get or set nethogs capability"
  [[ $@ =~ '--help' ]] && echo "$usage" && return 4
  local cap=${1:-'cap_net_admin,cap_net_raw+ep'}
  [ "$cap" ] && sudo setcap "$cap" /usr/sbin/nethogs || getcap /usr/sbin/nethogs
}