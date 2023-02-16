#!/bin/bash

function der-to-pem {
  local usage="..usage: ${FUNCNAME}; To Convert a DER file (.crt .cer .der) to PEM specify input file as \$1"
  [[ $@ =~ '--help' ]] && echo "$usage" && return 4

  local CER_INPUT_FILE=${1:?$usage}
  local PEM_OUTPUT_FILE=$2
  if [ ! "$PEM_OUTPUT_FILE" ]
  then
    PEM_OUTPUT_FILE="$CER_INPUT_FILE.pem"
  fi

  openssl x509 -inform der -in $CER_INPUT_FILE -out $PEM_OUTPUT_FILE
}

function showcert {
  local -r usage="..usage: $FUNCNAME <host:port>; show cert info by openssl, example: showcert mx.yandex.ru:25"
  local host_port=${1:?$usage}
  echo | openssl s_client -connect ${host_port} -starttls smtp 2>&1 | openssl x509 -noout -dates
}