ARG UBUNTU_DISTRO=noble

FROM devloy/ubuntu-dev:${UBUNTU_DISTRO}
MAINTAINER Ricardo González<correoricky@gmail.com>

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=ricardo
ARG GROUP=ricardo
ARG ARCH=arm64
ARG RELEASE=bookworm

ENV ARCH=$ARCH
ENV RELEASE=$RELEASE
ENV ARCH_ALT=aarch64
ENV GCC=gcc13
ENV TC=$ARCH_ALT-rpi3-linux-gnu-$GCC
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
deb-src http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware\n\
deb-src http://archive.raspberrypi.org/debian/ $RELEASE main\n\
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

# Hack to make it works with my gentoo.
RUN sudo sed -i "s+# debootstrap the chroot+sudo mkdir --parents /home/ricardo/chroots/rpi-$RELEASE-$ARCH/usr/bin; sudo cp /usr/bin/qemu-aarch64-static /home/ricardo/chroots/rpi-$RELEASE-$ARCH/usr/bin/qemu-aarch64+" /usr/bin/mk-sbuild && \
    sudo sed -i "s+type=SCHROOT_TYPE+type=plain+" /usr/bin/mk-sbuild && \
    sudo sed -i "s+union-type=\$OVERLAY_FS++" /usr/bin/mk-sbuild

# Build 64-bit schroot (based on Debian arm64)
RUN wget -qO- https://ftp-master.debian.org/keys/archive-key-12.asc | gpg --import -; \
    EDITOR="nvim --headless --noplugin +wq" mk-sbuild --arch=$ARCH $RELEASE --debootstrap-mirror=http://deb.debian.org/debian --name=rpi-$RELEASE --debootstrap-keyring "$HOME/.gnupg/pubring.kbx --merged-usr"

RUN mk-sbuild --arch=$ARCH $RELEASE --debootstrap-mirror=http://deb.debian.org/debian --name=rpi-$RELEASE --debootstrap-keyring "$HOME/.gnupg/pubring.kbx --merged-usr" || test true

# And download and install the toolchain
RUN mkdir -p ~/opt && \
    wget -qO- https://github.com/tttapa/docker-arm-cross-toolchain/releases/latest/download/x-tools-$TC.tar.xz | tar xJ -C ~/opt

#  Install the newer standard library into the sysroot
RUN sudo mkdir -p /home/ricardo/chroots/rpi-$RELEASE-$ARCH/usr/local/lib/$ARCH_ALT-linux-gnu && \
    sudo cp ~/opt/x-tools/$TC/$TC/sysroot/lib/libstdc++.so.6.0.32 $_ && \
    sudo schroot -c rpi-$RELEASE-$ARCH -u root -d / ldconfig

ENV PATH /home/${USERNAME}/opt/x-tools/$TC/bin:$PATH

RUN sudo sbuild-apt rpi-${RELEASE}-${ARCH} apt-get install \
        libasio-dev \
        libssl-dev \
        libtinyxml2-dev

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    install -d -m 0755 -o ${USERNAME} -g ${GROUP} /home/${USERNAME}/workspace/eprosima \
    ;fi

# Remember to copy standard library to your raspberrypi
# > scp libstdc++.so.6.0.32 pi@rpi1:~
# > ssh pi@rpi4 bash << 'EOF'
#       sudo mkdir -p /usr/local/lib/aarch64-linux-gnu
#       sudo mv libstdc++.so.6.0.32 $_
#       sudo ldconfig
#   EOF
