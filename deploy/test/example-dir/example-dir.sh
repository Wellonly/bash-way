#!/bin/bash
#example of an init script

export expo_dir="expo_dir: $0; BASH_SOURCE[0]:$(basename "${BASH_SOURCE[0]}"); BASH_SOURCE[1]:$(basename "${BASH_SOURCE[1]}"); BASH_SOURCE[2]:$(basename "${BASH_SOURCE[2]}"); \$1:$1; \$2:$2"
