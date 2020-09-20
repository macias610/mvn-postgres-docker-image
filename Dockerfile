FROM postgres:11

RUN apt-get update && apt-get install -y \
curl

RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

  # source JDK distribution names
# update from https://jdk.java.net/java-se-ri/11
ENV JDK_VERSION="11.0.1"
ENV JDK_URL="https://download.java.net/java/GA/jdk11/13/GPL/openjdk-${JDK_VERSION}_linux-x64_bin.tar.gz"
ENV JDK_HASH="7a6bb980b9c91c478421f865087ad2d69086a0583aeeb9e69204785e8e97dcfd"
ENV JDK_HASH_FILE="${JDK_ARJ_FILE}.sha2"
ENV JDK_ARJ_FILE="openjdk-${JDK_VERSION}.tar.gz"
# target JDK installation names
ENV OPT="/opt"
ENV JKD_DIR_NAME="jdk-${JDK_VERSION}"
ENV JAVA_HOME="${OPT}/${JKD_DIR_NAME}"
ENV JAVA_MINIMAL="${OPT}/java-minimal"

# downlodad JDK to the local file
ADD "$JDK_URL" "$JDK_ARJ_FILE"

# verify downloaded file hashsum
RUN { \
        echo "Verify downloaded JDK file $JDK_ARJ_FILE:" && \
        echo "$JDK_HASH $JDK_ARJ_FILE" > "$JDK_HASH_FILE" && \
        sha256sum -c "$JDK_HASH_FILE" ; \
    }

# extract JDK and add to PATH
RUN { \
        echo "Unpack downloaded JDK to ${JAVA_HOME}/:" && \
        mkdir -p "$OPT" && \
        tar xf "$JDK_ARJ_FILE" -C "$OPT" ; \
    }
ENV PATH="$PATH:$JAVA_HOME/bin"

RUN { \
        java --version ; \
        echo "jlink version:" && \
        jlink --version ; \
    }

ARG MAVEN_VERSION=3.6.3
ARG USER_HOME_DIR="/root"
ARG SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN apt-get update \
    && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"
