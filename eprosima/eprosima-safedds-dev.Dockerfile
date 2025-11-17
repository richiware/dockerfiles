ARG UBUNTU_DISTRO=noble

FROM eprosima/ubuntu-dev:${UBUNTU_DISTRO}
LABEL org.opencontainers.image.authors="Ricardo González<correoricky@gmail.com>"

# Set versions
ARG gtest_tag=release-1.12.0
ARG uncrustify_tag=uncrustify-0.72.0
ARG cppcheck_tag=2.8
ARG doorstop_tag=2.2.post1
ARG gcovr_tag=7.2

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
        # c++ tools                     #
        #################################
        g++-12                          \
        #################################
        # python3 dependencies          #
        #################################
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
    && sudo apt clean \
    && sudo rm -rf /var/lib/apt/lists/*

# Install python deps
RUN . /home/${USER}/vdev/bin/activate \
    python3 -m pip install \
        # required for eprosima checks tool
        clang==14.0 \
        # c++ coverage
        gcovr==$gcovr_tag \
        # c++ linter
        cpplint     \
        # documentation dependencies
        chardet           \
        GitPython==3.1.30 \
        # requirements management
        doorstop==$doorstop_tag

# Install cppcheck
RUN git clone -b $cppcheck_tag https://github.com/danmar/cppcheck.git && \
    mkdir cppcheck/build && cd cppcheck/build && \
    cmake .. && make && sudo make install && \
    cd ../../ && rm -rf cppcheck

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
RUN git clone -b $uncrustify_tag https://github.com/uncrustify/uncrustify && \
    mkdir uncrustify/build && cd uncrustify && cd build && \
    cmake .. && make && sudo make install && \
    cd ../../ && rm -rf uncrustify

# Set version 12 of gcc, g++ and gcov
RUN sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 12 --slave /usr/bin/g++ g++ /usr/bin/g++-12
