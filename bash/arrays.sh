#!/bin/bash

function array-find-item {
  local usage="..usage: ${FUNCNAME[0]} <array-name> <value> [start-from=0]; : scan <array-ref> for <value> starting from the element. Returns item or error"
  local -n arr=${1:?$usage}
  local item=${2:?$usage}
  local start=${3:-0}
  local idxs=${!arr[*]} ai
  # echo "..arrcou: ${#arr[*]}; item: $item; start: $start; idxs: $idxs; arr: ${arr[*]}"
  for ai in ${idxs[*]:$start}; do [[ ${arr[$ai]} =~ $item ]] && echo "${arr[$ai]}" && return 0; done
  return 1 ### not found
}

function array-find-index {
  local usage="..usage: ${FUNCNAME[0]} <array-name> <value> [start-from=0]; : scan <array-ref> for <value> starting from the element. Returns index or error"
  local -n arr=${1:?$usage}
  local item=${2:?$usage}
  local start=${3:-0}
  local idxs=${!arr[*]} ai
  # echo "..arrcou: ${#arr[*]}; item: $item; start: $start; idxs: $idxs; arr: ${arr[*]}"
  for ai in ${idxs[*]:$start}; do [[ ${arr[$ai]} =~ $item ]] && echo "$ai" && return 0; done
  return 1 ### not found
}

