#!/bin/bash

function jpg2video {
  local -r usage="..usage: $FUNCNAME [frame_rate_per_second=2] [ffmpeg-options]; : ffmpeg converter jpg files to video"
  [[ $@ =~ '--help' ]] && echo "$usage" && return 4
  local frame_rate_per_second=${1:-2}
  ffmpeg -framerate "$frame_rate_per_second" -pattern_type glob -i '*.jpg' -c:v libx264 -profile:v high -crf 20 -pix_fmt yuv420p ${@:2} output.mp4
}

