#!/bin/bash
#more info: https://github.com/linrock/ssh-tunnels

function ssh-keygen-id {
  local usage="..Usage: $FUNCNAME <key-type:(rsa|dsa|ecdsa|ed25519)> [ssh-keygen options]; : generate a ssh key pair"
  local KEYTYPE=${1:?$usage}
  local pubFName=~/.ssh/id_rsa.pub ###on default
  local i
  for ((i=2; i <= ${#@}; i++))
  do
      [[ "${@:i:1}" == '-f' && "${@:i+1:1}" ]] && pubFName=${@:i+1:1}
  done 
  [ -f "$pubFName" ] && echo "..key file already exist: $pubFName" && return 1

  ssh-keygen -o -t "$KEYTYPE" ${@:2} ### TODO: test option -o
}

function ssh-remove-id {
  local USAGE="..Usage: $FUNCNAME <host[:port]> [ssh-keygen options]; Removes all keys belonging to hostname from a known_hosts file"
  local host=${1:?$USAGE}

  local knownHosts=~/.ssh/known_hosts ###on default known_hosts
  local opt_f='' i
  for ((i=2; i <= ${#@}; i++))
  do
    [[ "${@:i:1}" == '-f' && "${@:i+1:1}" ]] && opt_f=${@:i+1:1} && break
  done
  [ "$opt_f" ] && knownHosts=$opt_f && opt_f='' || opt_f="-f $knownHosts"
  [ -f "$knownHosts" ] || { echo "..known_hosts file not found: $knownHosts" && return 2; }

  ssh-keygen "$opt_f" -R "$host" ${@:2}
}

function scp-to {
  local usage="..Usage: $FUNCNAME <source-file/folder> <[user@]host> <dest-folder> [scp_options([-r:recursive] [-P port])]"
  local SOURCE_DATA=${1:?$usage}
  local user_host=${2:?$usage}
  local DEST_DIR=${3:?$usage}
  scp ${@:4} "$SOURCE_DATA" "$user_host:$DEST_DIR"
}

function scp-from {
  local usage="..Usage: $FUNCNAME <[user@]host> <source-file/folder> <dest-folder> [scp_options([-r:recursive] [-P port])]"
  local user_host=${1:?$usage}
  local SOURCE_DATA=${2:?$usage}
  local DEST_DIR=${3:?$usage}
  scp ${@:4} "$user_host:$SOURCE_DATA" "$DEST_DIR"
}

function sshfs-mount {
  local -r usage="..Usage: $FUNCNAME <[user@]host[:/remote/mount/dir/]> <mountPoint> [sshfs options(ex.: -p port)]"
  local user_host_dir=${1:?$usage}
  local mountPoint=${2:?$usage}

  local user_host=${user_host_dir/:*}
  local remote_dir=${user_host_dir:${#user_host}} && [ "$remote_dir" ] || remote_dir=':'
  [ "$(command -v ssh-hosts)" ] && user_host="$(ssh-hosts "$user_host")"
  local -a options_user_host=($user_host)
  user_host=${options_user_host[@]: -1}
  local options=${options_user_host[@]:0:${#options_user_host[@]}-1}

  sshfs $user_host$remote_dir $mountPoint $options ${@:3}
}

function sshfs-umount {
  local -r usage="..Usage: $FUNCNAME <mountPoint> [fusermount(umount) options]"
  local -r mountPoint=${1:?$usage}

  [ "$(command -v fusermount)" ] && fusermount -u ${@:2} "$mountPoint" || sudo umount ${@:2} "$mountPoint"
}

function ssh-bash {
  local usage="..Usage: $FUNCNAME ['ssh_options(-p port)'] <[user@]host> [[-x|-c: bash_options] [sudo] script.sh [param1,...]]"
  local sshOptions=${1:?$usage} && [[ ${1:0:1} == '-' ]] || sshOptions=''
  local user_host="$2" && [ "$sshOptions" ] || user_host="$1"
  [ "$(command -v ssh-hosts)" ] && user_host="$(ssh-hosts "$user_host")"
  local scriptName="${@:${#sshOptions} ? 3: 2}"
  [[ "$scriptName" =~ ^'sudo ' ]] && { local sudo='sudo'; scriptName=${scriptName:5}; }
  ssh $sshOptions $user_host -t $sudo bash $scriptName
}

function ssh-with-bashrc {
  local -r usage="..usage: $FUNCNAME [remote_cmd]; : copy & set up a bashrc file from \$BASHRC to remote first, then ssh"
  local bashrc=${BASHRC:-'http://my_local_server/my_bashrc'}
  ssh -fNM "$@" "curl -O $bashrc; ssh --rcfile ~/${bashrc##*/}"
}

function ssh-script {
  local -r usage="..Usage: $FUNCNAME ['ssh_options(-p port)'] <[user@]host> <[bash-option(-x)] [sudo] script-name [param]>; : Transfer and exec a script"
  local -r libFolder=/tmp/lib
  local sshOptions=${1:?$usage} && [[ ${1:0:1} == '-' ]] || sshOptions=''
  local user_host="$2" && [ "$sshOptions" ] || user_host="$1"
  [ "$(command -v ssh-hosts)" ] && user_host="$(ssh-hosts "$user_host")"
  local -r cmdIdx=$((${#sshOptions} ? 3: 2))
  local sudo='' scriptName=''
  local beSudo=0 scriptNameIdx=$cmdIdx i
  for ((i=$cmdIdx; i <= ${#@}; i++))
  do
    local bashopt="${@:$i:1}"
    [ "${bashopt:0:1}" != '-' ] && {
      if [ "$bashopt" == 'sudo' ]; then
        sudo='sudo'; beSudo=1
      else
        scriptName="$bashopt" && scriptNameIdx=$i && break
      fi
    }
  done
  [ -f "$scriptName" ] || { echo "..script not found:$scriptName; $usage" && return 2; }
  local -r remoteScriptName="$libFolder/$(basename "$scriptName")"
  cat "$scriptName" | ssh $sshOptions $user_host "mkdir -p "$libFolder" && cat > $remoteScriptName" || return
  ssh $sshOptions $user_host -t $sudo bash ${@:cmdIdx:scriptNameIdx-cmdIdx-beSudo} $remoteScriptName ${@:scriptNameIdx+1}
}

function ssh-console-function {
  local -r usage="..Usage: $FUNCNAME ['ssh_options(-p port)'] <[user@]host> <[bash-option(-x)] 'function-list' 'command'>;
                         : Create file(lib-<date>.sh) with the function-list, transfer it and exec the command"
  local -r libFolder=/tmp/lib
  local sshOptions=${1:?$usage} && [[ ${1:0:1} == '-' ]] || sshOptions=''
  local user_host="$2" && [ "$sshOptions" ] || user_host="$1"
  [ "$(command -v ssh-hosts)" ] && user_host="$(ssh-hosts "$user_host")"
  local -r cmdIdx=$((${#sshOptions} ? 3: 2))
  local sudo='' funcnames=''
  local beSudo=0 funcNameIdx=$cmdIdx i
  for ((i=$cmdIdx; i <= ${#@}; i++))
  do
    local bashopt="${@:$i:1}"
    [ "${bashopt:0:1}" != '-' ] && { 
      if [ "$bashopt" == 'sudo' ]; then
        sudo='sudo'; beSudo=1
      else
        funcnames="$bashopt" && funcNameIdx=$i && break
      fi
    }
  done
  [ "$funcnames" ] || { echo "..functions undefined; $usage" && return 2; }
  local libfile="$libFolder/lib-$(date +%Y%m%d-%H%M%S).sh"
  echo "..start build the file: $libfile with functions: $funcnames..."
  mkdir -p "$libFolder" && functions-to-file "$libfile" "$funcnames" || return 3

  cat "$libfile" | ssh $sshOptions $user_host "mkdir -p "$libFolder" && cat > $libfile" || return
  ssh $sshOptions $user_host -t $sudo bash -c ${@:cmdIdx:funcNameIdx-cmdIdx-beSudo} "'. $libfile && ${@:funcNameIdx+1}'"
}

function ssh-function {
  local -r usage="..Usage: $FUNCNAME ['ssh_options(-p port)'] <[user@]host> <[bash-option(-x)] [sudo] script/function [param]>; : Transfer script and exec its function with params"
  local -r libFolder=/tmp/lib
  local sshOptions=${1:?$usage} && [[ ${1:0:1} == '-' ]] || sshOptions=''
  local user_host="$2" && [ "$sshOptions" ] || user_host="$1"
  [ "$(command -v ssh-hosts)" ] && user_host="$(ssh-hosts "$user_host")"
  local -r cmdIdx=$((${#sshOptions} ? 3: 2))
  local sudo='' scriptFunctionName=''
  local beSudo=0 scriptFuncNameIdx=$cmdIdx i
  for ((i=$cmdIdx; i <= ${#@}; i++))
  do
    local bashopt="${@:$i:1}"
    [ "${bashopt:0:1}" != '-' ] && { 
      if [ "$bashopt" == 'sudo' ]; then
        sudo='sudo'; beSudo=1
      else
        scriptFunctionName="$bashopt"; scriptFuncNameIdx=$i; break
      fi
    }
  done
  local -r funcname="$(basename "$scriptFunctionName")"
  local scriptName="$(dirname "$scriptFunctionName")"
  [ -f "$scriptName" ] || { echo "..script not found:$scriptName; $usage" && return 2; }
  local -r remoteScriptName="$libFolder/$(basename "$scriptName")"
  cat "$scriptName" | ssh $sshOptions $user_host "mkdir -p "$libFolder" && cat > $remoteScriptName" || return
  ssh $sshOptions $user_host -t $sudo bash -c ${@:cmdIdx:scriptFuncNameIdx-cmdIdx-beSudo} "'. $remoteScriptName && $funcname ${@:scriptFuncNameIdx+1}'"
}

function functions2file {
  local usage="..Usage: $FUNCNAME <outfile> <function-list> [commands]; : copy to <outfile>:
                        shebag (if new file);
                        function bodies;
                        'command 1' 'command 2' one per line
                        "
  local -r outfname=${1:?$usage}
  local -ar funcnames=(${2:?$usage})
  local func i cou=$#
  for func in ${funcnames[@]}
  do
    [ "$(type -t $func)" == 'function' ] || { echo "..$func: not a function" && return 1; }
  done
  [ -f "$outfname" ] || { echo '#!/bin/bash' > "$outfname" || return ; }
  for func in ${funcnames[@]}
  do
    echo "$(declare -f $func)" >> "$outfname" || return
  done
  for (( i=3; i <= cou; i++ ))
  do
    echo "${@:i:1}" >> "$outfname" ### finnaly the commands copy out; rule: each param to own line
  done
}

function ssh-mkuser {
  local usage="..Usage: $FUNCNAME ['ssh_options(-p port)'] <[user@]host> [remote_user=$(id -un)]; : Add user on remote host"
  local sshOptions=${1:?$usage} && [[ ${1:0:1} == '-' ]] || sshOptions=''
  local user_host="$2" && [ "$sshOptions" ] || user_host="$1"
  local remoteUserName="$3" && [ "$sshOptions" ] || remoteUserName="$2"
  [ "$(command -v ssh-hosts)" ] && user_host="$(ssh-hosts "$user_host")"

  [ "$remoteUserName" ] || remoteUserName="$(id -un)"
  [[ "$user_host" =~ 'root@' ]] || SUDO='sudo'

  local -r cmd="$SUDO apt-get update && $SUDO apt-get install sudo && $SUDO adduser '$remoteUserName' && $SUDO adduser '$remoteUserName' sudo"
  ssh $sshOptions $user_host "$cmd"
}

function ssh-cp-id {
  local usage="..Usage: $FUNCNAME ['ssh_options(-p port)'] <[user@]host>; : Copy by ssh rsa key on remote host (same as ssh-copy-id)"
  local sshOptions=${1:?$usage} && [[ ${sshOptions:0:1} == '-' ]] || sshOptions=''
  local user_host="${2:-$1}" && [ "$(command -v ssh-hosts)" ] && user_host="$(ssh-hosts "$user_host")"

  [ -f ~/.ssh/id_rsa.pub ] || ssh-keygen -t rsa
  cat ~/.ssh/id_rsa.pub | ssh $sshOptions $user_host 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
}

function ssh-rm-id {
  local usage="..Usage: $FUNCNAME ['ssh_options(-p port)'] <[user@]host>; : Remove by ssh: ~/.ssh/authorized_keys"
  local sshOptions=${1:?$usage} && [[ ${sshOptions:0:1} == '-' ]] || sshOptions=''
  local user_host="${2:-$1}" && [ "$(command -v ssh-hosts)" ] && user_host="$(ssh-hosts "$user_host")"

  ssh $sshOptions $user_host 'rm -f ~/.ssh/authorized_keys'
}

function ssh-do {
  local usage="..Usage: $FUNCNAME ['ssh_options(-p port)'] <[user@]host> <[-P: bash_options] cmd1[; cmd2]>; : same as ssh-bash with -c option"
  local sshOptions=${1:?$usage} && [[ ${1:0:1} == '-' ]] || sshOptions=''
  local user_host="$2" && [ "$sshOptions" ] || user_host="$1"
  [ "$(command -v ssh-hosts)" ] && user_host="$(ssh-hosts "$user_host")"
  ssh $sshOptions $user_host -t bash -c "'id && ${@:${#sshOptions} ? 3: 2}'"
}

function test-add {
  local aa="$1"
  local bb="$2"
  echo "..$(hostname -I); test-add $@ result: $((aa+bb))"
}

function ssh-hosts {
  local -r usage="..Usage: $FUNCNAME <[user@]host> [hosts-file=/etc/bashit/hosts]"
  local userAtHost=${1:?$usage}
  local -r bashitHostsFName=${2:-/etc/bashit/hosts}
  local found port extraOptions userName hostName
 
  IFS='@' read -r userName hostName <<< "$userAtHost"
  [ "$hostName" ] || { hostName="$userAtHost"; userName=''; }
  if [ -f "$bashitHostsFName" ]; then
    while read -r line || [ -n "$line" ]
    do
      local noComment=${line/'#'*/}
      [[ "$line" =~ ^"$hostName:" || "$line" =~ "@$hostName:" ]] && found="$noComment" && break
    done < "$bashitHostsFName"
    if [ "$found" ]; then
      IFS=: read -r userAtHost port extraOptions <<< "$found"
      [[ "$userAtHost" =~ '@' && "$userName" ]] && {
        local dbUserName="${userAtHost/'@'*/}"
        [ "$userName" ] && userAtHost="$userName@${userAtHost:${#dbUserName}+1}"
      }
    fi
  fi
  [[ "$userAtHost" =~ '@' ]] || {
    [ "$userName" ] || userName="$(id -un)"
    userAtHost="$userName@$userAtHost"
  }
  [ "$port" ] && extraOptions="$extraOptions -p $port"
  echo "$extraOptions $userAtHost"
}
#uncomment it if needed: export -f ssh-hosts

function ssh-host-add {
  local -r usage="..Usage: $FUNCNAME <[default-user@]ip:host[:port][:extra-ssh-options][:comments]>; add data to /etc/hosts;/etc/bashit/hosts"
  local userAtHost=${1:?$usage}
  local -r bashitHostsFName=/etc/bashit/hosts
  local params userName ipv4 hostName port extraOptions comments

  IFS='@' read -r userName params <<< "$userAtHost"
  [ "$params" ] || { params="$userAtHost"; userName=''; }
  IFS=':' read -r ipv4 hostName port extraOptions comments <<< "$params"
  [[ $ipv4 =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]] || {
    echo "...ip address validate fail for ipv4:$ipv4"; return 1;
  }
  [ "$hostName" ] || { echo '...host name not specified'; return 1; }
  
  local bashitHostsData='' ###data format:[default-user@]host[:port][:extra-ssh-options] # and comments
  [ "$userName" ] && bashitHostsData="$userName@"
  bashitHostsData="$bashitHostsData$hostName"
  [ "$port" ] && bashitHostsData="$bashitHostsData:$port" || bashitHostsData="$bashitHostsData:22"
  [ "$extraOptions" ] && bashitHostsData="$bashitHostsData:$extraOptions"
  [ "$comments" ] && bashitHostsData="$bashitHostsData  #$comments"
  
  echo "../etc/hosts will be updated with:$ipv4 $hostName"
  echo "..$bashitHostsFName will be updated with:$bashitHostsData"
  echo "$ipv4 $hostName" | sudo tee -a /etc/hosts && echo "$bashitHostsData" | sudo tee -a "$bashitHostsFName" || return
  echo "../etc/hosts and $bashitHostsFName successfully updated"
}

function ssh-ls-fingerprints {
  ssh-add -l ### List fingerprints of all identities
}

function ssh-show-fingerprint {
  local -r usage="..Usage: $FUNCNAME [sshKeyFile=/etc/ssh/ssh_host_ecdsa_key]; show fingerprint of ssh key file"
  local KEY_FNAME=${1:-/etc/ssh/ssh_host_ecdsa_key}
  echo $KEY_FNAME | ssh-keygen -ql
}

function ssh-tun-port {
  local -r usage="..Usage: $FUNCNAME <localPort server serverPort ssh-server>; 
                    create ssh tunnel for local port to a server; 
                    used autossh instead ssh (sudo apt install autossh)
                    server os requires: /etc/ssh/sshd_config must have: AllowTcpForwarding yes
                    local  os requires: /etc/ssh/ssh_config  must have: GatewayPorts yes
                    more info: https://habr.com/ru/company/flant/blog/691388/"
  local localPort=${1:?$usage}
  local srv=${2:?$usage}
  local srvPort=${3:?$usage}
  local sshSrv=${4:?$usage}
  autossh -fnNT -L localhost:$localPort:$srv:$srvPort $sshSrv
}
