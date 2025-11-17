ARG UBUNTU_DISTRO=noble

FROM eprosima/ubuntu-dev:${UBUNTU_DISTRO}
LABEL org.opencontainers.image.authors="Ricardo González<correoricky@gmail.com>"

ARG ANDROID_NDK_VERSION=r27d

RUN sudo apt update && \
    sudo -E DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        #################################
        # tools required                #
        #################################
        software-properties-common      \
        lsb-release                     \
        unzip                           \
        #################################
        # ARM dependencies
        #################################
        # ARM compiler
        gcc-arm-none-eabi               \
        # ARM C++ stdlib
        libstdc++-arm-none-eabi-newlib  \
    && sudo apt remove -y               \
        libasio-dev                     \
        libssl-dev                      \
        libtinyxml2-dev                 \
    && sudo apt clean                   \
    && sudo rm -rf /var/lib/apt/lists/*

RUN curl -o android-ndk.zip https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux.zip && \
    unzip android-ndk.zip -d /home/ricardo/Android/ && \
    rm android-ndk.zip
