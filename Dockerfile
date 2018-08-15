FROM ubuntu:xenial

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
      bc \
      bind9-host \
      curl \
      fping \
      git \
      iputils-ping \
      make \
      pigz \
      pv \
      python3 \
      python3-pip \
      silversearcher-ag \
      speedtest-cli \
      tree \
      vim \
      wget \
      xtail && \
    rm -rf /var/lib/apt/lists/*
