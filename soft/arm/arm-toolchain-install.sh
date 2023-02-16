#!/bin/bash

function arm-toolchain-install {
local dist_dir='/media/sf_vms/ins/toolchain'
local def_parent_ins_dir='/opt/toolchain'
local symlink='/opt/toolchain/gcc-arm'
local def_version='10.3-2021.10'
local def_arch='x86_64-linux'
local -r usage="..usage: $FUNCNAME [version=$def_version] [arch=$def_arch] [parent-install-dir=$def_parent_ins_dir]"
[[ $@ =~ '--help' ]] && echo "$usage" && return 4

local version=${1:-$def_version}
local TOOLCHAIN_ARCH=${2:-$def_arch}
local parent_ins_dir=${3:-$def_parent_ins_dir}
local name_and_version="gcc-arm-none-eabi-$version"
local name_version_arch="$name_and_version-$TOOLCHAIN_ARCH"
local fullname="$name_version_arch.tar.bz2"
local URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/$version/$fullname"

local loadfname="$dist_dir/$fullname"
local targetdir="$parent_ins_dir/$name_and_version"
local skipDownload
[ -s "$loadfname" ] && echo "..$loadfname already present, skip download" && skipDownload="skip"
[ -d "$targetdir" ] && echo "..$targetdir already installed" && return 2
[ "$skipDownload" ] || {
  echo "..download $URL"
  mkdir -p $dist_dir && wget "$URL" -O "$loadfname" --directory-prefix="$dist_dir" || return
}
echo "..sudo apt install..." && sudo apt install libncurses5 || return ### libncurses5 for arm-none-eabi-gdb
echo "..extract $loadfname to $targetdir"
mkdir -p $targetdir && tar -x -f $loadfname -C $targetdir --strip-components 1 || return
[ -d "$symlink" ] && echo "..link present $symlink, check it" || 
  { echo "..make symbolic link $symlink..." && ln -s "$targetdir/ $symlink"; }

echo "..$FUNCNAME done, enjoy"
}
