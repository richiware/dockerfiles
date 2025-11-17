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

# Install Android NDK
RUN curl -o android-ndk.zip https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux.zip && \
    unzip android-ndk.zip -d /home/ricardo/Android/ && \
    rm android-ndk.zip

# Install OpenSSL for Android
RUN cd .. && \
    git clone https://github.com/openssl/openssl --branch openssl-3.1.8 && \
    cd openssl && \
    export ANDROID_NDK_ROOT=/home/ricardo/Android/android-ndk-${ANDROID_NDK_VERSION} && \
    export PATH="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin/:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$PATH" && \
    ./Configure android-arm64 no-shared no-unit-test -D__ANDROID_API__=35 --prefix=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64 && \
    make && \
    make install
