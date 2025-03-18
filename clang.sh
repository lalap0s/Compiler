#!/bin/bash

echo -e "==========================="
echo -e "= START COMPILING KERNEL  ="
echo -e "==========================="
bold=$(tput bold)
normal=$(tput sgr0)

# Scrip option
while (( ${#} )); do
    case ${1} in
        "-Z"|"--zip") ZIP=true ;;
    esac
    shift
done
[[ -z ${ZIP} ]] && { echo "${bold}LOADING-_-....${normal}"; }

DEFCONFIG="mi8937i_defconfig"
export KBUILD_BUILD_USER=LalapOs
export KBUILD_BUILD_HOST=LalapOs
export PATH="/root/clang/bin:$PATH"

if [[ $1 = "-r" || $1 = "--regen" ]]; then
make O=out ARCH=arm64 $DEFCONFIG savedefconfig
cp out/defconfig arch/arm64/configs/$DEFCONFIG
exit
fi

if [[ $1 = "-c" || $1 = "--clean" ]]; then
rm -rf out
fi

mkdir -p out
make O=out ARCH=arm64 $DEFCONFIG


make -j$(nproc --all) O=out ARCH=arm64 
                   CC=clang  
                   AR=llvm-ar 
                   AS=llvm-as 
                   NM=llvm-nm 
                   OBJDUMP=llvm-objdump 
                   STRIP=llvm-strip 
                   CROSS_COMPILE=aarch64-linux-gnu- 
                   CROSS_COMPILE_ARM32=arm-linux-gnueabi- 2>&1 | tee log.txt

    echo -e "==========================="
    echo -e "   COMPILE KERNEL COMPLETE "
    echo -e "==========================="

if [[ ":v" ]]; then
exit
fi