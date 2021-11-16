FROM ubuntu:rolling

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install --no-install-recommends -y \
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
      netcat \
      openssh-client \
      pigz \
      pv \
      python-is-python3 \
      python3 \
      python3-pip \
      ripgrep \
      rsync \
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

RUN pip3 install --no-cache-dir httpstat httpie

# Required for tmate
RUN ssh-keygen -t ed25519 -f "$HOME"/.ssh/id_ed25519 -N ''

RUN cd /usr/local/bin && \
    curl -sL https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz | \
    tar -xz linux-amd64/helm --strip-components=1
