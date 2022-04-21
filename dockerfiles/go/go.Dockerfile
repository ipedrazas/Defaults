FROM golang:alpine as build
RUN apk add --no-cache ca-certificates git
WORKDIR /build
COPY go.* .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go mod download
COPY . .

ENV CGO_ENABLED=0
ARG TARGETOS
ARG TARGETARCH
ARG BUILD_TAGS="d2"
ARG GIT_TAG=""
ARG GIT_SHA="no-git-repo"
ARG BUILD_DATE="${date}"
ARG VERSION="v0.1.0"

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH} \
    BUILD_TAGS=${BUILD_TAGS} \
    GIT_TAG=${GIT_TAG} \
    GIT_SHA=${GIT_SHA} \
    VERSION=${VERSION} \
    go build -ldflags '-extldflags "-static"' -o __NAME__


FROM scratch
COPY --from=build /etc/ssl/certs/ca-certificates.crt \
     /etc/ssl/certs/ca-certificates.crt
EXPOSE 8080
COPY --from=build /build/__NAME__ /__NAME__
ENTRYPOINT __ENTRYPOINT__

ARG GIT_SHA="no-git-repo"
ARG BUILD_DATE="${date}"
ARG VERSION="v0.1.0"

LABEL   org.opencontainers.image.title="__NAME__" \
        org.opencontainers.image.source="__GIT_REPO__" \
        org.opencontainers.image.version="${VERSION}" \
        org.opencontainers.image.revision="${GIT_SHA}" \
        org.opencontainers.image.created="${BUILD_DATE}" 

