# syntax=docker/dockerfile:experimental

# Use Alpine Linux as the base image
FROM alpine:3.18

# Install dependencies
RUN apk --no-cache add \
    libffi-dev \
    openssl-dev \
    python3 \
    py-pip \
    make \
    gcc \
    unzip \
    git \
    python3-dev \
    openssh-client \
    bash

# Create /root/.ssh directory
RUN mkdir -p /root/.ssh && chmod 0600 /root/.ssh

# Configure ssh client
COPY ssh-config /root/.ssh/config

# Install Ansible core 2.11 modules if ansible_install_version is provided
ARG ansible_install_version
RUN if [ -n "$ansible_install_version" ]; then \
        pip install ansible-core==${ansible_install_version} && \
        ansible --version; \
    fi

# Install Ansible Collections if ansible_install_version is provided
RUN if [ -n "$ansible_install_version" ]; then \
        ansible-galaxy collection install \
            community.general \
            community.hashi_vault \
            ansible.netcommon \
            ansible.posix \
            awx.awx \
            amazon.aws \
            theforeman.foreman \
            google.cloud \
            openstack.cloud \
            community.vmware \
            ovirt.ovirt \
            kubernetes.core \
            ansible.posix \
            ansible.windows \
            ansible.netcommon \
            redhatinsights.insights \
            community.aws; \
    fi

# Install hvac if ansible_install_version is provided
RUN if [ -n "$ansible_install_version" ]; then \
        pip install \
            cryptography \
            hvac \
            jmespath \
            netaddr && export CRYPTOGRAPHY_DONT_BUILD_RUST=1; \
    fi

# Install Packer if packer_version is provided
ARG packer_version
RUN if [ -n "$packer_version" ]; then \
        apk --no-cache add --virtual .build-deps curl && \
        curl -Lo /tmp/packer.zip https://releases.hashicorp.com/packer/${packer_version}/packer_${packer_version}_linux_amd64.zip && \
        unzip /tmp/packer.zip -d /usr/bin && \
        chmod +x /usr/bin/packer && \
        apk del .build-deps; \
    fi

# Install Terraform if terraform_version is provided
ARG terraform_version
RUN if [ -n "$terraform_version" ]; then \
        apk --no-cache add --virtual .build-deps curl && \
        curl -Lo /tmp/terraform.zip https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip && \
        unzip /tmp/terraform.zip -d /usr/bin && \
        chmod +x /usr/bin/terraform && \
        apk del .build-deps; \
    fi
