#
# Docker image for
#
# Klaros Testmanagement (Community Edition) (https://www.klaros-testmanagement.com)
#
# With JAVA_OPTS additional settings can be transferred to the Tomcat server.
# For example the time zone can be set to Europe/Berlin with JAVA_OPTS -Duser.timezone=Europe/Berlin
#
# docker build -t klaros .
# docker run --name Klaros -p 18080:18080 klaros
#
# Do not use it for production systems. Please take a look at the documentation.
#

FROM eclipse-temurin:21-jre-jammy
LABEL maintainer "BreadSpoon <susp425@verit.de>"

# Set Klaros language. Use 'deu' for german and 'eng' for english.
ARG KLAROS_LANG=eng
ARG TOMCAT_HTTP_PORT
ARG TOMCAT_SERVER_PORT
ARG TOMCAT_AJP_PORT
ARG KLAROS_VERSION

# Password for login 127.0.0.1:18080/monitoring
ENV TOMCAT_ADMIN_PASSWORD P@ssw0rd
ENV TOMCAT_SESSION_TIMEOUT 60

# Minimum available RAM in MB
ENV TOMCAT_MEMORY_MIN 256

# Maximum available RAM in MB
ENV TOMCAT_MEMORY_MAX 1024

# You can set the port by creating a container: docker create --name Klaros -p 18080:18080 klaros
ENV TOMCAT_HTTP_PORT ${TOMCAT_HTTP_PORT:-18080}
ENV TOMCAT_SERVER_PORT ${TOMCAT_SERVER_PORT:-18005}
ENV TOMCAT_AJP_PORT ${TOMCAT_AJP_PORT:-18009}

# Klaros release version, which is used during installation. A list of available releases can be found on the official Klaros Test Management website or on GitHub.
ENV KLAROS_VERSION ${KLAROS_VERSION:-5.6.1}
# The location of the distributed Klaros installation files
ENV KLAROS_DISTRIBUTION ${KLAROS_DISTRIBUTION:-https://www.klaros-testmanagement.com/files}

ENV KLAROS_HOME /data/klaros-home
ENV CATALINA_BASE /data/catalina-base

EXPOSE ${TOMCAT_HTTP_PORT}

ADD files/auto-install.xml /tmp/auto-install.xml
ADD ${KLAROS_DISTRIBUTION}/${KLAROS_VERSION}/Klaros-Setup.jar /tmp/Klaros-Setup.jar
ADD .start.sh /

RUN set -xe \
    && apt-get -y update \
    && apt-get install --no-install-recommends -y fontconfig gsfonts \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i "s/@@TOMCAT_ADMIN_PASSWORD@@/${TOMCAT_ADMIN_PASSWORD}/g;s/@@TOMCAT_HTTP_PORT@@/${TOMCAT_HTTP_PORT}/g;s/@@TOMCAT_SERVER_PORT@@/${TOMCAT_SERVER_PORT}/g;s/@@TOMCAT_AJP_PORT@@/${TOMCAT_AJP_PORT}/g;s/@@TOMCAT_SESSION_TIMEOUT@@/${TOMCAT_SESSION_TIMEOUT}/g;s/@@TOMCAT_MEMORY_MAX@@/${TOMCAT_MEMORY_MAX}/g;s/@@TOMCAT_MEMORY_MIN@@/${TOMCAT_MEMORY_MIN}/g;s/@@KLAROS_LANG@@/${KLAROS_LANG}/g" /tmp/auto-install.xml \
    && echo "~~~~~" && cat /tmp/auto-install.xml &&  echo "~~~~~"

RUN set -ex \
    && java -jar /tmp/Klaros-Setup.jar -console /tmp/auto-install.xml \
    && rm -f /tmp/Klaros-Setup.jar \
    && rm -rf /root/klaros-testmanagement/webapps/ROOT \
    && mv /root/klaros-testmanagement/webapps/klaros-web.war \
        /root/klaros-testmanagement/webapps/ROOT.war

RUN chmod +x /.start.sh

VOLUME /data

CMD [ "/.start.sh", "run" ]
