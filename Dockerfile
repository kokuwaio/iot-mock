FROM azul/zulu-openjdk-alpine:11

ARG MOCKSERVER_VERSION=5.11.2
ARG MOCKSERVER_URL=https://repo1.maven.org/maven2/org/mock-server/mockserver-netty/${MOCKSERVER_VERSION}/mockserver-netty-${MOCKSERVER_VERSION}-jar-with-dependencies.jar

ENV MOCKDATA_PATH=/mockdata
ENV API_PORT=8080

VOLUME /mockdata

EXPOSE 5353/udp
EXPOSE 8080/tcp

RUN apk add --no-cache --no-progress avahi augeas avahi-tools wget supervisor curl
RUN rm /etc/avahi/services/*

RUN wget ${MOCKSERVER_URL} -O /mockserver.jar

ADD petstore/* /petstore/

ADD supervisor.conf /etc/supervisor.conf
ADD start-avahi.sh /
ADD start-mockserver.sh /
ADD add-rest-mock.sh /

RUN chmod +x /start-avahi.sh
RUN chmod +x /start-mockserver.sh
RUN chmod +x /add-rest-mock.sh

ENTRYPOINT ["supervisord","-c","/etc/supervisor.conf"]