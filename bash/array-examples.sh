#!/bin/bash
#demo functions for tests only

function array-as-param-example {
  local usage="..usage: ${FUNCNAME[0]} <file> [key=value array]; : ex.: ${FUNCNAME[0]} \"\$file\" \"\${arr[@]}\""
  local file=${1:?"$usage"}
  local arr=(${@:2})
  local arrcou=${#arr[*]} i
  for (( i=0; i < arrcou; i++ ))
  do
    local line="${arr[i]}"
    local key=${line%%=*}
    local value=${line#*=}
    echo "..service-create: $i/$arrcou: line: $line: key: $key: value: $value"
  done
}

#iterate throw parameters... do not clone: arr=($@) because 'aa bb' param will be splitted
function array-iterate-throw-parameters-example {
  local usage="..usage: ${FUNCNAME[0]} '11' '22' ...; : descript"
  for ((i=0; i <= ${#@}; i++))
  do
    echo "parameter[$i] value: ${@:i:1}; next value: ${@:i+1:1}"
  done 
}

function array-read-from-file-example {
  local usage="..usage: ${FUNCNAME[0]} <file> [mapfile-options] ; : read array from the <file>"
  local file=${1:?$usage}; 
  local opt=${2:--t};
  local array && readarray $opt array < $file
  echo "..array len: ${#array[@]}: ${array[@]}"
}

function array-read-from-stdin-example {
  local usage="..usage: ${FUNCNAME[0]} ; : read an array from stdin: line as item"
  local PIPE=$(read -t 0 && cat); readarray -t array <<< $PIPE ### read a stdin without blocking mode v1
  readarray -t array <(read -t 0 && cat) ### read a stdin without blocking mode v2
  echo "..array len: ${#array[@]}: ${array[@]}"
}

function array-iterate-by-index-example {
  local usage="..usage: ${FUNCNAME[0]} 'one' 'two' ...; : iterate by index"
  local array=(${@:1})
  echo "Number of items in original array: ${#array[*]}"
  for ix in ${!array[*]}
  do
      echo "${array[$ix]}"
  done
}

function array-on-words-example {
  local usage="..usage: ${FUNCNAME[0]} 'one two ...'; : fill array from \$1 on words basis"
  local -ar arr=($1) ### the param to string array
  echo "Number of items in original array: ${#arr[*]}"
  for i in ${arr[@]}
  do
      echo "array value: $i"
  done 
}

function array-add-item-examples {
  local usage="..usage: ${FUNCNAME[0]} <item-value> <array>; : add <item-value> to array examples"
  local item=${1:?"$usage"}
  local arr=(${@:2})
  arr+=("$item") ### v1
  arr[${#arr[@]}]="$item"  ### v2
  arr=(${arr[@]} "$item")   ### v3
  local arr3=(${arr1[@]} ${arr2[@]})  ### v4 concatenate arrays
}

