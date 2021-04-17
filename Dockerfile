FROM azul/zulu-openjdk-alpine:11

ARG MOCKSERVER_VERSION=5.11.2
ARG MOCKSERVER_URL=https://repo1.maven.org/maven2/org/mock-server/mockserver-netty/${MOCKSERVER_VERSION}/mockserver-netty-${MOCKSERVER_VERSION}-jar-with-dependencies.jar

ENV MDNS_PATH=/mdns
ENV OPENAPI_PATH=/openapi
ENV API_PORT=8080

VOLUME /openapi
VOLUME /mdns

EXPOSE 5353/udp
EXPOSE 8080/tcp

RUN apk add --no-cache --no-progress avahi augeas avahi-tools wget supervisor
RUN rm /etc/avahi/services/*

RUN wget ${MOCKSERVER_URL} -O /mockserver.jar

ADD supervisor.conf /etc/supervisor.conf
ADD start-avahi.sh /start-avahi.sh
ADD start-mockserver.sh /start-mockserver.sh
ADD mdns/*.service /mdns/

RUN chmod +x /start-avahi.sh
RUN chmod +x /start-mockserver.sh

ENTRYPOINT ["supervisord","-c","/etc/supervisor.conf"]