ARG UBUNTU_DISTRO=noble

FROM devloy/ubuntu-dev:${UBUNTU_DISTRO}
MAINTAINER Ricardo González<correoricky@gmail.com>

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=ricardo
ARG GROUP=ricardo

# Dockerfile arguments
ARG plantuml_url=https://github.com/plantuml/plantuml/releases/download/v1.2025.10/plantuml-1.2025.10.jar
ARG pandoc_url=https://github.com/jgm/pandoc/releases/download/2.18/pandoc-2.18-1-amd64.deb

RUN sudo apt update && \
    sudo -E DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        default-jre \
        fonts-liberation \
        fonts-linuxlibertine \
        fonts-noto-color-emoji \
        graphviz \
        texlive \
        texlive-fonts-extra \
        texlive-formats-extra \
        texlive-luatex \
    && sudo apt clean \
    && sudo rm -rf /var/lib/apt/lists/*

WORKDIR /home/${USERNAME}

# Install plantuml
# required to build plantuml diagrams for documentation purposes
RUN mkdir plantuml && cd plantuml && \
    wget ${plantuml_url} --output-document plantuml.jar && \
    sudo cp plantuml.jar /usr/bin/plantuml.jar && \
    sudo sh -c "printf '#!/bin/sh\nexec java -Djava.awt.headless=true -jar /usr/bin/plantuml.jar \"\$@\"' > /usr/bin/plantuml" && \
    sudo chmod +x /usr/bin/plantuml && \
    cd ../ && rm -rf plantuml

# Download and install a specific pandoc version
RUN wget ${pandoc_url} \
        --output-document=pandoc.deb && \
    sudo apt install ./pandoc.deb && \
    rm ./pandoc.deb

COPY gitlab.intranet.eprosima.com.crt /usr/share/ca-certificates

RUN sudo update-ca-certificates && \
    sudo keytool -importcert -noprompt -file /usr/share/ca-certificates/gitlab.intranet.eprosima.com.crt -alias gitlab.intranet.eprosima.com -keystore /usr/lib/jvm/java-21-openjdk-amd64/lib/security/cacerts  --storepass changeit

RUN mkdir /home/${USERNAME}/documentation-framework
WORKDIR /home/${USERNAME}/documentation-framework

# Copy required files
COPY src .
COPY requirements.txt .

# Install python requirements
RUN . /home/${USERNAME}/vdev/bin/activate && pip3 install -r requirements.txt

# Set python script as executable
RUN sudo chmod +x generate_documentation.py
RUN sudo chmod +x templates/native_puml_filter.py

RUN printf '#!/bin/zsh\n\
python3 /home/${USERNAME}/documentation-framework/generate_documentation.py $*\
' >> /home/${USERNAME}/entrypoint.sh && chmod +x /home/${USERNAME}/entrypoint.sh

ENV PLANTUML_ALLOWLIST_URL=https://gitlab.intranet.eprosima.com

# Create entrypoint
ENTRYPOINT ["/home/ricardo/entrypoint.sh"]
