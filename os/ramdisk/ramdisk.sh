#!/bin/bash

function ramdisk {
  local usage="..usage: ${FUNCNAME[0]} <size(ex.:100m, 10G)> <mountPoint(ex.:/tmp/ramdisk)>; : mount ramdisk as tmpfs"
  local size=${1:?$usage}
  local mountPoint=${2:?$usage}
  local chmodAccessRights=${3:-a=rwx}

  [ -d "$mountPoint" ] && sudo umount "$mountPoint"
  mkdir -p "$mountPoint" && chmod "$chmodAccessRights" "$mountPoint" &&
    sudo mount -t tmpfs -o size="$size" "$(basename "$mountPoint")" "$mountPoint" && 
    echo "..ramdisk $size created and mounted on: $mountPoint"
}
