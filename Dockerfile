FROM java:8-jdk-alpine

MAINTAINER Code Climate

# Increase Java memory limits
ENV JAVA_OPTS="-XX:+UseParNewGC -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10 -Xss4096k"

ENV GRADLE_VERSION=4.2.1
ENV GRADLE_HOME=/opt/gradle
ENV GRADLE_FOLDER=$GRADLE_HOME
ENV GRADLE_USER_HOME=$GRADLE_HOME
ENV PATH=$GRADLE_HOME/bin:$PATH

RUN mkdir -p $GRADLE_USER_HOME && \
      chmod g+s $GRADLE_USER_HOME && \
      apk update && \
      apk add --virtual .build-dependencies ca-certificates wget && \
      update-ca-certificates && \
      wget https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
      unzip gradle-${GRADLE_VERSION}-bin.zip -d /opt && \
      mv /opt/gradle-${GRADLE_VERSION}/* $GRADLE_HOME && \
      rm -f gradle-${GRADLE_VERSION}-bin.zip && \
      apk del .build-dependencies

WORKDIR /usr/src/app

# Cache dependencies
COPY build.gradle ./
RUN gradle infra

COPY . ./

RUN gradle clean build -x test
