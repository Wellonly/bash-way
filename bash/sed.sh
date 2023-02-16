
function sed-replace-only-first {
  local usage='..usage: sed-replace-only-first <pattern> <replacement> [sed-options file-name];: replace only first occurence'
  local pattern=${1:?$usage}
  local replacement=${2:?$usage}
  sed -i "0,/$pattern$/s/$pattern$/$replacement/1" ${@:3}
}

function sed-replace-text {
  local usage='..usage: sed-replace-in-line <text> <replacement> <occurence=g(g=all,1,2..)> [sed-options file-name];: replace text with replacement. Example: sed-replace-in-line "text" "newtext" file.txt'
  local txt=${1:?$usage}
  local replacement=${2:?$usage}
  local occurance=${3:?$usage}
  sed -i "s/$txt/$replacement/$occurance" ${@:4}
  # sed -i:replace text in place(in file)
}

function jsonEscape {
  local usage="..usage: ${FUNCNAME[0]} <json>; : escape characters in json strings for telegram"
  local txt=${1:?$usage}
	sed -E -e 's/\r//g' -e 's/([-"`´,§$%&/(){}#@!?*.\t])/\\\1/g' <<< "${txt//$'\n'/\\n}"
}

function cleanEscape {
  local usage="..usage: ${FUNCNAME[0]} ; : clean \ from escaped json string, but  \n\u		\n or \r"
  local txt=${1:?$usage}
	sed -E -e 's/\\"/+/g' -e 's/\\([^nu])/\1/g' -e 's/(\r|\n)//g' <<<"${txt}"
}
