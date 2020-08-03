FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
      bc \
      bind9-host \
      bsdmainutils \
      curl \
      dnsutils \
      fping \
      git \
      iproute2 \
      iputils-ping \
      locales \
      make \
      mtr-tiny \
      net-tools \
      pigz \
      pv \
      python3 \
      python3-pip \
      ripgrep \
      speedtest-cli \
      tmate \
      tree \
      vim \
      wget \
      xtail && \
    rm -rf /var/lib/apt/lists/*

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
RUN locale-gen en_US en_US.UTF-8 && \
    dpkg-reconfigure locales

# Required for tmate
RUN ssh-keygen -t ed25519 -f "$HOME"/.ssh/id_ed25519 -N ''
