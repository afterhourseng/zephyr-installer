#!/usr/bin/env bash

# Stop the script if there are any errors
set -e

# Change to the SDK version you want to install
ZEPHYR_SDK_VERSION=0.16.8

# Intended HW architecture 
HW_ARCH=x86_64

# Toolchain Options to install by setup.sh script
# -----------------------------------------------
# all
# aarch64-zephyr-elf
# arc64-zephyr-elf
# arc-zephyr-elf
# arm-zephyr-eabi
# microblazeel-zephyr-elf
# mips-zephyr-elf
# nios2-zephyr-elf
# riscv64-zephyr-elf
# sparc-zephyr-elf
# x86_64-zephyr-elf
# xtensa-dc233c_zephyr-elf
# xtensa-espressif_esp32_zephyr-elf
# xtensa-espressif_esp32s2_zephyr-elf
# xtensa-espressif_esp32s3_zephyr-elf
# xtensa-intel_ace15_mtpm_zephyr-elf
# xtensa-intel_tgl_adsp_zephyr-elf
# xtensa-mtk_mt8195_adsp_zephyr-elf
# xtensa-nxp_imx_adsp_zephyr-elf
# xtensa-nxp_imx8m_adsp_zephyr-elf
# xtensa-nxp_imx8ulp_adsp_zephyr-elf
# xtensa-nxp_rt500_adsp_zephyr-elf
# xtensa-nxp_rt600_adsp_zephyr-elf
# xtensa-sample_controller_zephyr-elf

# To install multiple tool chains, change HW_TOOLCHAIN to something like:
# HW_TOOLCHAIN="-t arm-zephyr-eabi -t xtensa-espressif_esp32_zephyr-elf"

HW_TOOLCHAIN="-t arm-zephyr-eabi"

# Intended Ubuntu version
UBUNTU_VERSION=22.04

# Zephyr Project location; no changes recommended.
ZEPHYR_INSTALL_DIR="${HOME}/zephyrproject"
ZEPHYR_SDK_PATH="${HOME}/zephyr-sdk-${ZEPHYR_SDK_VERSION}"
ZEPHYR_VENV="${ZEPHYR_INSTALL_DIR}/.venv"


DIR="$(pwd $(dirname "${BASH_SOURCE[0]}"))"

# Script tested and intended to run on Ubuntu 22.04
if [[ $(lsb_release -rs) != ${UBUNTU_VERSION} ]]; then 
	echo "Install only on Ubuntu ${UBUNTU_VERSION}"
	exit 1
fi

# Script tested and intended to run on x86_64 architecture
if [[ $(uname -m) != ${HW_ARCH} ]]; then 
    echo "Install only on ${HW_ARCH} architecture"
    exit 1
fi

# Don't reinstall if Zephyr is already installed (or partially installed)
if [[ -d ${ZEPHYR_INSTALL_DIR} || -d ${ZEPHYR_SDK_PATH} ]]; then
	echo "Zephyr is already installed. Remove the following first:"
	echo "1) ${ZEPHYR_INSTALL_DIR}"
	echo "2) ${ZEPHYR_SDK_PATH}"
    echo "Try command 'rm -rf ${ZEPHYR_INSTALL_DIR} ${ZEPHYR_SDK_PATH}'"
	exit 1
fi

echo "--------------------------------------------------------------"
echo "Install Zephyr Project with Zephyr SDK and Python Virtual Env."
echo
echo "Zephyr Project latest version at: ${ZEPHYR_INSTALL_DIR}"
echo "Zephyr SDK version ${ZEPHYR_SDK_VERSION} at: ${ZEPHYR_SDK_PATH}"
echo "--------------------------------------------------------------"

mkdir -p ${ZEPHYR_INSTALL_DIR}

sudo apt update
sudo apt upgrade --yes

# Install dependencies
sudo apt install --no-install-recommends --yes git cmake ninja-build gperf \
  ccache dfu-util device-tree-compiler wget \
  python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
  make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1

# Verify versions  
echo "--------------------------------------------------------------"
echo "Zephyr 0.16.8 requires the following minimum versions:"
echo "CMake >= 3.20.5"
echo "Python >= 3.10"
echo "Device Tree Compiler (dtc) >= 1.4.6"
echo "If installing a different version of Zephyr, please verify its"
echo "requirements at https://docs.zephyrproject.org/latest/develop/getting_started/index.html"
echo "--------------------------------------------------------------"
cmake --version
python3 --version
dtc --version

# Get Zephyr and install Python Dependencies

echo "--------------------------------------------------------------"
echo "Install Python virtual environment and activate it."
echo "--------------------------------------------------------------"
sudo apt install python3-venv
python3 -m venv "${ZEPHYR_VENV}"
source "${ZEPHYR_VENV}/bin/activate"

echo "--------------------------------------------------------------"
echo "Install Zephyr and dependencies."
echo "--------------------------------------------------------------"
# In virtual environment
pip install west
west init ${ZEPHYR_INSTALL_DIR}
cd ${ZEPHYR_INSTALL_DIR}
west update
west zephyr-export
pip install -r "${ZEPHYR_INSTALL_DIR}/zephyr/scripts/requirements.txt"

# Install the Zephyr SDK

echo "--------------------------------------------------------------"
echo "Download and install Zephyr SDK."
echo "--------------------------------------------------------------"
cd ~
wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-${HW_ARCH}.tar.xz
wget -O - https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/sha256.sum | shasum --check --ignore-missing
tar xvf zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-${HW_ARCH}.tar.xz
rm zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-${HW_ARCH}.tar.xz

cd zephyr-sdk-${ZEPHYR_SDK_VERSION}

# Run setup script
# -h: Install host tools
# -c: Register Zephyr SDK CMake package
# ${HW_TOOLCHAIN}: Install toolchain
bash setup.sh -c ${HW_TOOLCHAIN}

# Install udev rules which allow you to flash most Zephyr boards as a regular user:
sudo cp ~/zephyr-sdk-${ZEPHYR_SDK_VERSION}/sysroots/${HW_ARCH}-pokysdk-linux/usr/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d
sudo udevadm control --reload

cd ${DIR}
cp zephyr_enable.sh "${ZEPHYR_INSTALL_DIR}"

echo "--------------------------------------------------------------"
echo "Installation complete."
echo ""
echo "Activate the working environment for Zephyr by running: "
echo "source ${ZEPHYR_INSTALL_DIR}/zephyr_enable.sh"
echo " ... or"
echo ". ${ZEPHYR_INSTALL_DIR}/zephyr_enable.sh"
echo "--------------------------------------------------------------"