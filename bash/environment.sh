#!/bin/bash

function test-environment () 
{
  echo "..0:$0;_:$_;BASH_SOURCE[@]:${BASH_SOURCE[@]}"
  echo "..user name: $(id -un); SUDO_USER: $SUDO_USER; HOSTNAME: $HOSTNAME"

  [ $UID == 0 ] && echo "..executing as root!!!" || echo "..non root id: $UID ($(id -un))"

  [ "${BASH_SOURCE[1]}" ] && echo "..this is called by other func or by exec the script: ${BASH_SOURCE[1]}" || echo "..this is called directly from a console"

  echo "..print shell options: " && set -o
  echo "..print all environments include body of active functions: " && set

}
