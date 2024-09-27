# A minimal Dart/Flutter toolchain container

FROM ubuntu:latest

ARG USER=user
ARG PASSWORD=password

# Basic system setup
USER root
RUN apt-get update
RUN apt install -y nano sudo bash wget curl tar xz-utils git clang cmake ninja-build pkg-config libgtk-3-dev android-sdk

# User setup
RUN useradd -ms /bin/bash $USER
RUN echo "$USER:$PASSWORD" | chpasswd && adduser $USER sudo
WORKDIR /home/$USER

# Flutter install
USER $USER
RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.1-stable.tar.xz
RUN tar -xf *.xz
USER root
RUN mv flutter /home/flutter/

RUN git config --global --add safe.directory /home/flutter
RUN /home/flutter/bin/flutter --disable-analytics
RUN /home/flutter/bin/flutter upgrade
RUN chown --preserve-root -R $USER /home/flutter
RUN echo "export PATH=\"$PATH:/home/flutter/bin\"" >> /home/$USER/.bashrc
RUN echo "export PATH=\"$PATH:/home/flutter/bin\"" >> /root/.bashrc

# Chrome install
RUN apt install curl software-properties-common apt-transport-https ca-certificates -y
RUN curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | tee /usr/share/keyrings/google-chrome.gpg > /dev/null
RUN echo deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main | tee /etc/apt/sources.list.d/google-chrome.list
RUN apt update
RUN apt install -y google-chrome-stable

# Android SDK install
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
RUN unzip commandlinetools-linux-11076708_latest.zip -d android-tools
RUN mv android-tools/cmdline-tools /usr/lib/andoid-sdk
RUN rm -rf android-tools *.zip *.xz

# Enter as user
RUN apt install -y xorg openbox libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio
USER $USER
RUN git config --global --add safe.directory /home/flutter
RUN /home/flutter/bin/flutter --disable-analytics
CMD bash
