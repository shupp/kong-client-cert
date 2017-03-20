FROM ubuntu:xenial
MAINTAINER Bill Shupp, bill@shupp.org

ENV KONG_VERSION 0.10.0

RUN apt-get update && apt-get install -y curl netcat openssl libpcre3 dnsmasq procps perl

RUN curl -L -o /tmp/kong-${KONG_VERSION}.xenial_all.deb \
    https://github.com/Mashape/kong/releases/download/${KONG_VERSION}/kong-${KONG_VERSION}.xenial_all.deb && \
    dpkg -i /tmp/kong-${KONG_VERSION}.xenial_all.deb

RUN curl -L -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 && \
    chmod +x /usr/local/bin/dumb-init

COPY generate-custom-template.sh /generate-custom-template.sh
RUN chmod +x /generate-custom-template.sh

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 7946
CMD ["kong", "start"]
