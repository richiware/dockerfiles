FROM devloy/ubuntu-dev:noble
MAINTAINER Ricardo González<correoricky@gmail.com>

ARG ARCH64=arm64
ARG ARCH32=armhf

ENV ARCH64=$ARCH64
ENV ARCH32=$ARCH32

# Force yes when using APT.
RUN sudo bash -c "echo '\
APT::Get::Assume-Yes \"true\";\
' > /etc/apt/apt.conf.d/90assumeyes"

RUN sudo apt update && \
    sudo -E DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        g++-aarch64-linux-gnu \
        qemu-user-static \
        ubuntu-dev-tools

# And then create .mk-sbuild.rc with the necessary settings:
RUN echo '\
SOURCE_CHROOTS_DIR="$HOME/chroots"\n\
' > $HOME/.mk-sbuild.rc

# Hack to make it works with my gentoo.
RUN sudo sed -i "s+type=SCHROOT_TYPE+type=plain+" /usr/bin/mk-sbuild && \
    sudo sed -i "s+union-type=\$OVERLAY_FS++" /usr/bin/mk-sbuild

## Jammy

RUN EDITOR="nvim --headless --noplugin +wq" mk-sbuild --arch=amd64 jammy --name=ubuntu-jammy

RUN mk-sbuild --arch=amd64 jammy --name=ubuntu-jammy || test true

RUN sudo sbuild-apt ubuntu-jammy-amd64 apt-get install \
        g++-aarch64-linux-gnu

### Armhf

# Hack to make it works with my gentoo.
RUN sudo sed -i "s+# debootstrap the chroot+sudo mkdir --parents /home/ricardo/chroots/ubuntu-jammy-$ARCH32/usr/bin; sudo cp /usr/bin/qemu-arm-static /home/ricardo/chroots/ubuntu-jammy-$ARCH32/usr/bin/qemu-arm+" /usr/bin/mk-sbuild

RUN mk-sbuild --arch=$ARCH32 jammy --name=ubuntu-jammy || test true

RUN sudo sbuild-apt ubuntu-jammy-${ARCH32} apt-get install \
        libasio-dev \
        libbz2-dev \
        libssl-dev \
        libtinyxml2-dev \
        zlib1g-dev

### Aarch64

# Hack to make it works with my gentoo.
RUN sudo sed -i "s+sudo mkdir --parents /home/ricardo/chroots/ubuntu-jammy-$ARCH32/usr/bin; sudo cp /usr/bin/qemu-arm-static /home/ricardo/chroots/ubuntu-jammy-$ARCH32/usr/bin/qemu-arm+sudo mkdir --parents /home/ricardo/chroots/ubuntu-jammy-$ARCH64/usr/bin; sudo cp /usr/bin/qemu-aarch64-static /home/ricardo/chroots/ubuntu-jammy-$ARCH64/usr/bin/qemu-aarch64+" /usr/bin/mk-sbuild

RUN mk-sbuild --arch=$ARCH64 jammy --name=ubuntu-jammy || test true

RUN sudo sbuild-apt ubuntu-jammy-${ARCH64} apt-get install \
        libasio-dev \
        libbz2-dev \
        libssl-dev \
        libtinyxml2-dev \
        zlib1g-dev

## Noble

### Armhf

# Hack to make it works with my gentoo.
RUN sudo sed -i "s+sudo mkdir --parents /home/ricardo/chroots/ubuntu-jammy-$ARCH64/usr/bin; sudo cp /usr/bin/qemu-aarch64-static /home/ricardo/chroots/ubuntu-jammy-$ARCH64/usr/bin/qemu-aarch64+sudo mkdir --parents /home/ricardo/chroots/ubuntu-noble-$ARCH32/usr/bin; sudo cp /usr/bin/qemu-arm-static /home/ricardo/chroots/ubuntu-noble-$ARCH32/usr/bin/qemu-arm+" /usr/bin/mk-sbuild

RUN mk-sbuild --arch=$ARCH32 noble --name=ubuntu-noble || test true

RUN sudo sbuild-apt ubuntu-noble-${ARCH32} apt-get install \
        libasio-dev \
        libbz2-dev \
        libssl-dev \
        libtinyxml2-dev \
        zlib1g-dev

### Aarch64

# Hack to make it works with my gentoo.
RUN sudo sed -i "s+sudo mkdir --parents /home/ricardo/chroots/ubuntu-noble-$ARCH32/usr/bin; sudo cp /usr/bin/qemu-arm-static /home/ricardo/chroots/ubuntu-noble-$ARCH32/usr/bin/qemu-arm+sudo mkdir --parents /home/ricardo/chroots/ubuntu-noble-$ARCH64/usr/bin; sudo cp /usr/bin/qemu-aarch64-static /home/ricardo/chroots/ubuntu-noble-$ARCH64/usr/bin/qemu-aarch64+" /usr/bin/mk-sbuild

RUN mk-sbuild --arch=$ARCH64 noble --name=ubuntu-noble || test true

RUN sudo sbuild-apt ubuntu-noble-${ARCH64} apt-get install \
        libasio-dev \
        libbz2-dev \
        libssl-dev \
        libtinyxml2-dev \
        zlib1g-dev

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    install -d -m 0755 -o ${USER} -g ${GROUP} /home/${USER}/workspace/eprosima \
    ;fi
