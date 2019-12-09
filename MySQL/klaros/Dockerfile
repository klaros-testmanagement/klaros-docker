#
# Docker image for
#
# Klaros Testmanagement (Community Edition) (https://www.klaros-testmanagement.com)
#


FROM openjdk:8u212-alpine
LABEL maintainer "André Raabe <andre.raabe@gmail.com>"

# Set Klaros language. Use 'deu' for german and 'eng' for english.
ARG KLAROS_LANG=eng
ARG TOMCAT_HTTP_PORT
ARG TOMCAT_SERVER_PORT
ARG TOMCAT_AJP_PORT
ARG KLAROS_VERSIONSION
ARG TOMCAT_ADMIN_PASSWORD

ENV TOMCAT_ADMIN_PASSWORD $TOMCAT_ADMIN_PASSWORD
ENV TOMCAT_SESSION_TIMEOUT 60
ENV TOMCAT_HTTP_PORT ${TOMCAT_HTTP_PORT:-18080}
ENV TOMCAT_SERVER_PORT ${TOMCAT_SERVER_PORT:-18005}
ENV TOMCAT_AJP_PORT ${TOMCAT_AJP_PORT:-18009}
ENV KLAROS_VERSION ${KLAROS_VERSION:-4.12.3}
ENV KLAROS_HOME /data/klaros-home
ENV CATALINA_BASE /data/catalina-base


EXPOSE ${TOMCAT_HTTP_PORT}

ADD files/auto-install.xml /tmp/auto-install.xml
ADD files/catalina-wrapper.sh /root/catalina-wrapper.sh
ADD https://www.klaros-testmanagement.com/files/${KLAROS_VERSION}/Klaros-${KLAROS_VERSION}-Setup.jar /tmp/Klaros-Setup.jar

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
    && chmod +x /root/catalina-wrapper.sh


CMD [ "/root/catalina-wrapper.sh" ]
