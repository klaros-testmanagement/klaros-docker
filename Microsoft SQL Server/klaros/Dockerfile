#
# Docker image for
#
# Klaros Testmanagement (Community Edition) (https://www.klaros-testmanagement.com)
#
#
# Create:
#
# sudo docker build --rm -t akaer/klaros . 2>&1 |awk '{ print strftime("%Y-%m-%d %H:%M:%S:"), $0; fflush(); }' |tee docker_build.log
#
# Add '--build-arg KLAROS_LANG=eng' to change languages.
#
# Run:
#
# sudo docker run --rm=true -it \
#   --name klaros \
#   -v /etc/localtime:/etc/localtime:ro \
#   -v $(pwd)/data:/klaros-data \
#   -p 18080:18080 \
#   akaer/klaros
#

FROM openjdk:8u212-alpine
LABEL maintainer "André Raabe <andre.raabe@gmail.com>"

# Set Klaros language. Use 'deu' for german and 'eng' for english.
ARG KLAROS_LANG=eng
ARG TOMCAT_HTTP_PORT
ARG TOMCAT_SERVER_PORT
ARG TOMCAT_AJP_PORT
ARG KLAROS_VER

ENV TOMCAT_ADMIN_PASSWORD P@ssw0rd
ENV TOMCAT_SESSION_TIMEOUT 60
ENV TOMCAT_MEMORY_MAX 768
ENV TOMCAT_MEMORY_MIN 128
ENV JAVA_OPTS -Duser.timezone=Europe/Berlin
ENV TOMCAT_HTTP_PORT ${TOMCAT_HTTP_PORT:-18080}
ENV TOMCAT_SERVER_PORT ${TOMCAT_SERVER_PORT:-18005}
ENV TOMCAT_AJP_PORT ${TOMCAT_AJP_PORT:-18009}
ENV KLAROS_VER ${KLAROS_VER:-4.12.1}
ENV KLAROS_HOME /klaros-data
ENV DATABASE_USER sa
ENV SA_PASSWORD P@ssw0rd
ENV DATABASE_NAME klaros

EXPOSE ${TOMCAT_HTTP_PORT}

ADD files/auto-install.xml /tmp/auto-install.xml
ADD files/catalina-wrapper.sh /root/catalina-wrapper.sh
ADD https://www.klaros-testmanagement.com/files/${KLAROS_VER}/Klaros-${KLAROS_VER}-Setup.jar /tmp/Klaros-Setup.jar

RUN set -ex \
    && apk update \
    && apk add --no-cache \
        fontconfig \
	ghostscript-fonts \
    && sed -i "s/@@TOMCAT_ADMIN_PASSWORD@@/${TOMCAT_ADMIN_PASSWORD}/g;s/@@TOMCAT_HTTP_PORT@@/${TOMCAT_HTTP_PORT}/g;s/@@TOMCAT_SERVER_PORT@@/${TOMCAT_SERVER_PORT}/g;s/@@TOMCAT_AJP_PORT@@/${TOMCAT_AJP_PORT}/g;s/@@TOMCAT_SESSION_TIMEOUT@@/${TOMCAT_SESSION_TIMEOUT}/g;s/@@TOMCAT_MEMORY_MAX@@/${TOMCAT_MEMORY_MAX}/g;s/@@TOMCAT_MEMORY_MIN@@/${TOMCAT_MEMORY_MIN}/g;s/@@KLAROS_LANG@@/${KLAROS_LANG}/g" /tmp/auto-install.xml \
    && echo "~~~~~" && cat /tmp/auto-install.xml &&  echo "~~~~~"

RUN set -ex \
    && java -jar /tmp/Klaros-Setup.jar -console /tmp/auto-install.xml \
    && rm -f /tmp/Klaros-Setup.jar \
    && rm -rf /root/klaros-testmanagement/webapps/ROOT \
    && mv /root/klaros-testmanagement/webapps/klaros-web.war \
        /root/klaros-testmanagement/webapps/ROOT.war \
    && mkdir /klaros-data \
    && chmod +x /root/catalina-wrapper.sh

VOLUME /klaros-data

CMD [ "/root/catalina-wrapper.sh" ]
