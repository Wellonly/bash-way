#!/bin/bash
# run this to prepare installation with copies of required scripts into one installer file
function configure-remote-deploy {
  local usage="..usage: ${FUNCNAME[0]} <deploy-config.sh> [destination-parent-dir=/tmp];
        : also consider to use next variables by deploy-config.sh:
        [POST_CMD]: variable to specify an installation command that will be executed after all;
        [COMMENT_INCLUDE]: used for include lines with matched comment content(on default all comment lines excluded)."
  local ret=$(_configure-remote-deploy $@) retcode=$? ### so we use fail()
  echo "$ret"
  return $retcode
}

function _configure-remote-deploy {
  [ "${FUNCNAME[1]}" == 'configure-remote-deploy' ] || { echo '..use: configure-remote-deploy()'; return 1; }
  local conf=${1:?"$usage"}
  local dest=${2:-/tmp}
  local LIB_PATH="${PWD/devops*}devops"
  [ -f "$conf" ] || fail "..configuration file not found: $conf"
  [ -d "$dest" ] || fail "..destination folder not exist: $dest"
  [ -d "$LIB_PATH" ] || fail "..scripts library folder not found: $LIB_PATH; run it from inside devops folder"
  local target_dir="$dest/$(basename $conf)-$(date +%Y%m%d)"
  local launcher="$(basename $conf)"
  local installator="$target_dir/install-$launcher"

  source "$conf" && [ "${#DEPLOY[*]}" != "0" ] || fail "source config: $conf not export(or export empty): \$DEPLOY"
  mkdir -p $target_dir || fail 'mkdir -p $target_dir'
  [ -f "$installator" ] && mkdir -p /tmp/conf-backups && mv "$installator" "/tmp/conf-backups/install-$launcher-before-$(date +%Y%m%d-%H%M%S).bak"
  cat "$conf" > $installator && echo >> $installator || fail create installator

  echo 'export DEPLOY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"' >> $installator
  echo '# compose lib begin...' >> $installator

  local -a funcname_array=()
  local idxFuncname=0
  local deploys=${#DEPLOY[*]} i
  echo "..number of items for deploy: $deploys; target dir: $target_dir"
  for ((i=0; i<$deploys; i++))
  do
    local line="${DEPLOY[i]}"
    local line_arr=($line)
    local deploy="${line_arr[0]}"
    local pathdeploy="$LIB_PATH/$deploy"
    if [ -f "$pathdeploy" ]; then
      transDeploy "$pathdeploy" "$line" >> $installator || fail "transDeploy $pathdeploy; line: $line"
    elif [ -d "$pathdeploy" ]; then
      local insname="$pathdeploy/install.sh"
      [ -f "$insname" ] || fail "not found: $insname"
      transDeploy "$insname" "$line" >> $installator || fail "transDeploy $insname; line: $line"
    else
      fail "not found: $pathdeploy"
    fi
  done
  echo '### end compose lib' >> $installator

  echo "function $launcher { ### composition begin..." >> $installator
  echo "..number of functional items for deploy: $idxFuncname"
  for ((i=0; i<$idxFuncname; i++))
  do
    echo "${funcname_array[i]}" >> $installator
  done
  echo '} ### end composition()' >> $installator

  [ "$POST_CMD" ] && echo "$POST_CMD" >> $installator

  chmod +x $installator || fail $installator
  echo "...all $deploys configured successfully to $target_dir"
} ### end configure()

function transDeploy {
  local usage="..usage: ${FUNCNAME[0]} [params]; : generate a function with content of the source file & fill external funcname_array[]"
  local sourceFName="$1"
  local deploy_line_arr=($2)
  local funcname="$(sed 's/\//_/g' <<<"${deploy_line_arr[0]}")"
  funcname_array[idxFuncname++]="$funcname ${deploy_line_arr[@]:1}"
  echo && echo "function $funcname { : ### $idxFuncname"
  inlineSource "$sourceFName" || fail "inlineSource $sourceFName"
  echo "} ### end $idxFuncname:$funcname"
}

function inlineSource {
  local usage="..usage: ${FUNCNAME[0]} <file.sh>; : inline the source file(expand 'source' links)"
  local file=${1:?$usage}
  local SCRIPT_DIR="$(dirname "$file")"
  while read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^(\.|source) ]]; then ###expand the source file...
      local spath=''
      [ "${line:0:1}" == '.' ] && spath=${line:2} || spath=${line:7}
      spath="$(eval "echo "$spath"")"
      if [ -f "$spath" ]; then
        echo "###source file included: $spath; instead line: $line"
        inlineSource "$spath" ###do recursive instead: cat "$spath" && echo
        echo "###end source: $spath"
      else
        echo "### file to expand not found: $spath; original line used: $line" 1>&2
        echo -E "$line ### file not found at compile time"
      fi
    elif [[ "$line" =~ ^\# ]]; then ### comments handler(no multiline support yet)...
      if [[ "$COMMENT_INCLUDE" && "$line" =~ $COMMENT_INCLUDE ]]; then
        echo -E $line ### -E: disable backslash escapes
        echo "### comment included: $line" 1>&2
      fi
    else
      echo -E $line ### -E: disable backslash escapes
    fi
  done < "$file"
}

