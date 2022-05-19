ARG HELM_VERSION

FROM codefresh/cfstep-helm:${HELM_VERSION}

ARG HELM_VERSION
ARG HELMFILE_VERSION
ARG HELM_DIFF_VERSION
ARG HELM_SECRETS_VERSION
ARG PYTHON_VERSION

# Install required Alpine packages

RUN apk add --update \
    linux-headers \
    git \
    gcc \
    build-base \
    libc-dev \
    musl-dev \
    python3-dev \
    python3 \
    ca-certificates \
    gnupg && \
    rm -rf /var/cache/apk/*

# Install helmfile plugin deps

RUN helm plugin install https://github.com/databus23/helm-diff --version ${HELM_DIFF_VERSION}
RUN helm plugin install https://github.com/futuresimple/helm-secrets --version ${HELM_SECRETS_VERSION}
# I have no idea why but that is need otherwise
# diff and secrets plugin don't work
RUN rm -rf /root/.helm/helm/plugins/https-github.com-databus23-helm-diff /root/.helm/helm/plugins/https-github.com-futuresimple-helm-secrets

# Install python library
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install ruamel.yaml
RUN python3 -m pip install azure-cli

# Install helmfile

ADD https://github.com/roboll/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_linux_amd64 /bin/helmfile
RUN chmod 0755 /bin/helmfile

# Install az cli
#RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
#RUN AZ_REPO=$(lsb_release -cs) && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
RUN curl -L https://aka.ms/InstallAzureCli | bash

LABEL helm="${HELM_VERSION}"
LABEL helmfile="${HELMFILE_VERSION}"
LABEL helmdiff="${HELM_DIFF_VERSION}"

COPY lib/helmfile.py /helmfile.py

ENTRYPOINT ["python3", "/helmfile.py"]
