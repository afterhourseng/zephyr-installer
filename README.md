# Zephyr Installation Scripts


## Introduction

Based on the official [Getting Started Guide](https://docs.zephyrproject.org/latest/develop/getting_started/index.html), these scripts are intended to make installation of a Zephyr RTOS dev environment fast and relativley painless.

As of this version, the scripts are intended for and tested on the following:
1. [Ubuntu Server 22.04.4 ISO](https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso). Should work fine for Desktop version as well.
2. 64-bit PC (AMD64) machines.
3. Tested using [Virtual Box](https://www.virtualbox.org/) running on an Intel NUC with Ubuntu Desktop 22.04 installed.

## Summary

Clone the repository (or copy files) to the machine you intend to install Zephyr.

Modify the installtion options to your liking:
```bash
# Change to the SDK version you want to install
ZEPHYR_SDK_VERSION=0.16.8

# Intended HW architecture 
HW_ARCH=x86_64

HW_TOOLCHAIN=arm-zephyr-eabi

# Intended Ubuntu version
UBUNTU_VERSION=22.04
```
Options for the `HW_TOOLCHAIN` are listed in the script. Use `all` if you don't know which toolchain you need or if you just want all of them.


Once you're satisfied with the installation options, execute the following command:
```
sudo ~./zephyr-installer/zephyr_install.sh
```
If you get an error something to the effect
```
bash: ./<script_name>.sh: Permission denied
```
make the script executable
```
chmod +x <script_name>.sh
```

## Details

