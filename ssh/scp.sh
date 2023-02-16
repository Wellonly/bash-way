#!/bin/bash

function scp-from {
  local USAGE='..Usage: scp-from <[user@]host> <source-file/folder> <dest-folder> [scp_options]; copy a file/fold from a remote'
  local USER_HOST=${1:?$USAGE}
  local SOURCE_DATA=${2:?$USAGE}
  local DEST_DIR=${3:?$USAGE}
  scp ${@:4} "$USER_HOST:$SOURCE_DATA" "$DEST_DIR"
}
function ssh-scp-from { scp-from $@; } ### for quick list by ssh-Tab

function scp-to {
  local USAGE='..Usage: scp-to <source-file/folder> <[user@]host> <dest-folder> [scp_options]; : copy a file/fold to a remote'
  local SOURCE_DATA=${1:?$USAGE}
  local USER_HOST=${2:?$USAGE}
  local DEST_DIR=${3:?$USAGE}

  scp ${@:4} "$SOURCE_DATA" "$USER_HOST:$DEST_DIR"
}
function ssh-scp-to { scp-to $@; } ### for quick list by ssh-Tab
