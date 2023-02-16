#!/bin/bash

function sshfs-mount {
  local USAGE="..Usage: ${FUNCNAME[0]} <[user@]host[:/remote/mount/dir/]> <mountPoint> [sshfs options(ex.: -p port)]"
  local USER_HOST_DIR=${1:?$USAGE}
  local mountPoint=${2:?$USAGE}
  [[ "$USER_HOST_DIR" =~ ':' ]] || USER_HOST_DIR="$USER_HOST_DIR:"
  sshfs "$USER_HOST_DIR" "$mountPoint" ${@:3}
}
function ssh-fs-mount { sshfs-mount $@; } ### for quick list by ssh-Tab

function sshfs-umount {
  local USAGE="..Usage: ${FUNCNAME} <mountPoint> [fusermount(umount) options]; : unmount wo sudo or with sudo"
  local mountPoint=${1:?$USAGE}
  [ "$(command -v fusermount)" ] && fusermount -u ${@:2} "$mountPoint" || sudo umount ${@:2} "$mountPoint"
}
function ssh-fs-umount { sshfs-umount $@; } ### for quick list by ssh-Tab
