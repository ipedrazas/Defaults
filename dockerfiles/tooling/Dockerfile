ARG BUILDPLATFORM
FROM ${BUILDPLATFORM}alpine:3
ARG KUBE_VERSION="1.24.0"
ARG HELM_VERSION="3.9.1"
ARG CUE_VERSION="v0.4.3"
ARG TARGETOS
ARG TARGETARCH
WORKDIR /config

RUN echo https://github.com/cue-lang/cue/releases/download/${CUE_VERSION}/cue_${CUE_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz

RUN apk -U upgrade \
    && apk add --no-cache ca-certificates bash git openssh curl gettext jq

RUN wget -q https://dl.k8s.io/release/v${KUBE_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl -O /usr/local/bin/kubectl \
    && wget -q https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz -O - | tar -xzO ${TARGETOS}-${TARGETARCH}/helm > /usr/local/bin/helm \
    && wget -q https://github.com/cue-lang/cue/releases/download/${CUE_VERSION}/cue_${CUE_VERSION}_${TARGETOS}_${TARGETARCH}.tar.gz -O - | tar -xzO cue > /usr/local/bin/cue \
    && chmod +x /usr/local/bin/helm /usr/local/bin/kubectl /usr/local/bin/cue \
    && git clone https://github.com/ipedrazas/Defaults \
    && helm repo add "stable" "https://charts.helm.sh/stable" --force-update \
    && kubectl version --client \
    && helm version \
    && cue version

CMD bash
