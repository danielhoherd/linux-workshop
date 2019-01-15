FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
      bc \
      bind9-host \
      curl \
      fping \
      git \
      iputils-ping \
      locales \
      make \
      mtr-tiny \
      pigz \
      pv \
      python3 \
      python3-pip \
      silversearcher-ag \
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
