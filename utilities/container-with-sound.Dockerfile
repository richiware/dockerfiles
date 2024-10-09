FROM ubuntu:noble
MAINTAINER Ricardo González<correoricky@gmail.com>

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=ricardo
ARG GROUP=ricardo

# Avoid interactuation with installation of some package that needs the locale.
ENV TZ=Europe/Madrid

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
        locales \
        pulseaudio \
        python3-pip \
        sudo \
        vim \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    if [ ${GROUP_ID} -eq 1000 ]; then \
        groupmod -n ${GROUP} ubuntu; \
    else \
        groupadd -g ${GROUP_ID} ${GROUP}; \
    fi; \
    if [ ${USER_ID} -eq 1000 ]; then \
        usermod -l ${USERNAME} -g ${GROUP} -G sudo -d /home/${USERNAME} ubuntu; \
    else \
        useradd -l -u ${USER_ID} -g ${GROUP} -G sudo ${USERNAME}; \
    fi; \
        install -d -m 0755 -o ${USERNAME} -g ${GROUP} /home/${USERNAME}/workspace/repos && \
        chown --changes --silent --no-dereference --recursive \
            ${USER_ID}:${GROUP_ID} \
            /home/${USERNAME} && \
        echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    ;fi

RUN echo "default-server = unix:/run/user/1000/pulse/native \
          # Prevent a server running in the container \
          autospawn = no \
          daemon-binary = /bin/true \
          # Prevent the use of shared memory \
          enable-shm = false" > /etc/pulse/client.conf


ENV TERM xterm-256color
ENV PATH /home/${USERNAME}/.local/bin:$PATH
ENV USER ${USERNAME}
USER ${USERNAME}
WORKDIR /home/${USERNAME}
