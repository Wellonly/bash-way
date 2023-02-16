#!/bin/bash
#POST_CMD='echo "...successfully done with: $@"'
COMMENT_INCLUDE='Client:'
#SERVER_WG_IPV4=192.168.1.1

export DEPLOY=( 
  soft/wg/wg-stub.sh
  soft/wg/wgctl-test.sh
  soft/wg/wg-client-add.sh
  soft/wg/wg-client-revoke.sh
  soft/wg/wg-uninstall.sh
  soft/wg/wgctl.sh
)
