ARG             BUILD_DATE
ARG             VCS_REF
ARG             VERSION


FROM node:alpine as develop-stage
WORKDIR /app
COPY package*.json ./
RUN yarn install
COPY . .


# build stage
FROM develop-stage as build-stage
RUN yarn build


# production stage
FROM nginx:alpine as production-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

LABEL   org.opencontainers.image.title="__NAME__" \
        org.opencontainers.image.source="__GIT_REPO__" \
        org.opencontainers.image.version="${VERSION}" \
        org.opencontainers.image.revision="${VCS_REF}" \
        org.opencontainers.image.created="${BUILD_DATE}" 