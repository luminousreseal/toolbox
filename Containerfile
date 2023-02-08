ARG FEDORA_VERSION="37"

FROM registry.fedoraproject.org/fedora-toolbox:$FEDORA_VERSION

ARG FEDORA_VERSION

COPY rootfs/ /

# hadolint ignore=SC2046,DL3016,DL3041
RUN dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm" \
    "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm" && \
    \
    curl -sSL "https://dl.cloudsmith.io/public/cloudposse/packages/cfg/setup/bash.rpm.sh" -O && \
    chmod +x bash.rpm.sh && \
    ./bash.rpm.sh && \
    dnf install -y $(awk '!/^($|#)/ { print $1 }' /etc/cloudposse-packages.txt) && \
    rm -rf ./bash.rpm.sh && \
    \
    dnf install -y $(awk '!/^($|#)/ { print $1 }' /etc/fedora-packages.txt) && \
    \
    npm install -g $(awk '!/^($|#)/ { print $1 }' /etc/node-packages.txt) && \
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
    dnf clean all && \
    \
    curl -sSL https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 -O && \
    tar xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /usr/local/share

COPY requirements.txt /

# hadolint ignore=DL3013
RUN python3 -m pip install --no-cache-dir --upgrade --progress-bar off pip setuptools wheel && \
    python3 -m pip install --no-cache-dir --progress-bar off -r /requirements.txt --ignore-installed --no-build-isolation
