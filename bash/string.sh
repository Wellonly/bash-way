
# azazaz='abcdefghijklmnopqrstuvwxyz'	# a-z   :lower:
# AZAZAZ='ABCDEFGHIJKLMNOPQRSTUVWXYZ'	# A-Z   :upper:
# o9o9o9='0123456789'			# 0-9   :digit:
# azAZaz="${azazaz}${AZAZAZ}"	# a-zA-Z	:alpha:
# azAZo9="${azAZaz}${o9o9o9}"	# a-zA-z0-9	:alnum:

function substring-index {
  local source="$1"
  local substring="$2"
  local res=${source/${substring}*/} ### remove all chars starting from the substring inclusive
  [[ ${#source} == ${#res} ]] && echo '-1' || echo "${#res}"
}

function substring-prefix {
  local str1="$1"
  local str2="$2"
  echo "${str1%$str2*}"
}

function substring-suffix {
  local str1="$1"
  local str2="$2"
  echo "${str1#*$str2}"
}

function read-field {
  local -r data="${1:?specify line with data fields}"
  local -r index=${2:?specify index of field}
  local -r separator=${3:-:}
  IFS="$separator" read -r field0 field1 field2 <<< "$data"
  
  local -a results=( "$field0" "$field1" "$field2" )
  echo "${results[@:index:1]}"
}

function string-to-array {
  local -a array=($string)
}

function string-add-to-file-with-sudo {
  local -r usage="..usage: $FUNCNAME <string> <file> : add the string to a file as root"
  local str="${1:?specify a string to add to file}"
  local file="${2:?specify a file for add the string}"
  echo "$str" | sudo tee -a "$file"
}

function string-length {
  local -r usage="..usage: $FUNCNAME <string> : prints string length"
  local str="${1:?$usage}"
  echo "..string length: ${#str}"
}

function string-from-stdin {
  local -r usage="..usage: $FUNCNAME ; : read a stdin without blocking mode example"
  local PIPE=$(read -t 0 && cat)
  [ "$PIPE" ] && echo "..stdin:$PIPE" || echo $usage
}
