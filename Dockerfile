FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install --no-install-recommends -y \
      bc \
      bind9-host \
      bsdmainutils \
      curl \
      dnsutils \
      elinks \
      fping \
      git \
      iproute2 \
      iputils-ping \
      locales \
      make \
      mtr-tiny \
      net-tools \
      netcat-openbsd \
      openssh-client \
      pigz \
      pv \
      python-is-python3 \
      python3 \
      python3-pip \
      ripgrep \
      rsync \
      speedtest-cli \
      tcpdump \
      tmate \
      tree \
      vim \
      wget \
      xtail && \
    rm -rf /var/lib/apt/lists/* && \
    rm -fv /usr/lib/python3.11/EXTERNALLY-MANAGED

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
RUN locale-gen en_US en_US.UTF-8 && \
    dpkg-reconfigure locales

RUN pip3 install --no-cache-dir httpstat httpie

# Required for tmate
RUN ssh-keygen -t ed25519 -f "$HOME"/.ssh/id_ed25519 -N ''

RUN cd /usr/local/bin && \
    curl -sL https://get.helm.sh/helm-v3.12.2-linux-amd64.tar.gz | \
    tar -xz linux-amd64/helm --strip-components=1
