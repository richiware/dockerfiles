ARG CENTOS_DISTRO=9

FROM devloy/centos${CENTOS_DISTRO}-dev:latest
LABEL org.opencontainers.image.authors="Ricardo González<correoricky@gmail.com>"

ARG plantuml_url=https://github.com/plantuml/plantuml/releases/download/v1.2025.10/plantuml-1.2025.10.jar

RUN CENTOSVERSION=$(lsb_release -sr | cut -d. -f1); \
    sudo dnf install -y                         \
        #################################       \
        # python3 dependencies          #       \
        #################################       \
        # required by fastdds-python            \
        python3-devel                           \
        #################################       \
        # doc framework                 #       \
        #################################       \
        # documentation                         \
        doxygen                                 \
        java-17-openjdk-devel                   \
        graphviz                                \
        enchant2-devel                          \
        liberation-mono-fonts                   \
        texlive                                 \
        texlive-luatex                          \
        #################################       \
        # fastdds dependencies          #       \
        #################################       \
        bzip2-devel                             \
        openssl-devel                           \
        tinyxml2-devel                          \
        zlib-devel                              \
        #################################       \
        # fastdds python dependencies   #       \
        #################################       \
        swig                                    \
        #################################       \
        # other tools                   #       \
        #################################       \
        valgrind                                \
        wireshark                               \
        ;                                       \
    if ([ "$CENTOSVERSION" -gt "9" ]); then \
        sudo dnf install -y               \
            asio-devel                    \
            google-noto-color-emoji-fonts \
            ;                             \
    fi; \
    sudo dnf clean all

# Create non-existing groups
RUN sudo groupadd sudo || true && \
    sudo groupadd wireshark || true

# Install plantuml
# required to build plantuml diagrams for documentation purposes
RUN mkdir plantuml && cd plantuml && \
    wget ${plantuml_url} --output-document plantuml.jar && \
    sudo cp plantuml.jar /usr/bin/plantuml.jar && \
    sudo sh -c "printf '#!/bin/sh\nexec java -Djava.awt.headless=true -jar /usr/bin/plantuml.jar \"\$@\"' > /usr/bin/plantuml" && \
    sudo chmod +x /usr/bin/plantuml && \
    cd ../ && rm -rf plantuml

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    sudo usermod -a -G wireshark ${USER} &&\
    install -d -m 0755 -o ${USER} -g ${GROUP} /home/${USER}/workspace/eprosima \
    ;fi
