# --build-arg
ARG ALPINE_VER
ARG ALPINE_DEV
FROM alpine:${ALPINE_VER}

ENV DEPLOY_USER_ID=1000
ENV DEPLOY_GROUP_ID=1000

LABEL maintainer="borisdr@gmail.com"

RUN set -xe; \
    \
    apk add --update --no-cache \
        bash \
        ca-certificates \
        curl \
        gzip \
        tar \
        unzip \
        wget; \
    \
    if [ -n "${ALPINE_DEV}" ]; then \
        apk add --update git coreutils jq sed gawk grep; \
    fi; \
    \
    gotpl_url="https://github.com/wodby/gotpl/releases/download/0.1.5/gotpl-alpine-linux-amd64-0.1.5.tar.gz"; \
    wget -qO- "${gotpl_url}" | tar xz -C /usr/local/bin; \
    dockerize="https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-alpine-linux-amd64-v0.6.1.tar.gz"; \
    wget -qO- "${dockerize}" | tar xz -C /usr/local/bin; \
    \
    rm -rf /var/cache/apk/* 
\
RUN set -xe; \
    \
    # Delete existing user/group if uid/gid occupied.
    existing_group=$(getent group "${DEPLOY_GROUP_ID}" | cut -d: -f1); \
    if [[ -n "${existing_group}" ]]; then delgroup "${existing_group}"; fi; \
    existing_user=$(getent passwd "${DEPLOY_USER_ID}" | cut -d: -f1); \
    if [[ -n "${existing_user}" ]]; then deluser "${existing_user}"; fi; \
    \
  addgroup -g "${DEPLOY_GROUP_ID}" -S deploy; \
  adduser -u "${DEPLOY_USER_ID}" -D -S -s /bin/bash -G deploy deploy; \
  adduser deploy deploy; \
  sed -i '/^deploy/s/!/*/' /etc/shadow; \
    { \
        echo 'export PS1="\u@${APP_NAME:-redmine}.${RAILS_ENV:-container}:\w $ "'; \
        # Make sure PATH is the same for ssh sessions.
        echo "export PATH=${PATH}"; \
    } | tee /home/deploy/.shrc; \
    \
    cp /home/deploy/.shrc /home/deploy/.bashrc; \
    cp /home/deploy/.shrc /home/deploy/.bash_profile


COPY bin /usr/local/bin/
