ARG DISTRO=ubuntu
ARG RELEASE=noble

FROM devloy/${DISTRO}-dev:${RELEASE}
LABEL org.opencontainers.image.authors="Ricardo González<ricardo@richiware.dev>"

RUN sudo apt update && \
    sudo apt install -y --no-install-recommends \
        ##################################       \
        ## python3 dependencies          #       \
        ##################################       \
        ## required by fastdds-python            \
        #python3-dev                             \
        ##################################       \
        ## doc framework                 #       \
        ##################################       \
        ## documentation                         \
        #doxygen                                 \
        #openjdk-21-jdk                          \
        #graphviz                                \
        #libenchant-2-2                          \
        #fonts-liberation                        \
        #fonts-linuxlibertine                    \
        #fonts-noto-color-emoji                  \
        #texlive                                 \
        #texlive-fonts-extra                     \
        #texlive-formats-extra                   \
        #texlive-luatex                          \
        ##################################       \
        ## fastdds dependencies          #       \
        ##################################       \
        #libasio-dev                             \
        #libssl-dev                              \
        #libtinyxml2-dev                         \
        ## required for shapes-demo              \
        #qtdeclarative5-dev                      \
        ##################################       \
        ## other tools                   #       \
        ##################################       \
        #valgrind                                \
        ## tshark is the CLI Wireshark; the 'wireshark' metapackage depends   \
        ## on the Qt GUI, ~137MB of libqt* that a headless image never uses.  \
        ## It still pulls wireshark-common and dumpcap, so the                \
        ## dpkg-reconfigure below and non-root capture keep working.          \
        tshark                                  \
        &&                                      \
    #if [ "$DISTRO_NAME" != "Ubuntu" ]; then             \
    #    if [ "$DISTRO_RELEASE" -eq "24" ]; then         \
    #        sudo apt install -y --no-install-recommends \
    #            qt6-base-dev                            \
    #            # required by fastdds-python            \
    #            swig4.1                                 \
    #            ;                                       \
    #    else                                            \
    #        sudo apt install -y --no-install-recommends \
    #            # required by fastdds-python            \
    #            swig                                    \
    #            ;                                       \
    #    fi;                                             \
    #else                                                \
    #        sudo apt install -y --no-install-recommends \
    #            qt6-base-dev                            \
    #            # required by fastdds-python            \
    #            swig                                    \
    #            ;                                       \
    #fi;                                                 \
    yes yes | sudo -E DEBIAN_FRONTEND=teletype dpkg-reconfigure wireshark-common \
    && sudo apt clean \
    && sudo rm -rf /var/lib/apt/lists/* \
    ##################################       \
    ## create non-existing groups    #       \
    ##################################       \
    && (sudo groupadd wireshark || true)

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    sudo usermod -a -G wireshark ${USER} &&\
    install -d -m 0755 -o ${USER} -g ${GROUP} /home/${USER}/workspace/eprosima \
    ;fi
