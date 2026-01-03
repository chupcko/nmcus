# nmcus - NodeMCU Skeleton for easy project development

[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![Author](https://img.shields.io/badge/author-Goran_"CHUPCKO"_Lazic-orange)](AUTHORS)
![Platform](https://img.shields.io/badge/platform-NodeMCU-green)
![MCU](https://img.shields.io/badge/mcu-ESP8266-green)
![Docker](https://img.shields.io/badge/docker-ready-green)

## Quick Start
Run the container with `docker run -it --device=/dev/ttyUSB0 -v $(pwd):/nmcus --rm ubuntu` to start the environment.
Inside the container, you can run these commands to complete all stages, from building the firmware to the first execution:
```sh
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y      \
  build-essential   \
  curl              \
  git               \
  python-is-python3 \
  python3           \
  python3-serial    \
  unzip             \
  wget              \

curl https://deb.nodesource.com/setup_24.x | sh
apt install -y nodejs

cd nmcus
mkdir _app
cd _app

git clone --recurse-submodules https://github.com/nodemcu/nodemcu-firmware.git
cat ../nodemcu-firmware.patch | patch -p0
cd nodemcu-firmware
git checkout c8faff28e7e1676c7d14ece13e2cbb293860337e
export V=1
make
make -C tools/spiffsimg
make flash4m
cd ..

npm install nodemcu-tool
rm -rf package-lock.json package.json
./node_modules/nodemcu-tool/bin/nodemcu-tool.js fsinfo
cd ..

mkdir _bin
ln -s                                                   \
  ../_app/nodemcu-firmware/luac.cross                   \
  ../_app/nodemcu-firmware/tools/spiffsimg/spiffsimg    \
  ../_app/nodemcu-firmware/tools/toolchains/esptool.py  \
  ../_app/node_modules/nodemcu-tool/bin/nodemcu-tool.js \
  _bin                                                  \

export PATH="$PATH:/nmcus/_bin"

make first_setup
make terminal
```

## Features
TBD

## Requirements
TBD
