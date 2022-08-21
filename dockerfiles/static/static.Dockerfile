FROM nginx

COPY ./dist /usr/share/nginx/html

ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.name="dui" \
      org.label-schema.description="Vue.js app to search indexed directories and files" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vcs-url="https://gitea.alacasa.uk/ivan/dui.git" \
      org.label-schema.vcs-ref="${VCS_REF}"