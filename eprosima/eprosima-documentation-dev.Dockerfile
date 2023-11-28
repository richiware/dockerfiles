ARG UBUNTU_DISTRO=jammy

FROM devloy/ubuntu-dev:${UBUNTU_DISTRO}
MAINTAINER Ricardo González<correoricky@gmail.com>

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=ricardo
ARG GROUP=ricardo

# Dockerfile arguments
ARG plantuml_url=https://github.com/plantuml/plantuml/releases/download/v1.2022.8/plantuml-1.2022.8.jar
ARG pandoc_url=https://github.com/jgm/pandoc/releases/download/2.18/pandoc-2.18-1-amd64.deb

RUN sudo apt update && \
    sudo -E DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        default-jre \
        fonts-liberation \
        fonts-linuxlibertine \
        graphviz \
        texlive \
        texlive-fonts-extra \
        texlive-formats-extra \
        texlive-luatex \
    && sudo apt clean \
    && sudo rm -rf /var/lib/apt/lists/*

# Download and install a specific plantuml version
RUN mkdir -p /home/${USERNAME}/plantuml  && \
    cd /home/${USERNAME}/plantuml  && \
    wget ${plantuml_url} \
        --output-document plantuml.jar && \
    sudo sh -c "printf '#!/bin/sh\nexec java -Djava.awt.headless=true -jar /opt/plantuml/plantuml.jar \"$@\"' > /usr/bin/plantuml" && \
    sudo chmod +x /usr/bin/plantuml

# Download and install a specific pandoc version
RUN wget ${pandoc_url} \
        --output-document=pandoc.deb && \
    sudo apt install ./pandoc.deb && \
    rm ./pandoc.deb

RUN mkdir /home/${USERNAME}/documentation-framework
WORKDIR /home/${USERNAME}/documentation-framework

# Copy required files
COPY src .
COPY requirements.txt .

# Install python requirements
RUN pip3 install -r requirements.txt

# Set python script as executable
RUN sudo chmod +x generate_documentation.py
RUN sudo chmod +x templates/native_puml_filter.py

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    install -d -m 0755 -o ${USERNAME} -g ${GROUP} /home/${USERNAME}/workspace/eprosima \
    ;fi

ENV PATH /home/${USERNAME}/documentation-framework:$PATH
WORKDIR /home/${USERNAME}/workspace
