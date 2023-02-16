#!/bin/bash

function calc-integer {
  local -r usage="..usage: $FUNCNAME <expression>; : calc integer expression using: \$((expr))"
  local opts=${1:?$usage}
  local result=$(($@))
  echo $result
}

function calc-float {
  local -r usage="..usage: $FUNCNAME <expression>; : calc float expression using: bc; ex.: $FUNCNAME 'scale=3; 1/3'"
  local opts=${1:?$usage}
  echo "$@" | bc
}
