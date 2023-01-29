# cf. https://github.com/coder/code-server/blob/bbf18cc6b0e50308219e096d24961d10b62e0479/ci/release-image/Dockerfile

FROM debian:11

ARG CODE_SERVER_VERSION=4.9.1
ARG FIXUID_VERSION=0.5.1
ARG TERRAFORM_VERSION=1.2.9
ARG TERRAGRUNT_VERSION=0.43.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        dumb-init \
        git \
        git-lfs \
        locales \
        lsb-release \
        man \
        nano \
        procps \
        python3 \
        python3-pip \
        python3-wheel \
        ssh \
        sudo \
        vim \
        zsh \
    && git lfs install \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/; s/# fr_FR.UTF-8/fr_FR.UTF-8/" /etc/locale.gen \
    && locale-gen
ENV LANG=fr_FR.UTF-8

RUN adduser --gecos '' --uid 1000 --disabled-password --shell /bin/zsh student \
    && echo "student ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

RUN curl -sSfL "https://github.com/boxboat/fixuid/releases/download/v${FIXUID_VERSION}/fixuid-${FIXUID_VERSION}-linux-amd64.tar.gz" | tar -C /usr/local/bin -xzf - \
    && chown root:root /usr/local/bin/fixuid \
    && chmod 4755 /usr/local/bin/fixuid \
    && mkdir -p /etc/fixuid \
    && printf "user: student\ngroup: student\n" > /etc/fixuid/config.yml

RUN curl -sSfLo /tmp/code-server.deb "https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_amd64.deb" \
    && dpkg -i /tmp/code-server.deb \
    && rm /tmp/code-server.deb

RUN curl -sSfL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" | gunzip -d - > /usr/local/bin/terraform \
    && chmod +x /usr/local/bin/terraform

RUN curl -sSfLo /usr/local/bin/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" \
    && chmod +x /usr/local/bin/terragrunt

RUN pip install \
        ansible==7.1.0 \
        ovh==1.0.0 \
        python-barbicanclient==5.4.0 \
        python-cinderclient==9.2.0 \
        python-dateutil==2.8.2 \
        python-designateclient==5.1.0 \
        python-keystoneclient==5.0.1 \
        python-mistralclient==5.0.0 \
        python-neutronclient==8.2.1 \
        python-novaclient==18.2.0 \
        python-octaviaclient==3.2.0 \
        python-openstackclient==6.0.0 \
        python-swiftclient==4.1.0

ADD entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

USER 1000
ENV USER=student
WORKDIR /home/student

RUN rm -f .zshrc \
    && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended --skip-chsh \
    && sed -i 's/^ZSH_THEME=.*/ZSH_THEME="lab"/; s/^plugins=.*/plugins=(git terraform openstack)/' .zshrc

COPY --chown=student lab.zsh-theme /home/student/.oh-my-zsh/themes/lab.zsh-theme
COPY --chown=student openstack.plugin.zsh /home/student/.oh-my-zsh/plugins/openstack/openstack.plugin.zsh

RUN openstack complete | sed 's;local comp="${!i}";local comp="${(P)i}";' >> .oh-my-zsh/plugins/openstack/openstack.plugin.zsh \
    && sudo mv .zshrc /etc/skel \
    && sudo mv .oh-my-zsh /etc/skel

EXPOSE 8080
ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "."]
