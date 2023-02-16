#!/bin/bash
#to print a messages to kernel ring buffer so dmesg can show that...
#TODO: build zv own driver to print a messages from a user space

function echok {
  local -r usage="..usage: $FUNCNAME ; : print a messages to the kernel ring buffer so dmesg can show that
                                    TODO: build zv own driver to print a messages from a user space"
  echo "${@?}" | sudo tee /dev/kmsg > /dev/null
}
