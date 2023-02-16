#!/bin/bash
#example of an init script

echo "..exec pre-config catalog item: $0; \$1:$1; \$2:$2; BASH_SOURCE[1]:${BASH_SOURCE[1]}; BASH_SOURCE[2]:${BASH_SOURCE[2]}; BASH_SOURCE[3]:${BASH_SOURCE[3]}"

function doExample()
{
  echo "..exec doExample catalog item: $0; \$1:$1; \$2:$2; BASH_SOURCE[1]:${BASH_SOURCE[1]}; BASH_SOURCE[2]:${BASH_SOURCE[2]}; BASH_SOURCE[3]:${BASH_SOURCE[3]}"
}

