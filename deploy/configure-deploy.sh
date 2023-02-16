#!/bin/bash
# run this to prepare installation with copies of required scripts

function configure-deploy {
  local -r usage="..usage: ${FUNCNAME[0]} <deploy-config.sh> [destination-parent-dir=/tmp]; : create a folder with install files. 
                            Call it from within devops folder"
  local ret=$(_configure-deploy $@) retcode=$? ### so we use fail()
  echo "$ret"
  return $retcode
}

function _configure-deploy {
  [ "${FUNCNAME[1]}" == 'configure-deploy' ] || { echo '..use: configure-deploy()'; return 1; }
  local -r conf=${1:?"$usage"}
  local -r dest=${2:-/tmp}
  local -r LIBPATH="${PWD/devops*}devops"
  [ -f "$conf" ] || fail "..configuration file not found: $conf"
  [ -d "$dest" ] || fail "..destination folder not exist: $dest"
  [ -d "$LIBPATH" ] || fail "..scripts library folder not found: $LIBPATH; run it from inside devops folder"
  local -r DEPLOYTODIR="$dest/$(basename $conf)-$(date +%Y%m%d-%H%M%S)"
  local -r INSTALLER="$DEPLOYTODIR/install-$(basename $conf)"

  mkdir $DEPLOYTODIR || fail 'mkdir $DEPLOYTODIR'
  cat "$conf" > $INSTALLER && echo >> $INSTALLER || fail 'create $INSTALLER'

  unset DEPLOY LIB; source "$conf" $@ || fail "of source configurator: $conf"
  for lib in ${LIB[@]}
  do
      local lib_source && [[ "${lib:0:1}" =~ ('.'|'/') ]] && lib_source="$lib" || lib_source="$LIBPATH/$lib"
      [ -f "$lib_source" ] || fail "lib source not found: $lib_source"
      source "$lib_source" || fail "on lib load: $lib_source"
  done 
  [ "$(type -t preconfigure)" ] && {
    preconfigure $@ || fail "of preconfigure()"
  }
  echo -e "${GREEN}..config ok, continue build deploy in:${NORM} $DEPLOYTODIR..."

  echo 'export DEPLOY_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )' >> $INSTALLER
  echo '{ ###deploys init begin' >> $INSTALLER
  local deploys=${#DEPLOY[*]} i isNotEmpty
  echo "..number of \$DEPLOY items: $deploys; target dir: $DEPLOYTODIR"
  for (( i=0; i < deploys; i++ ))
  do
    local line="${DEPLOY[i]}"
    local line_arr=($line)
    local deploy="${line_arr[0]}"
    local include && [[ "${deploy:0:1}" =~ ('.'|'/') ]] && include="$deploy" || include="$LIBPATH/$deploy"
    if [ -f "$include" ]; then
      local subdir="$(dirname $deploy)"
      mkdir -p "$DEPLOYTODIR/$subdir" && cp "$include" "$DEPLOYTODIR/$subdir" || fail 'cp $include $DEPLOYTODIR/$subdir'
      [ "${include##*.}" == 'sh' ] && echo -e "source \"\$DEPLOY_DIR\"/$line" >> $INSTALLER && isNotEmpty=true
    elif [ -d "$include" ]; then
      local subdir="$(dirname $deploy)"
      mkdir -p "$DEPLOYTODIR/$subdir" && cp -r "$include" "$DEPLOYTODIR/$subdir" || fail 'cp -r $include $DEPLOYTODIR/$subdir'
      [ -f "$include/install.sh" ] && echo -e "source \"\$DEPLOY_DIR\"/$deploy/install.sh ${line_arr[@]:1}" >> $INSTALLER && isNotEmpty=true
    elif [ "$(type -t $deploy)" ]; then
      [ "$(type -t $deploy)" == 'function' ] || fail "$deploy: $(type -t $deploy) and not a function"
      echo "$(declare -f $deploy)" >> $INSTALLER && isNotEmpty=true
    else
      fail "not found: $deploy"
    fi
  done
  [ $isNotEmpty ] || echo ': no deploys to init' >> $INSTALLER
  echo '} ###end deploys init' >> $INSTALLER
  [ "$POST_CMD" ] && echo "$POST_CMD" >> $INSTALLER
  unset DEPLOY LIB

  chmod +x $INSTALLER
  echo "..all $deploys configured successfully to $DEPLOYTODIR"
}

