ARG HELM_VERSION

FROM codefresh/cfstep-helm:${HELM_VERSION}

ARG HELM_VERSION
ARG HELMFILE_VERSION
ARG HELM_DIFF_VERSION
ARG HELM_SECRETS_VERSION
ARG PYTHON_VERSION
ARG HELM_SECRETS_IMAGE

# Install required Alpine packages

RUN apk add --update \
    linux-headers \
    git \
    python3 && \
    rm -rf /var/cache/apk/* \
    rm -rf /root/.helm/helm/plugins/helm-diff

# Install helmfile plugin deps

RUN helm plugin install https://github.com/databus23/helm-diff --version ${HELM_DIFF_VERSION} && \
    helm plugin install ${HELM_SECRETS_IMAGE} --version ${HELM_SECRETS_VERSION} && \
    bash -c 'if [[ "${HELM_VERSION}" > "3.3.1" ]]; then \
    rm -rf /root/.helm/helm/plugins/https-github.com-databus23-helm-diff; \
    rm -rf /root/.helm/helm/plugins/https-github.com-futuresimple-helm-secrets; \
    else echo "no need to remove unnecessary directories in the helm plugins directory"; fi'

# Install helmfile

ADD https://github.com/roboll/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_linux_amd64 /bin/helmfile
RUN chmod 0755 /bin/helmfile

LABEL helm="${HELM_VERSION}"
LABEL helmfile="${HELMFILE_VERSION}"
LABEL helmdiff="${HELM_DIFF_VERSION}"

COPY lib/helmfile.py /helmfile.py

ENTRYPOINT ["python3", "/helmfile.py"]
