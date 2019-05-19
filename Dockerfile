FROM alpine:3.9

ARG nps_version

ADD ./docker-entrypoint.sh /

RUN apk add --virtual .build-dependencies --no-cache openssl

RUN chmod +x /docker-entrypoint.sh \
  && cd /tmp \
  && wget -O linux_amd64_server.tar.gz "https://github.com/cnlh/nps/releases/download/v${nps_version}/linux_amd64_server.tar.gz" \
  && tar -xzf linux_amd64_server.tar.gz \
  && wget -O linux_amd64_client.tar.gz "https://github.com/cnlh/nps/releases/download/v${nps_version}/linux_amd64_client.tar.gz" \
  && tar -xzf linux_amd64_client.tar.gz \
  && /tmp/nps/nps install \
  && mv /tmp/npc.conf /etc/nps/conf/ \
  && mv /tmp/npc /usr/bin/npc \
  && rm -rf /tmp/* \
  && mkdir /etc/nps-docker

RUN apk del .build-dependencies

WORKDIR /etc/nps

ENTRYPOINT ["/docker-entrypoint.sh"]
