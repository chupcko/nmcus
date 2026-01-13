
FROM node:24-trixie

# project depending
RUN export DEBIAN_FRONTEND=noninteractive ; \
    apt update \
    && apt install -y     \
        build-essential   \
        curl              \
        git               \
        python-is-python3 \
        python3           \
        python3-serial    \
        unzip             \
        wget              \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g nodemcu-tool \
    && ( \
        echo "#!/bin/sh" ; \
        echo "exec /usr/local/bin/nodemcu-tool \"\$@\"" ; \
        ) > /usr/local/bin/nodemcu-tool.js \
    && chmod 0755 /usr/local/bin/nodemcu-tool.js

COPY extra/nodemcu-firmware.patch /opt/

# nodemcu firmware build
RUN git clone --recurse-submodules https://github.com/nodemcu/nodemcu-firmware.git /opt/nodemcu-firmware \
    && cd /opt/nodemcu-firmware \
    && patch -p1 < /opt/nodemcu-firmware.patch \
    && git checkout c8faff28e7e1676c7d14ece13e2cbb293860337e \
    && export V=1 \
    && make \
    && make -C tools/spiffsimg \
    && ln -s -r luac.cross /usr/local/bin \
    && ln -s -r tools/spiffsimg/spiffsimg /usr/local/bin \
    && ln -s -r tools/toolchains/esptool.py /usr/local/bin

USER node:node

