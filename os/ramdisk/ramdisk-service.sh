#!/bin/bash

function backup-suffix { echo "$1.backuped-by-${FUNCNAME[1]}-$(date +%Y%m%d-%H%M%S)"; }

function ramdisk-engage {
  local usage="..usage: ${FUNCNAME[0]} <disk_size(e.g.:10G)> [mountPoint=/mnt/ramdisk] [rambackup=/mnt/ramdisk_backup]; : engage ramdisk service"
  local RAMSIZE=${1:?$usage}
  local RAMMOUNT=${2:-/mnt/ramdisk}
  local RAMBACKUP=${3:-/mnt/ramdisk_backup}

  [ $(id -u) != 0 ] && echo "..run it as root; $usage" && return 1

  local FSTABFILE="/etc/fstab"
  local FSTABLINE="tmpfs $RAMMOUNT tmpfs rw,size=$RAMSIZE 0 0"

  #stage 1: fstab check and update if needed...
  if [ "$(cat $FSTABFILE | grep ramdisk )" != "$FSTABLINE" ]; then
    sed -i$(backup-suffix) '/ramdisk/d' $FSTABFILE || return
    echo $FSTABLINE | tee -a $FSTABFILE || return
  fi

  #stage 2: create service file...
  local SERVICE_FNAME="/lib/systemd/system/ramdisk.service"
  local TMP_SRV_FNAME=$(mktemp -t ramdisk.XXX)
  ( cat <<-EOF
#$SERVICE_FNAME was auto generated by $0

[Unit]
Before=umount.target
Description=ramdisk service
Documentation=$0

[Service]
Type=oneshot
User=root
ExecStartPre=/bin/chown -Rf user:user $RAMMOUNT
ExecStart=/usr/bin/rsync -ar $RAMBACKUP/ $RAMMOUNT/
ExecStop=/usr/bin/rsync -ar $RAMMOUNT/ $RAMBACKUP/
ExecStopPost=/bin/chown -Rf user:user $RAMBACKUP
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target

EOF
  ) > $TMP_SRV_FNAME

  if [ "$(diff $SERVICE_FNAME $TMP_SRV_FNAME 2>&1 || echo empty)" ]; then
    [ -f "$SERVICE_FNAME" ] && cp -f $SERVICE_FNAME $(backup-suffix $SERVICE_FNAME)
    cp -f $TMP_SRV_FNAME $SERVICE_FNAME && chmod 644 $SERVICE_FNAME
    [ $? != 0 ] && rm -f $TMP_SRV_FNAME && echo "...SERVICE_FNAME: $SERVICE_FNAME fail" && return 4
  fi
  rm -f $TMP_SRV_FNAME || echo "...something wrong with file: $TMP_SRV_FNAME"

  #stage 3: start service ...
  mkdir -p $RAMMOUNT --mode=777 && mkdir -p $RAMBACKUP --mode=777 || return
  systemctl enable --now $SERVICE_FNAME && echo "..$SERVICE_FNAME engaged OK; may be need to reboot" || { 
    echo "..SERVICE_FNAME: $SERVICE_FNAME fail" && return 4
  }

}

function ramdisk-remove {
  local usage="..usage: ${FUNCNAME[0]} <disk_size(e.g.:10G)> [mountPoint=/mnt/ramdisk]; : remove ramdisk service"
  local RAMSIZE=${1:-?$usage}
  local RAMMOUNT=${2:-/mnt/ramdisk}

  [ $(id -u) != 0 ] && echo "..run it as root; $usage" && return 2

  local FSTABFILE="/etc/fstab"
  local FSTABLINE="tmpfs $RAMMOUNT tmpfs rw,size=$RAMSIZE 0 0"

  #stage 1: fstab check and update if needed...
  if [ "$(cat $FSTABFILE | grep ramdisk )" ]; then
    sed -i$(backup-suffix) '/ramdisk/d' $FSTABFILE || return
  fi

  #stage 2: stop service ...
  local SERVICE_FNAME="/lib/systemd/system/ramdisk.service"
  systemctl disable --now $SERVICE_FNAME && 
    rm -f $SERVICE_FNAME &&
    echo "..$SERVICE_FNAME disabled OK; may be need to reboot"
}