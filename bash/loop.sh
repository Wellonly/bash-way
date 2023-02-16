#!/bin/bash
# for examples: show date every 1 second

function while-loop {
  while sleep 1;
  do 
    ./getdate.sh
  done
}

function until-loop {
  until sleep 1; do
    ./getdate.sh
  done
}

function for-name-loop {
  local dir11="/opt/dr11"
  local dir22="/opt/dr22"
  for name in "$dir11" "$dir22"
  do 
    echo "..loop for: '$name'"; 
  done
}

see also doc for:
# until test-commands; do commands; done ### Execute commands as long as test-commands has an exit status which is not zero.
# while test-commands; do commands; done ### Execute commands as long as test-commands has an exit status of zero.
# for name [ [in [words ...] ] ; ] do commands; done
# for (( expr1 ; expr2 ; expr3 )) ; do commands ; done
# The break and continue builtins may be used for control loops
