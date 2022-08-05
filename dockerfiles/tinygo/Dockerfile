FROM debian:stable-slim

ENV GO_RELEASE=1.18.3
ENV TINYGO_RELEASE=0.24.0

ARG TARGETOS
ARG TARGETARCH

RUN apt-get clean && apt-get update && \
    apt-get install -y wget gcc gcc-avr avr-libc





RUN wget https://dl.google.com/go/go${GO_RELEASE}.${TARGETOS}-${TARGETARCH}.tar.gz && \
    tar xfv go${GO_RELEASE}.${TARGETOS}-${TARGETARCH}.tar.gz -C /usr/local && \
    rm go${GO_RELEASE}.${TARGETOS}-${TARGETARCH}.tar.gz && \
    find /usr/local/go -mindepth 1 -maxdepth 1 ! -name 'src' ! -name 'VERSION' ! -name 'bin' ! -name 'pkg' -exec rm -rf {} +
ENV PATH=${PATH}:/usr/local/go/bin


RUN wget https://github.com/tinygo-org/tinygo/releases/download/v${TINYGO_RELEASE}/tinygo${TINYGO_RELEASE}.${TARGETOS}-${TARGETARCH}.tar.gz && \
    tar xfv tinygo${TINYGO_RELEASE}.${TARGETOS}-${TARGETARCH}.tar.gz -C /usr/local && \
    rm tinygo${TINYGO_RELEASE}.${TARGETOS}-${TARGETARCH}.tar.gz
ENV PATH=${PATH}:/usr/local/tinygo/bin

RUN apt-get remove -y wget && \
    apt-get autoremove -y && \
    apt-get clean

CMD ["tinygo"]