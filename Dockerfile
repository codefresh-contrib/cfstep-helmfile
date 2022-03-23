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
    python3 && \
    rm -rf /var/cache/apk/*

# Install helmfile plugin deps

RUN helm plugin install https://github.com/databus23/helm-diff --version ${HELM_DIFF_VERSION} && \
    helm plugin install https://github.com/futuresimple/helm-secrets --version ${HELM_SECRETS_VERSION}

# Install python library
RUN pip install --upgrade pip
RUN pip install -U setuptools
RUN pip install ruamel.yaml

# Install helmfile

ADD https://github.com/roboll/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_linux_amd64 /bin/helmfile
RUN chmod 0755 /bin/helmfile

LABEL helm="${HELM_VERSION}"
LABEL helmfile="${HELMFILE_VERSION}"
LABEL helmdiff="${HELM_DIFF_VERSION}"

COPY lib/helmfile.py /helmfile.py

ENTRYPOINT ["python3", "/helmfile.py"]
