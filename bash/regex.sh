#!/bin/bash

function is-host {
  local usage="..usage: ${FUNCNAME[0]} <nost-name>; : find line by last word with space or tab prefix"
  local hostName=${1:?$usage}
  echo "$(cat /etc/hosts | grep -P -m 1 "[\t ]$hostName$")"
}
