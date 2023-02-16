#!/bin/bash
#example of an init script with source

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$SCRIPT_DIR/example-cat-dir.sh"
  source "$SCRIPT_DIR"/example-dir.sh

  . "$SCRIPT_DIR"/example-dir.sh

function exampleDirInit.sh () {
  echo "..exampleDirInit(): $@"
}

echo "..exec catalog dir: $0; \$1:$1; \$2:$2; and DEPLOY_DIR: $DEPLOY_DIR"
echo "..inst:expo_cat_dir: $expo_cat_dir"
echo "..inst:expo_dir: $expo_dir"
