#!/bin/bash

function trap-on-exit {
  local -r usage='..usage: trap-on-exit <exec>; : execute <exec> on exit event; to list traps use: trap -l'
  local exe=${1:?$usage}
  trap "$exe" EXIT
}

#for example we use: ping
function kill-pid-by-trap {
    local usage='..usage: kill-pid <pid>; alias for: kill -SIGINT "$pid"'
    local pid=${1:?}
    local psinfo=$(ps "$pid"|grep "$pid")
    trap - SIGINT SIGTERM ### recover trap to default state
    [ "$psinfo" ] || { echo "..process not found with pid: $pid"; return ; }
    echo "..we will kill: $psinfo by send a signal -SIGINT"
    kill -SIGINT "$pid"
}

function trap-example {
  echo "..starting ping web server..."
  ping -c 10 google.com &
  local pid="$!"
  trap "kill-pid-by-trap $pid" SIGINT SIGTERM
  wait "$pid"
  echo "..end trap-example for pid: $pid"
}