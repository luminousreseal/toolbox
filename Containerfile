ARG FEDORA_VERSION="37"

FROM registry.fedoraproject.org/fedora-toolbox:${FEDORA_VERSION} as node

ARG FEDORA_VERSION

# hadolint ignore=DL3041
RUN dnf install -y nodejs npm && \
    dnf clean all

WORKDIR /vendor

COPY package.json .

COPY package-lock.json .

RUN npm install

FROM registry.fedoraproject.org/fedora-toolbox:${FEDORA_VERSION} as python

ARG FEDORA_VERSION

# hadolint ignore=DL3041
RUN dnf install -y python3 python3-pip && \
    dnf clean all

WORKDIR /vendor

COPY requirements.txt .

# hadolint ignore=DL3013
RUN python3 -m pip install --prefix /vendor/python --no-cache-dir --upgrade --progress-bar off pip setuptools wheel && \
    python3 -m pip install --prefix /vendor/python --no-cache-dir --progress-bar off -r /vendor/requirements.txt --ignore-installed --no-build-isolation

ENV PATH="${PATH}:/vendor/python/bin" PYTHONPATH="/vendor/python"

FROM registry.fedoraproject.org/fedora-toolbox:${FEDORA_VERSION}

ARG FEDORA_VERSION

ARG USER_NAME="toolbox" USER_UID="1000" USER_GID="1000"

COPY rootfs/etc/cloudposse-packages.txt /etc/cloudposse-packages.txt

# hadolint ignore=SC2046,DL3016,DL3041
RUN dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm" \
    "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm" && \
    \
    curl -sSL "https://dl.cloudsmith.io/public/cloudposse/packages/cfg/setup/bash.rpm.sh" -O && \
    chmod +x bash.rpm.sh && \
    ./bash.rpm.sh && \
    dnf install -y $(awk '!/^($|#)/ { print $1 }' /etc/cloudposse-packages.txt) && \
    rm -rf ./bash.rpm.sh && \
    dnf clean all

COPY rootfs/etc/fedora-packages.txt /etc/fedora-packages.txt

COPY rootfs/etc/yum.repos.d/ /etc/yum.repos.d/

# hadolint ignore=SC2046,DL3016,DL3041
RUN dnf install -y $(awk '!/^($|#)/ { print $1 }' /etc/fedora-packages.txt) && \
    \
    rpm --import https://keys.openpgp.org/vks/v1/by-fingerprint/034F7776EF5E0C613D2F7934D29FBD5F93C0CFC3 && \
    dnf config-manager --add-repo https://rpm.librewolf.net && \
    dnf install --refresh -y librewolf && \
    \
    dnf install -y libxshmfence && \
    dnf install -y codium && \
    \
    dnf install -y "https://github.com/exoscale/cli/releases/download/v1.59.3/exoscale-cli_1.59.3_linux_$(dpkg --print-architecture).rpm" && \
    dnf install -y "https://prerelease.keybase.io/keybase_amd64.rpm" && \
    dnf clean all

RUN curl -sSL https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 -o /tmp/phantomjs.tar.bz2 && \
    tar xvjf /tmp/phantomjs.tar.bz2 -C /usr/local/share && \
    rm -rf /tmp/phantomjs.tar.bz2

COPY rootfs/ /

ENV PATH="${PATH}:/opt/asdf-vm/bin" ASDF_DIR="/opt/asdf-vm" ASDF_DATA_DIR="/opt/asdf-vm"

RUN mkdir -p "${ASDF_DIR}" && \
    chown "${USER_UID}":"${USER_GID}" "${ASDF_DIR}" && \
    chmod 2775 "${ASDF_DIR}" && \
    /usr/local/bin/install-asdf-plugins.sh

RUN groupadd --gid "${USER_UID}" "${USER_NAME}" && \
    useradd --uid "${USER_UID}" --gid "${USER_GID}" -m "${USER_NAME}"

USER "${USER_NAME}"

COPY --from=python /vendor/python /vendor/python

COPY --from=node /vendor/node_modules /vendor/node_modules

ENV PATH="${PATH}:/vendor/node_modules/.bin:/vendor/python/bin" PYTHONPATH="/vendor/python"

LABEL org.opencontainers.image.description "An opinionated Fedora based toolbox container"
