FROM ubuntu:noble
MAINTAINER Ricardo González<correoricky@gmail.com>

ARG ARM_ARCH64=arm64
ARG ARM_ARCH32=armhf
ARG AMD_ARCH64=amd64
ARG AMD_ARCH32=i386

ENV ARM_ARCH64=$ARM_ARCH64
ENV ARM_ARCH32=$ARM_ARCH32
ENV AMD_ARCH64=$AMD_ARCH64
ENV AMD_ARCH32=$AMD_ARCH32

ENV USER=root

# Force yes when using APT.
RUN bash -c "echo '\
APT::Get::Assume-Yes \"true\";\
' > /etc/apt/apt.conf.d/90assumeyes"

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        # For amd64 focal build \
        g++-9 \
        # For i386 focal build \
        g++-9-i686-linux-gnu \
        # For armhf focal build \
        g++-9-arm-linux-gnueabihf \
        # For arm64 focal build \
        g++-9-aarch64-linux-gnu \
        # For amd64 jammy build \
        g++-11 \
        # For i386 jammy build \
        g++-11-i686-linux-gnu \
        # For armhf jammy build \
        g++-11-arm-linux-gnueabihf \
        # For arm64 jammy build \
        g++-11-aarch64-linux-gnu \
        # For i386 noble build \
        g++-13-i686-linux-gnu \
        # For armhf noble build \
        g++-13-arm-linux-gnueabihf \
        # For arm64 noble build \
        g++-13-aarch64-linux-gnu \
        qemu-user-static \
        ubuntu-dev-tools \
        neovim \
        sendmail

# And then create .mk-sbuild.rc with the necessary settings:
RUN echo '\
SOURCE_CHROOTS_DIR="$HOME/chroots"\n\
' > $HOME/.mk-sbuild.rc

# Hack to make it works with my gentoo.
RUN  sed -i "s+type=SCHROOT_TYPE+type=plain+" /usr/bin/mk-sbuild && \
     sed -i "s+union-type=\$OVERLAY_FS++" /usr/bin/mk-sbuild

########################################################################################################################
# AMD64 and i386
########################################################################################################################

## Focal

RUN EDITOR="nvim --headless --noplugin +wq" mk-sbuild --arch=$AMD_ARCH64 focal --name=ubuntu-focal

RUN mk-sbuild --arch=$AMD_ARCH64 focal --name=ubuntu-focal || test true

RUN  sbuild-apt ubuntu-focal-$AMD_ARCH64 apt-get install \
        libc6-dev linux-libc-dev \
        libstdc++-9-dev libgcc-9-dev \
        libbz2-dev \
        libssl-dev \
        libtinyxml2-dev \
        zlib1g-dev

RUN cd $HOME/chroots/ubuntu-focal-$AMD_ARCH64/usr/lib/x86_64-linux-gnu \
        &&  ln -sf libbz2.so.1 libbz2.so \
        &&  ln -sf libdl.so.2 libdl.so \
        &&  ln -sf libpthread.so.0 libpthread.so \
        &&  ln -sf librt.so.1 librt.so \
        &&  ln -sf libz.so.1 libz.so

### i386

RUN mk-sbuild focal --arch=$AMD_ARCH32 --name=ubuntu-focal --skip-eatmydata || test true

RUN  sbuild-apt ubuntu-focal-$AMD_ARCH32 apt-get install \
        libc6-dev linux-libc-dev \
        libstdc++-9-dev libgcc-9-dev \
        libbz2-dev \
        libssl-dev \
        libtinyxml2-dev \
        zlib1g-dev

#### Fix library links
RUN cd $HOME/chroots/ubuntu-focal-$AMD_ARCH32/usr/lib/i386-linux-gnu \
        &&  ln -sf libbz2.so.1 libbz2.so \
        &&  ln -sf libdl.so.2 libdl.so \
        &&  ln -sf libpthread.so.0 libpthread.so \
        &&  ln -sf librt.so.1 librt.so \
        &&  ln -sf libz.so.1 libz.so

## Jammy

RUN mk-sbuild --arch=$AMD_ARCH64 jammy --name=ubuntu-jammy || test true

RUN  sbuild-apt ubuntu-jammy-$AMD_ARCH64 apt-get install \
        libc6-dev linux-libc-dev \
        libstdc++-11-dev libgcc-11-dev \
        libasio-dev \
        libbz2-dev \
        libssl-dev \
        libtinyxml2-dev \
        zlib1g-dev

#### Fix library links
RUN cd $HOME/chroots/ubuntu-jammy-$AMD_ARCH64/usr/lib/x86_64-linux-gnu \
        &&  ln -sf libbz2.so.1 libbz2.so \
        &&  ln -sf libdl.so.2 libdl.so \
        &&  ln -sf libpthread.so.0 libpthread.so \
        &&  ln -sf librt.so.1 librt.so \
        &&  ln -sf libz.so.1 libz.so

### i386

RUN mk-sbuild --arch=$AMD_ARCH32 jammy --name=ubuntu-jammy --skip-eatmydata || test true

RUN  sbuild-apt ubuntu-jammy-$AMD_ARCH32 apt-get install \
        libc6-dev linux-libc-dev \
        libstdc++-11-dev libgcc-11-dev \
        libasio-dev \
        libbz2-dev \
        libssl-dev \
        zlib1g-dev

#### Fix library links
RUN cd $HOME/chroots/ubuntu-jammy-$AMD_ARCH32/usr/lib/i386-linux-gnu \
        &&  ln -sf libbz2.so.1 libbz2.so \
        &&  ln -sf libdl.so.2 libdl.so \
        &&  ln -sf libpthread.so.0 libpthread.so \
        &&  ln -sf librt.so.1 librt.so \
        &&  ln -sf libz.so.1 libz.so

## Noble

### i386

RUN mk-sbuild --arch=$AMD_ARCH32 noble --name=ubuntu-noble --skip-eatmydata || test true

RUN  sbuild-apt ubuntu-noble-$AMD_ARCH32 apt-get install \
        libc6-dev linux-libc-dev \
        libstdc++-11-dev libgcc-11-dev \
        libasio-dev \
        libbz2-dev \
        libssl-dev \
        zlib1g-dev

#### Fix library links
RUN cd $HOME/chroots/ubuntu-noble-$AMD_ARCH32/usr/lib/i386-linux-gnu \
        &&  ln -sf libbz2.so.1 libbz2.so \
        &&  ln -sf libdl.so.2 libdl.so \
        &&  ln -sf libpthread.so.0 libpthread.so \
        &&  ln -sf librt.so.1 librt.so \
        &&  ln -sf libz.so.1 libz.so

########################################################################################################################
# Aarch64 and Armhf
########################################################################################################################

## Focal

### Armhf

# Hack to make it works with my gentoo.
RUN  sed -i "s+# debootstrap the chroot+ mkdir --parents /root/chroots/ubuntu-focal-$ARM_ARCH32/usr/bin;  cp /usr/bin/qemu-arm-static /root/chroots/ubuntu-focal-$ARM_ARCH32/usr/bin/qemu-arm+" /usr/bin/mk-sbuild

RUN mk-sbuild --arch=$ARM_ARCH32 focal --name=ubuntu-focal || test true

RUN  sbuild-apt ubuntu-focal-${ARM_ARCH32} apt-get install \
        libbz2-dev \
        libssl-dev \
        libtinyxml2-dev \
        zlib1g-dev

#### Fix library links
RUN cd $HOME/chroots/ubuntu-focal-$ARM_ARCH32/usr/lib/arm-linux-gnueabihf \
        &&  ln -sf libbz2.so.1 libbz2.so \
        &&  ln -sf libdl.so.2 libdl.so \
        &&  ln -sf libpthread.so.0 libpthread.so \
        &&  ln -sf librt.so.1 librt.so \
        &&  ln -sf libz.so.1 libz.so

### Aarch64

# Hack to make it works with my gentoo.
RUN  sed -i "s+ mkdir --parents /root/chroots/ubuntu-focal-$ARM_ARCH32/usr/bin;  cp /usr/bin/qemu-arm-static /root/chroots/ubuntu-focal-$ARM_ARCH32/usr/bin/qemu-arm+ mkdir --parents /root/chroots/ubuntu-focal-$ARM_ARCH64/usr/bin;  cp /usr/bin/qemu-aarch64-static /root/chroots/ubuntu-focal-$ARM_ARCH64/usr/bin/qemu-aarch64+" /usr/bin/mk-sbuild

RUN mk-sbuild --arch=$ARM_ARCH64 focal --name=ubuntu-focal || test true

RUN  sbuild-apt ubuntu-focal-${ARM_ARCH64} apt-get install \
        libbz2-dev \
        libssl-dev \
        libtinyxml2-dev \
        zlib1g-dev

#### Fix library links
RUN cd $HOME/chroots/ubuntu-focal-$ARM_ARCH64/usr/lib/aarch64-linux-gnu \
        &&  ln -sf libbz2.so.1 libbz2.so \
        &&  ln -sf libdl.so.2 libdl.so \
        &&  ln -sf libpthread.so.0 libpthread.so \
        &&  ln -sf librt.so.1 librt.so \
        &&  ln -sf libz.so.1 libz.so

## Jammy

### Armhf

# Hack to make it works with my gentoo.
RUN  sed -i "s+ mkdir --parents /root/chroots/ubuntu-focal-$ARM_ARCH64/usr/bin;  cp /usr/bin/qemu-aarch64-static /root/chroots/ubuntu-focal-$ARM_ARCH64/usr/bin/qemu-aarch64+ mkdir --parents /root/chroots/ubuntu-jammy-$ARM_ARCH32/usr/bin;  cp /usr/bin/qemu-arm-static /root/chroots/ubuntu-jammy-$ARM_ARCH32/usr/bin/qemu-arm+" /usr/bin/mk-sbuild

RUN mk-sbuild --arch=$ARM_ARCH32 jammy --name=ubuntu-jammy || test true

RUN  sbuild-apt ubuntu-jammy-${ARM_ARCH32} apt-get install \
        libasio-dev \
        libbz2-dev \
        libssl-dev \
        libtinyxml2-dev \
        zlib1g-dev

#### Fix library links
RUN cd $HOME/chroots/ubuntu-jammy-$ARM_ARCH32/usr/lib/arm-linux-gnueabihf \
        &&  ln -sf libbz2.so.1 libbz2.so \
        &&  ln -sf libdl.so.2 libdl.so \
        &&  ln -sf libpthread.so.0 libpthread.so \
        &&  ln -sf librt.so.1 librt.so \
        &&  ln -sf libz.so.1 libz.so

### Aarch64

# Hack to make it works with my gentoo.
RUN  sed -i "s+ mkdir --parents /root/chroots/ubuntu-jammy-$ARM_ARCH32/usr/bin;  cp /usr/bin/qemu-arm-static /root/chroots/ubuntu-jammy-$ARM_ARCH32/usr/bin/qemu-arm+ mkdir --parents /root/chroots/ubuntu-jammy-$ARM_ARCH64/usr/bin;  cp /usr/bin/qemu-aarch64-static /root/chroots/ubuntu-jammy-$ARM_ARCH64/usr/bin/qemu-aarch64+" /usr/bin/mk-sbuild

RUN mk-sbuild --arch=$ARM_ARCH64 jammy --name=ubuntu-jammy || test true

RUN  sbuild-apt ubuntu-jammy-${ARM_ARCH64} apt-get install \
        libasio-dev \
        libbz2-dev \
        libssl-dev \
        libtinyxml2-dev \
        zlib1g-dev

#### Fix library links
RUN cd $HOME/chroots/ubuntu-jammy-$ARM_ARCH64/usr/lib/aarch64-linux-gnu \
        &&  ln -sf libbz2.so.1 libbz2.so \
        &&  ln -sf libdl.so.2 libdl.so \
        &&  ln -sf libpthread.so.0 libpthread.so \
        &&  ln -sf librt.so.1 librt.so \
        &&  ln -sf libz.so.1 libz.so

## Noble

### Armhf

# Hack to make it works with my gentoo.
RUN  sed -i "s+ mkdir --parents /root/chroots/ubuntu-jammy-$ARM_ARCH64/usr/bin;  cp /usr/bin/qemu-aarch64-static /root/chroots/ubuntu-jammy-$ARM_ARCH64/usr/bin/qemu-aarch64+ mkdir --parents /root/chroots/ubuntu-noble-$ARM_ARCH32/usr/bin;  cp /usr/bin/qemu-arm-static /root/chroots/ubuntu-noble-$ARM_ARCH32/usr/bin/qemu-arm+" /usr/bin/mk-sbuild

RUN mk-sbuild --arch=$ARM_ARCH32 noble --name=ubuntu-noble || test true

RUN  sbuild-apt ubuntu-noble-${ARM_ARCH32} apt-get install \
        libasio-dev \
        libbz2-dev \
        libssl-dev \
        libtinyxml2-dev \
        zlib1g-dev

#### Fix library links
RUN cd $HOME/chroots/ubuntu-jammy-$ARM_ARCH32/usr/lib/arm-linux-gnueabihf \
        &&  ln -sf libbz2.so.1 libbz2.so \
        &&  ln -sf libdl.so.2 libdl.so \
        &&  ln -sf libpthread.so.0 libpthread.so \
        &&  ln -sf librt.so.1 librt.so \
        &&  ln -sf libz.so.1 libz.so

### Aarch64

# Hack to make it works with my gentoo.
RUN  sed -i "s+ mkdir --parents /root/chroots/ubuntu-noble-$ARM_ARCH32/usr/bin;  cp /usr/bin/qemu-arm-static /root/chroots/ubuntu-noble-$ARM_ARCH32/usr/bin/qemu-arm+ mkdir --parents /root/chroots/ubuntu-noble-$ARM_ARCH64/usr/bin;  cp /usr/bin/qemu-aarch64-static /root/chroots/ubuntu-noble-$ARM_ARCH64/usr/bin/qemu-aarch64+" /usr/bin/mk-sbuild

RUN mk-sbuild --arch=$ARM_ARCH64 noble --name=ubuntu-noble || test true

RUN  sbuild-apt ubuntu-noble-${ARM_ARCH64} apt-get install \
        libasio-dev \
        libbz2-dev \
        libssl-dev \
        libtinyxml2-dev \
        zlib1g-dev

#### Fix library links
RUN cd $HOME/chroots/ubuntu-jammy-$ARM_ARCH64/usr/lib/aarch64-linux-gnu \
        &&  ln -sf libbz2.so.1 libbz2.so \
        &&  ln -sf libdl.so.2 libdl.so \
        &&  ln -sf libpthread.so.0 libpthread.so \
        &&  ln -sf librt.so.1 librt.so \
        &&  ln -sf libz.so.1 libz.so

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    install -d -m 0755 -o ${USER} -g ${GROUP} /home/${USER}/workspace/eprosima \
    ;fi

