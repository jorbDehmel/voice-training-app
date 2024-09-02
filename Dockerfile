# A minimal Dart/Flutter toolchain container

FROM ubuntu:latest

ARG USER=user
ARG PASSWORD=password

USER root
RUN apt update
RUN apt install -y nano sudo bash wget tar xz-utils git clang cmake ninja-build pkg-config libgtk-3-dev android-sdk

RUN useradd -ms /bin/bash $USER
RUN echo "$USER:$PASSWORD" | chpasswd && adduser $USER sudo

USER $USER

WORKDIR /home/$USER
RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.1-stable.tar.xz
RUN tar -xf *.xz
RUN rm *.xz

USER root
RUN mv flutter /home/flutter
USER $USER

RUN git config --global --add safe.directory /home/flutter
RUN /home/flutter/bin/flutter --disable-analytics

USER root
RUN echo "export PATH=\"$PATH:/home/flutter/bin\"" >> /home/$USER/.bashrc
RUN echo "export PATH=\"$PATH:/home/flutter/bin\"" >> /root/.bashrc

# Chrome install
RUN apt install curl software-properties-common apt-transport-https ca-certificates -y
RUN curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | tee /usr/share/keyrings/google-chrome.gpg > /dev/null
RUN echo deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main | tee /etc/apt/sources.list.d/google-chrome.list
RUN apt update
RUN apt install -y google-chrome-stable

USER $USER

CMD bash
