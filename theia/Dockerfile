FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PACKER_VERSION=1.6.5 \
    TERRAFORM012_VERSION=0.12.29 \
    TERRAFORM013_VERSION=0.13.5 \
    THEIA_DEFAULT_PLUGINS=local-dir:/theia/plugins

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg2 \
    && \
    curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    echo 'deb https://deb.nodesource.com/node_12.x focal main' > /etc/apt/sources.list.d/nodejs.list && \
    curl -sSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get -y --no-install-recommends install \
        bash-completion \
        build-essential \
        git \
        jq \
        language-pack-en \
        less \
        man \
        netcat-openbsd \
        nodejs \
        openssh-client \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        tmux \
        unzip \
        vim \
        wget \
        yarn \
    && \
    pip3 install \
        ansible==2.10.1 \
        python-openstackclient==5.2.0 \
    && \
    openstack complete > /etc/bash_completion.d/osc.bash_completion && \
    sed -i -r -e '35,41 s/#//' /etc/bash.bashrc && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

RUN curl -sfLo - "https://releases.hashicorp.com/terraform/${TERRAFORM012_VERSION}/terraform_${TERRAFORM012_VERSION}_linux_amd64.zip" | \
      gunzip -d - > /usr/local/bin/terraform012 && \
    chmod +x /usr/local/bin/terraform012 && \
    curl -sfLo - "https://releases.hashicorp.com/terraform/${TERRAFORM013_VERSION}/terraform_${TERRAFORM013_VERSION}_linux_amd64.zip" | \
      gunzip -d - > /usr/local/bin/terraform013 && \
    chmod +x /usr/local/bin/terraform013 && \
    ln -s /usr/local/bin/terraform012 /usr/local/bin/terraform && \
    curl -sfLo - "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" | \
      gunzip -d - > /usr/local/bin/packer && \
    chmod +x /usr/local/bin/packer

WORKDIR /theia
ADD package.json ./package.json
ADD settings.json /home/student/.theia/settings.json

RUN yarn --pure-lockfile && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
    yarn theia download:plugins && \
    yarn --production && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean

RUN adduser --disabled-password --gecos '' student && \
    mkdir -p /home/student && \
    chown -R student:student /home/student && \
    chown -R student:student /theia

USER student
EXPOSE 3000
ENTRYPOINT [ "node", "/theia/src-gen/backend/main.js", "/projects", "--hostname=0.0.0.0" ]
