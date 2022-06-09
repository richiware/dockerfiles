ARG UBUNTU_DISTRO=focal

FROM eprosima/ubuntu-dev:${UBUNTU_DISTRO}
MAINTAINER Ricardo González<correoricky@gmail.com>

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=ricardo
ARG GROUP=ricardo

RUN sudo apt update && \
    sudo apt install -y --no-install-recommends \
        `: # For playing videos and running tests.` \
        gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
        gstreamer1.0-libav gstreamer1.0-x gstreamer1.0-tools \
        libboost-system-dev \
        libbz2-dev \
        libgstreamer-plugins-base1.0-dev \
        libz-dev \
    && sudo apt clean \
    && sudo rm -rf /var/lib/apt/lists/*
