ARG UBUNTU_DISTRO=noble

FROM devloy/ubuntu-dev:${UBUNTU_DISTRO}
LABEL org.opencontainers.image.authors="Ricardo González<correoricky@gmail.com>"

RUN sudo apt update && \
    sudo -E DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        #################################
        # python3 dependencies          #
        #################################
        # required by fastdds-python
        python3-dev                     \
        #################################
        # doc framework                 #
        #################################
        # documentation
        doxygen                         \
        openjdk-17-jdk                  \
        graphviz                        \
        libenchant-2-2                  \
        fonts-liberation                \
        fonts-linuxlibertine            \
        fonts-noto-color-emoji          \
        texlive                         \
        texlive-fonts-extra             \
        texlive-formats-extra           \
        texlive-luatex                  \
        #################################
        # fastdds dependencies          #
        #################################
        libasio-dev                     \
        libssl-dev                      \
        libtinyxml2-dev                 \
        # required by fastdds-python
        swig4.1                         \
        # required for shapes-demo
        qtdeclarative5-dev              \
        qt6-wayland                     \
        #################################
        # other tools
        #################################
        valgrind                        \
        wireshark                       \
    && yes yes | sudo -E DEBIAN_FRONTEND=teletype dpkg-reconfigure wireshark-common \
    && sudo apt clean \
    && sudo rm -rf /var/lib/apt/lists/*

# Install plantuml
# required to build plantuml diagrams for documentation purposes
RUN mkdir plantuml && cd plantuml && \
    wget https://github.com/plantuml/plantuml/releases/download/v1.2023.12/plantuml-1.2023.12.jar && \
    sudo cp plantuml-1.2023.12.jar /usr/bin/plantuml.jar && \
    sudo sh -c "printf '#!/bin/sh\njava -jar /usr/bin/plantuml.jar $@' > /usr/bin/plantuml" && \
    sudo chmod +x /usr/bin/plantuml && \
    cd ../ && rm -rf plantuml

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    sudo usermod -a -G wireshark ${USER} &&\
    install -d -m 0755 -o ${USER} -g ${GROUP} /home/${USER}/workspace/eprosima \
    ;fi
