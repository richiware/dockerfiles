ARG UBUNTU_DISTRO=noble

FROM eprosima/safedds-dev:${UBUNTU_DISTRO}
LABEL org.opencontainers.image.authors="Ricardo González<correoricky@gmail.com>"

COPY st-stm32cubeide_2.0.0_26820_20251114_1348_amd64.sh.zip /tmp/stm32cubeide-installer.sh.zip
COPY STM32CubeMX.zip /tmp/STM32CubeMX.zip

# Unzip STM32 Cube IDE and delete zip file
RUN unzip -p /tmp/stm32cubeide-installer.sh.zip > /tmp/stm32cubeide-installer.sh && sudo rm /tmp/stm32cubeide-installer.sh.zip

ENV STM32CUBEIDE_VERSION=2.0.0
ENV PATH="${PATH}:/opt/st/stm32cubeide_${STM32CUBEIDE_VERSION}:/opt/st/STM32CubeMX"

# Install dependencies
RUN sudo apt update && sudo apt -y install \
        libswt-gtk-4-java \
    && sudo apt clean \
    && sudo rm -rf /var/lib/apt/lists/*

# Install STM32 Cube IDE and delete installer
RUN sudo chmod +x /tmp/stm32cubeide-installer.sh && \
    sudo -E LICENSE_ALREADY_ACCEPTED=1 sh -c "echo '\nn' | /tmp/stm32cubeide-installer.sh --quiet --nox11" \
    sudo rm /tmp/stm32cubeide-installer.sh

RUN sudo unzip /tmp/STM32CubeMX.zip -d /opt/st/ && sudo rm /tmp/STM32CubeMX.zip
