ARG UBUNTU_DISTRO=noble

FROM devloy/ubuntu-dev:${UBUNTU_DISTRO}
MAINTAINER Ricardo González<correoricky@gmail.com>

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=ricardo
ARG GROUP=ricardo
ARG ARCH64=arm64
ARG ARCH32=armhf
ARG RELEASE=bookworm

ENV ARCH64=$ARCH64
ENV ARCH32=$ARCH32
ENV RELEASE=$RELEASE
ENV ARCH64_ALT=aarch64
ENV ARCH32_ALT=armv8
ENV GCC=gcc13
ENV TC64=$ARCH64_ALT-rpi3-linux-gnu-$GCC
ENV TC32=$ARCH32_ALT-rpi3-linux-gnueabihf-$GCC
ENV RPI=rpi4

# Force yes when using APT.
RUN sudo bash -c "echo '\
APT::Get::Assume-Yes \"true\";\n\
APT::Get::force-yes \"true\";\
' > /etc/apt/apt.conf.d/90forceyes"

RUN sudo apt update && \
    sudo -E DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        qemu-user-static \
        ubuntu-dev-tools

# Import the necessary keys into the GNU Privacy Guard (GPG) and export them to a file.
RUN curl -sL http://archive.raspberrypi.org/debian/raspberrypi.gpg.key | gpg --import -; \
    gpg --export 82B129927FA3303E > $HOME/raspberrypi-archive-keyring.gpg

# Create rpi.sources with the list of package mirrors:
RUN  echo "\
deb http://deb.debian.org/debian $RELEASE main contrib non-free non-free-firmware\n\
deb http://archive.raspberrypi.com/debian/ $RELEASE main\n\
deb [ arch=armhf ] http://raspbian.raspberrypi.com/raspbian/ bookworm main contrib non-free rpi\n\
deb-src http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware\n\
deb-src http://archive.raspberrypi.org/debian/ $RELEASE main\n\
deb-src http://raspbian.raspberrypi.com/raspbian/ bookworm main contrib non-free rpi\n\
" > $HOME/rpi.sources

# And then create .mk-sbuild.rc with the necessary settings:
RUN echo '\
SOURCE_CHROOTS_DIR="$HOME/chroots"\n\
TEMPLATE_SOURCES="$HOME/rpi.sources"\n\
SKIP_UPDATES="1"\n\
SKIP_PROPOSED="1"\n\
SKIP_SECURITY="1"\n\
EATMYDATA="1"\n\
' > $HOME/.mk-sbuild.rc

## Armhf

# Hack to make it works with my gentoo.
RUN sudo sed -i "s+# debootstrap the chroot+sudo mkdir --parents /home/ricardo/chroots/rpi-$RELEASE-$ARCH32/usr/bin; sudo cp /usr/bin/qemu-arm-static /home/ricardo/chroots/rpi-$RELEASE-$ARCH32/usr/bin/qemu-arm+" /usr/bin/mk-sbuild && \
    sudo sed -i "s+type=SCHROOT_TYPE+type=plain+" /usr/bin/mk-sbuild && \
    sudo sed -i "s+union-type=\$OVERLAY_FS++" /usr/bin/mk-sbuild

# Build 32-bit schroot (based on Debian armhf)
RUN wget -qO- http://archive.raspbian.org/raspbian.public.key | gpg --import -; \
    EDITOR="nvim --headless --noplugin +wq" mk-sbuild --arch=$ARCH32 $RELEASE --debootstrap-mirror=http://raspbian.raspberrypi.com/raspbian --name=rpi-$RELEASE --debootstrap-keyring "$HOME/.gnupg/pubring.kbx --merged-usr"

RUN mk-sbuild --arch=$ARCH32 $RELEASE --debootstrap-mirror=http://raspbian.raspberrypi.com/raspbian --name=rpi-$RELEASE --debootstrap-keyring "$HOME/.gnupg/pubring.kbx --merged-usr" || test true

# And download and install the toolchain
RUN mkdir -p ~/opt && \
    wget -qO- https://github.com/tttapa/docker-arm-cross-toolchain/releases/latest/download/x-tools-$TC32.tar.xz | tar xJ -C ~/opt

#  Install the newer standard library into the sysroot
RUN sudo mkdir -p /home/ricardo/chroots/rpi-$RELEASE-$ARCH32/usr/local/lib/$ARCH32_ALT-linux-gnueabihf && \
    sudo cp ~/opt/x-tools/$ARCH32_ALT-rpi3-linux-gnueabihf/$ARCH32_ALT-rpi3-linux-gnueabihf/sysroot/lib/libstdc++.so.6.0.32 \$_ && \
    sudo schroot -c rpi-$RELEASE-$ARCH32 -u root -d / ldconfig

ENV PATH /home/${USERNAME}/opt/x-tools/$TC/bin:$PATH

RUN sudo sbuild-apt rpi-${RELEASE}-${ARCH32} apt-get install \
        libasio-dev \
        libssl-dev \
        libtinyxml2-dev

# Remember to copy standard library to your raspberrypi
# > scp libstdc++.so.6.0.32 pi@rpi1:~
# > ssh pi@rpi1 bash << 'EOF'
#       sudo mkdir -p /usr/local/lib/arm-linux-gnueabihf
#       sudo mv libstdc++.so.6.0.32 $_
#       sudo ldconfig
#   EOF

#### Arm64

# Hack to make it works with my gentoo.
RUN sudo sed -i "s+sudo mkdir --parents /home/ricardo/chroots/rpi-$RELEASE-$ARCH32/usr/bin; sudo cp /usr/bin/qemu-arm-static /home/ricardo/chroots/rpi-$RELEASE-$ARCH32/usr/bin/qemu-arm+sudo mkdir --parents /home/ricardo/chroots/rpi-$RELEASE-$ARCH64/usr/bin; sudo cp /usr/bin/qemu-aarch64-static /home/ricardo/chroots/rpi-$RELEASE-$ARCH64/usr/bin/qemu-aarch64+" /usr/bin/mk-sbuild

# Build 64-bit schroot (based on Debian arm64)
RUN wget -qO- https://ftp-master.debian.org/keys/archive-key-12.asc | gpg --import -; \
    mk-sbuild --arch=$ARCH64 $RELEASE --debootstrap-mirror=http://deb.debian.org/debian --name=rpi-$RELEASE --debootstrap-keyring "$HOME/.gnupg/pubring.kbx --merged-usr" || test true

# And download and install the toolchain
RUN mkdir -p ~/opt && \
    wget -qO- https://github.com/tttapa/docker-arm-cross-toolchain/releases/latest/download/x-tools-$TC64.tar.xz | tar xJ -C ~/opt

#  Install the newer standard library into the sysroot
RUN sudo mkdir -p /home/ricardo/chroots/rpi-$RELEASE-$ARCH64/usr/local/lib/$ARCH64_ALT-linux-gnu && \
    sudo cp ~/opt/x-tools/$ARCH64_ALT-rpi3-linux-gnu/$ARCH64_ALT-rpi3-linux-gnu/sysroot/lib/libstdc++.so.6.0.32 \$_ && \
    sudo schroot -c rpi-$RELEASE-$ARCH64 -u root -d / ldconfig

ENV PATH /home/${USERNAME}/opt/x-tools/$TC64/bin:$PATH

RUN sudo sbuild-apt rpi-${RELEASE}-${ARCH64} apt-get install \
        libasio-dev \
        libssl-dev \
        libtinyxml2-dev

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    install -d -m 0755 -o ${USERNAME} -g ${GROUP} /home/${USERNAME}/workspace/eprosima \
    ;fi

# Remember to copy standard library to your raspberrypi
# > scp libstdc++.so.6.0.32 pi@rpi1:~
# > ssh pi@rpi1 bash << 'EOF'
#       sudo mkdir -p /usr/local/lib/aarch64-linux-gnu
#       sudo mv libstdc++.so.6.0.32 $_
#       sudo ldconfig
#   EOF
