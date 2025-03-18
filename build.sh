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

echo -e "=             cleaning output               ="
   rm -rf out

echo -e "=    cloning AnyKernel3   ="
if [ -d "AnyKernel3" ]; then
    echo -e " [!] AnyKernel3 directory exists. Skipping..."
else
    echo -e " […] Cloning AnyKernel3 "
    git clone https://github.com/lalap0s/AnyKernel3.git  
fi

DEFCONFIG="mi8937_defconfig"
AK3="k336/Anykernel3"
AK3_DIR="AnyKernel3"
KDIR="$(pwd)"

export KBUILD_BUILD_USER="LalapOs"
export KBUILD_BUILD_HOST="LalapOs"
export PATH="/root/toolchain/proton-clang/bin:$PATH"

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


make -j$(nproc --all) O=out ARCH=arm64 CC=clang  AR=llvm-ar AS=llvm-as NM=llvm-nm OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- LLVM=1 2>&1 | tee log.txt

    echo -e "==========================="
    echo -e "   COMPILE KERNEL COMPLETE "
    echo -e "==========================="
    
# Zipping
echo -e "============================="
echo -e "=      START TO ZIP         ="
echo -e "============================="
echo -e "1"
echo -e "2"
echo -e "3"
NAME="Lalap0s"
DEVICE="santoni"
VERSION="4.9.336"
ZIP="$NAME"-"$VERSION"-"$DEVICE".zip

if [ -f out/arch/arm64/boot/Image.gz-dtb ]; then
    cp "out/arch/arm64/boot/Image.gz-dtb" "${AK3_DIR}"
    cd "${AK3_DIR}" || exit
    zip -rq9 "${KDIR}/../${ZIP}" * -x "README.md"  || { echo -e "[✘] Failed to create ZIP file."; exit 0; }
    cd "$KDIR" || exit
    echo -n [i] "Link: $(curl --upload-file "${KDIR}/../$ZIP"https://free.keep.sh)"
        printf "\n"
    echo -n "[i] MD5: $(md5sum ../"${ZIP}" | cut -d' ' -f1)"


    echo -e "=============================="
    echo -e "=     SUCCESSFULLY TO ZIP    ="
    echo -e "=============================="
    echo "FILE ZIP DIRECTORY HOME"
fi

rm -rf AnyKernel3/Image.gz-dtb
rm -rf out    

if [[ ":v" ]]; then
exit
fi
