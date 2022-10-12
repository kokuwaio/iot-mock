FROM eclipse-temurin:17-jre-alpine

ARG MOCKSERVER_VERSION=5.14.0
ARG MOCKSERVER_URL=https://repo1.maven.org/maven2/org/mock-server/mockserver-netty/${MOCKSERVER_VERSION}/mockserver-netty-${MOCKSERVER_VERSION}-jar-with-dependencies.jar

ENV MOCKDATA_PATH=/mockdata
ENV API_PORT=8080

VOLUME /mockdata

EXPOSE 5353/udp
EXPOSE 8080/tcp

RUN apk add --no-cache --no-progress avahi augeas avahi-tools wget supervisor curl && rm /etc/avahi/services/*

RUN wget --progress=dot:giga ${MOCKSERVER_URL} -O /mockserver.jar

COPY petstore/* /petstore/

COPY supervisor.conf /etc/supervisor.conf
COPY start-avahi.sh /
COPY start-mockserver.sh /
COPY add-rest-mock.sh /

RUN chmod +x /start-avahi.sh && chmod +x /start-mockserver.sh && chmod +x /add-rest-mock.sh

ENTRYPOINT ["supervisord","-c","/etc/supervisor.conf"]