#!/bin/bash
# okteta: gui version of binary editor

function alias-xxd {
  local -r usage="..usage: $FUNCNAME <binary-file> [other-xxd-options]; : read and print binary data. 
                    ex: alias-xxd file.dat -s 0 -l 32; : print 32 bytes from 0 offset of the file"
  local fname=${1:?"$usage"}
  [ -f "$fname" ] || { echo "..binary file not found: $fname"; return 1; }
  xxd ${@:2} "$fname"
}

function binary-cat-from-top {
  local -r usage="..usage: $FUNCNAME <binary-file> [other-xxd-options]; : read and print binary data from top of the file 128 bytes"
  local fname=${1:?"$usage"}
  [ -f "$fname" ] || { echo $usage; echo "..binary file not found: $fname"; return 1; }
  xxd -s 0 -l 128 ${@:2} "$fname"
}

function binary-cat-from-end {
  local -r usage="..usage: $FUNCNAME <binary-file> [other-xxd-options]; : read and print binary data from end of the file 128 bytes"
  local fname=${1:?"$usage"}
  [ -f "$fname" ] || { echo $usage; echo "..binary file not found: $fname"; return 1; }
  xxd -s -128 -l 128 ${@:2} "$fname"
}
