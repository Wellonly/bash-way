#!/bin/bash
#TODO: use all chattr attributes

function alias-lsattr { lsattr ${@:1}; }

function chattr-i-set { 
  local -r usage="..usage: $FUNCNAME <file> [chattr-opts] ; : set(+i) attribyte to protect the file from write access"
  sudo chattr +i ${@:1}
}
function alias-chattr-i-set { chattr-i-set ${@:1}; }

function chattr-i-clear { 
  local -r usage="..usage: $FUNCNAME <file> [chattr-opts] ; : clear(-i) attribyte to unprotect the file from write access"
  sudo chattr -i ${@:1}
}
function alias-chattr-i-clear { chattr-i-clear ${@:1}; }
