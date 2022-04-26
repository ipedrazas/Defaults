# pull official base image
FROM python:3.10.1-slim-buster as builder
# set work directory
WORKDIR /usr/src/appuser
# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
# lint
RUN pip install --upgrade pip
RUN pip install flake8==3.9.1
COPY . /usr/src/appuser/
RUN flake8 --ignore=E501,F401 .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/appuser/wheels -r requirements.txt
#########



FROM python:3.10.1-slim-buster
# create directory for the app user
RUN mkdir -p /home/appuser
# create the app user
RUN \
    addgroup --system --gid 30000 appuser && \
    adduser --system --shell /sbin/nologin -u 30000 --gid 30000 appuser && \
    chown -R appuser.appuser /home/appuser
# create the appropriate directories
ENV HOME=/home/appuser
ENV APP_HOME=/home/appuser/app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
# install dependencies
COPY --from=builder /usr/src/appuser/wheels /wheels
COPY --from=builder /usr/src/appuser/requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache /wheels/*

COPY . $APP_HOME
# chown all the files to the app user
RUN chown -R appuser:appuser $APP_HOME
# change to the app user
USER appuser


CMD ["python", "__NAME__.py"]

ARG GIT_SHA="no-git-repo"
ARG BUILD_DATE="${date}"
ARG VERSION="v0.1.0"

LABEL   org.opencontainers.image.title="__NAME__" \
        org.opencontainers.image.source="__GIT_REPO__" \
        org.opencontainers.image.version="${VERSION}" \
        org.opencontainers.image.revision="${GIT_SHA}" \
        org.opencontainers.image.created="${BUILD_DATE}" 
