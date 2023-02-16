#!/bin/bash
function check-parameters-example {
  local PIPE=$(read -t 0 && cat) ### read a stdin without blocking mode
  local PAR1=${1:?Specify mandatory parameter for \$1}
  local PAR2=${2:-Default parameter value for \$2}
  shift ### shift first param, after that all params shifted: $1<$2<$3 and so on
  echo "params ok: $PAR1; $@"
  echo "if param not exits then exit with error! example: ${NOT_EXIST_PAR?}"

  #iterate throw parameters... do not clone: arr=($@) because 'aa bb' param will be splitted
  for ((i=0; i <= ${#@}; i++))
  do
      echo "parameter[$i] value: ${@:i:1}; next value: ${@:i+1:1};"
  done 
}

function iterate-throw-parameters {
  local usage="..usage: ${FUNCNAME[0]} \$@; : iterate, see also: bash/arrays.sh"
  local i
  for ((i=0; i <= $#; i++ ))
  do 
    echo "param[$i]:${@:i:1}; next value: ${@:i+1:1};"
  done
}
