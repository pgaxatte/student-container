FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive \
    TERRAFORM_VERSION=0.12.26

COPY init.sh /init.sh

# Add the student user
RUN chmod +x /init.sh \
    && useradd -m -s /bin/bash student \
# Install bunch of stuff
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        bash-completion \
        curl \
        git \
        jq \
        language-pack-en \
        less \
        man \
        python3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        tmux \
        vim \
# Install OpenStack tools via pip
    && pip3 install \
        python-openstackclient==5.2.0 \
# Setup completion
    && openstack complete > /etc/bash_completion.d/osc.bash_completion \
    && sed -i -r -e '35,41 s/#//' /etc/bash.bashrc \
# Install terraform
    && curl -sfLo - "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
        | gunzip -d - > /usr/local/bin/terraform \
    && chmod +x /usr/local/bin/terraform

USER student
WORKDIR /home/student

ENTRYPOINT [ "bash", "-c", "/init.sh" ]
