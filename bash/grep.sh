#/bin/bash

function grep-any-line {
  local -r usage="..usage: $FUNCNAME <search-for-file> <search-in-file>; : search any line from <search-for-file> in the <search-in-file>
                                for file syntax: each line as a word for grep expression, skipped empty lines and started from '#'"
  local searchForFile=${1:?"$usage"}
  local searchInFile=${2:?"$usage"}
  [ -f "$searchForFile" ] || { echo "..file not found:$searchForFile"; echo "$usage"; return 1; }
  [ -f "$searchInFile" ] || { echo "..file not found:$searchInFile"; echo "$usage"; return 1; }

  local searchForArray && readarray -t searchForArray < $searchForFile
  local exp="" ai cou=0
  for ai in ${searchForArray[*]};
  do 
    [ "$ai" ] && [ ${ai:0:1} != '#' ] && exp="$exp|$ai" && ((cou++))
  done
  local grepExpr="${exp:1}"
  echo "..grep expression words: $cou"
  grep -n -E $grepExpr $searchInFile
}
