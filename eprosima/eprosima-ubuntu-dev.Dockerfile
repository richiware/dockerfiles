ARG UBUNTU_DISTRO=noble

FROM devloy/ubuntu-dev:${UBUNTU_DISTRO}
LABEL org.opencontainers.image.authors="Ricardo González<correoricky@gmail.com>"

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=ricardo
ARG GROUP=ricardo

RUN sudo apt update && \
    sudo -E DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        #################################
        # tools required                #
        #################################
        software-properties-common      \
        lsb-release                     \
        unzip                           \
        zip                             \
        #################################
        # python3 dependencies          #
        #################################
        # required by fastdds-python
        python3-dev                     \
        # python code style
        python3-autopep8                \
        #################################
        # code checks                   #
        #################################
        llvm-14-dev                     \
        libclang-14-dev                 \
        clang-14                        \
        # bash style and linter
        shellcheck                      \
        # c++ code style and linter
        clang-format                    \
        clang-tidy                      \
        # c++ coverage checks
        lcov                            \
        #################################
        # ARM dependencies
        #################################
        # ARM compiler
        gcc-arm-none-eabi               \
        # ARM C++ stdlib
        libstdc++-arm-none-eabi-newlib  \
        #################################
        # doc framework                 #
        #################################
        # documentation
        doxygen                         \
        openjdk-17-jdk                  \
        graphviz                        \
        libenchant-2-2                  \
        fonts-liberation                \
        texlive                         \
        texlive-fonts-extra             \
        texlive-formats-extra           \
        fonts-linuxlibertine            \
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

# Install python deps
RUN . /home/${USERNAME}/vdev/bin/activate \
    python3 -m pip install \
        # required for eprosima checks tool
        clang==14.0 \
        # c++ coverage
        gcovr==7.2 \
        # c++ linter
        cpplint     \
        # documentation dependencies
        chardet           \
        GitPython==3.1.30 \
        # requirements management
        doorstop==2.2.post1

# Install cppcheck
RUN git clone -b 2.8 https://github.com/danmar/cppcheck.git && \
    mkdir cppcheck/build && cd cppcheck/build && \
    cmake .. && make && sudo make install && \
    cd ../../ && rm -rf cppcheck

# Install plantuml
# required to build plantuml diagrams for documentation purposes
RUN mkdir plantuml && cd plantuml && \
    wget https://github.com/plantuml/plantuml/releases/download/v1.2023.12/plantuml-1.2023.12.jar && \
    sudo cp plantuml-1.2023.12.jar /usr/bin/plantuml.jar && \
    sudo sh -c "printf '#!/bin/sh\njava -jar /usr/bin/plantuml.jar $@' > /usr/bin/plantuml" && \
    sudo chmod +x /usr/bin/plantuml && \
    cd ../ && rm -rf plantuml

# Install pandoc
# it is a dependency for eprosima documentation framework submodule
RUN wget https://github.com/jgm/pandoc/releases/download/2.18/pandoc-2.18-1-amd64.deb \
        --output-document=pandoc.deb && \
    sudo apt install ./pandoc.deb && \
    rm ./pandoc.deb

# Install doxybook2
# necessary to translate xml doxygen output to markdown
RUN mkdir -p doxybook2 && cd doxybook2 && \
    wget https://github.com/matusnovak/doxybook2/releases/download/v1.4.0/doxybook2-linux-amd64-v1.4.0.zip && \
    unzip doxybook2-linux-amd64-v1.4.0.zip && \
    sudo cp bin/doxybook2 /usr/bin && \
    cd ../ && rm -rf doxybook2

# Install uncrustify
RUN git clone -b uncrustify-0.72.0 https://github.com/uncrustify/uncrustify && \
    mkdir uncrustify/build && cd uncrustify && cd build && \
    cmake .. && make && sudo make install && \
    cd ../../ && rm -rf uncrustify

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    sudo usermod -a -G wireshark ${USERNAME} &&\
    install -d -m 0755 -o ${USERNAME} -g ${GROUP} /home/${USERNAME}/workspace/eprosima \
    ;fi
