#!/bin/bash

function case-bot-commands-example {
  local ret cmd=${1:--}
  case $cmd in
  '/start') ret="Just few commands are implemented yet";;
  '/ps') ret="$(ps aux --sort=-pcpu | head -n5)";;
  '/meminfo') ret="$(cat /proc/meminfo)";;
  '/cpuinfo') ret="$(cat /proc/cpuinfo)";;
  '/uname') ret="$(uname -a)";;
  '/log') ret="$(cat /opt/var/log/bot.log)";;
  *) ret="$cmd";;
  esac
  echo "$ret"
}
