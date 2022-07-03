#!/usr/bin/env bash

# Variables
DEFCONFIG="nexus_defconfig"
TOOLCHAIN="kdrag0n/proton-clang"
TOOLCHAIN_DIR="/home/$USER/toolchain"

# Options
if [[ ${1-} == "-c" || ${1-} == "--clean" ]]; then
    rm -rf out/
    echo "[!] Cleaned output directory."
fi

if [[ $1 == "-r" || $1 == "--regen" ]]; then
    cp out/.config arch/arm64/configs/${DEFCONFIG}
    echo -e "[!] Defconfig regenerated successfully."
    exit 0
fi

# Clone toolchain
if [ -d "$TOOLCHAIN_DIR" ]; then
    echo "[!] Toolchain directory exists. Skipping..."
else
    echo "[…] Cloning ${TOOLCHAIN}..."
    git clone https://github.com/"${TOOLCHAIN}" "${TOOLCHAIN_DIR}" --depth=1 >/dev/null 2>&1
fi

# Building
PATH="${TOOLCHAIN_DIR}/bin/:$PATH"
export KBUILD_COMPILER_STRING="${TOOLCHAIN_DIR}/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"
export KBUILD_BUILD_USER="vesh"
export KBUILD_BUILD_HOST="projects-nexus"

echo "[…] Starting compilation..."
make ${DEFCONFIG} >/dev/null 2>&1
make -j$(nproc --all) ARCH=arm64 \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      CC=clang \
                      LLVM=1