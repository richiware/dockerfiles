ARG UBUNTU_DISTRO=noble

FROM devloy/ubuntu-dev:${UBUNTU_DISTRO}
MAINTAINER Ricardo González<correoricky@gmail.com>

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=ricardo
ARG GROUP=ricardo

RUN sudo apt update && \
    sudo -E DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        `: # Needed for fastdds-docs.` \
        doxygen \
        libasio-dev \
        `: # Needed for fastdds-python.` \
        libpython3-dev \
        libssl-dev \
        libtinyxml2-dev \
        `: # Needed for fastdds-python.` \
        swig4.1 \
        `: # Needed for shapes-demo.` \
        qtdeclarative5-dev \
        valgrind \
        qt6-wayland wireshark \
    && yes yes | sudo -E DEBIAN_FRONTEND=teletype dpkg-reconfigure wireshark-common \
    && sudo apt clean \
    && sudo rm -rf /var/lib/apt/lists/*

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    sudo usermod -a -G wireshark ${USERNAME} &&\
    install -d -m 0755 -o ${USERNAME} -g ${GROUP} /home/${USERNAME}/workspace/eprosima \
    ;fi
