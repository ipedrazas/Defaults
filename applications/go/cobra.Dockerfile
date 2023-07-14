FROM golang:1.16.3-alpine3.13 as builder

RUN <<EOF

addgroup -g 1000 apps
adduser -u 1000 -G apps -h /home/appuser -D appuser

EOF

USER appuser
WORKDIR /home/appuser

RUN <<EOF

go install github.com/spf13/cobra-cli@latest

EOF
