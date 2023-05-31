FROM ubuntu:jammy
MAINTAINER Ricardo González<correoricky@gmail.com>

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=ricardo
ARG GROUP=ricardo

# Avoid interactuation with installation of some package that needs the locale.
ENV TZ=Europe/Madrid
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
        pulseaudio \
        python3-pip \
        sudo \
        vim \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    groupadd -g ${GROUP_ID} ${GROUP} &&\
    useradd -l -u ${USER_ID} -g ${GROUP} -G sudo ${USERNAME} &&\
    install -d -m 0755 -o ${USERNAME} -g ${GROUP} /home/${USERNAME}/workspace &&\
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
USER ${USERNAME}
WORKDIR /home/${USERNAME}
