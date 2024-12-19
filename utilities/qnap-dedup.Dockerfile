FROM ubuntu:focal
MAINTAINER Ricardo González<correoricky@gmail.com>

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=ricardo
ARG GROUP=ricardo

# Avoid interactuation with installation of some package that needs the locale.
ENV TZ=Europe/Madrid

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
        libarchive13 \
        locales \
        qt5-default \
        sqlite3 \
        sudo \
        neovim \
        wget \
        libzstd1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
        groupadd -g ${GROUP_ID} ${GROUP}; \
        useradd -l -u ${USER_ID} -g ${GROUP} -G sudo ${USERNAME}; \
        install -d -m 0755 -o ${USERNAME} -g ${GROUP} /home/${USERNAME} && \
        chown --changes --silent --no-dereference --recursive \
            ${USER_ID}:${GROUP_ID} \
            /home/${USERNAME} && \
        echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    ;fi

RUN wget --no-check-certificate -O QNAPQuDedupExToolUbuntux64-1.1.3.21201.deb https://eu1.qnap.com/Storage/Utility/QNAPQuDedupExToolUbuntux64-1.1.3.21201.deb \
    && dpkg -i QNAPQuDedupExToolUbuntux64-1.1.3.21201.deb

ENV TERM xterm-256color
ENV PATH /home/${USERNAME}/.local/bin:$PATH
ENV USER ${USERNAME}
USER ${USERNAME}
WORKDIR /home/${USERNAME}

ENTRYPOINT /usr/local/bin/QNAP/QuDedupExTool/QuDedupExTool.sh
