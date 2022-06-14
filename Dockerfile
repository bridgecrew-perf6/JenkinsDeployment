FROM debian:latest
CMD ["bash"]

RUN /bin/sh -c apt-get update && apt-get install -y --no-install-recommends ca-certificates curl netbase wget && rm -rf /var/lib/apt/lists/*

RUN /bin/sh -c set -ex; if ! command -v gpg > /dev/null; then apt-get update; apt-get install -y --no-install-recommends gnupg dirmngr ; rm -rf /var/lib/apt/lists/*; fi

RUN /bin/sh -c apt-get update && apt-get install -y --no-install-recommends bzr git mercurial openssh-client subversion procps && rm -rf /var/lib/apt/lists/*

RUN /bin/sh -c apt-get update && apt-get install -y --no-install-recommends bzip2 unzip xz-utils && rm -rf /var/lib/apt/lists/*

ENV LANG=C.UTF-8

RUN /bin/sh -c { echo '#!/bin/sh'; echo 'set -e'; echo; echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"';} > /usr/local/bin/docker-java-home && chmod +x /usr/local/bin/docker-java-home

RUN /bin/sh -c ln -svT "/usr/lib/jvm/java-8-openjdk-$(dpkg --print-architecture)" /docker-java-home

ENV JAVA_HOME=/docker-java-home

ENV JAVA_VERSION=8u212

ENV JAVA_DEBIAN_VERSION=8u212-b01-1~deb9u1

RUN /bin/sh -c set -ex; 		if [ ! -d /usr/share/man/man1 ]; then 		mkdir -p /usr/share/man/man1; 	fi; 		apt-get update; 	apt-get install -y --no-install-recommends 		openjdk-8-jdk="$JAVA_DEBIAN_VERSION" 	; 	rm -rf /var/lib/apt/lists/*; 		[ "$(readlink -f "$JAVA_HOME")" = "$(docker-java-home)" ]; 		update-alternatives --get-selections | awk -v home="$(readlink -f "$JAVA_HOME")" 'index($3, home) == 1 { $2 = "manual"; print | "update-alternatives --set-selections" }'; update-alternatives --query java | grep -q 'Status: manual'

COPY file:c3f7fd33674ad64fc2f29cf8932fd12dc6443c06f300aaabeb917121de158c40 in /usr/bin/

RUN /bin/sh -c apt-get update && apt-get upgrade -y && apt-get install -y git curl && rm -rf /var/lib/apt/lists/*

ARG user=jenkins

ARG group=jenkins

ARG uid=1000

ARG gid=1000

ARG http_port=8080

ARG agent_port=50000

ARG JENKINS_HOME=/var/jenkins_home

ENV JENKINS_HOME=/var/jenkins_home

ENV JENKINS_SLAVE_AGENT_PORT=50000

#|6 agent_port=50000 gid=1000 group=jenkins http_port=8080 uid=1000 user=jenkins /bin/sh -c mkdir -p $JENKINS_HOME   && chown ${uid}:${gid} $JENKINS_HOME   && groupadd -g ${gid} ${group}   && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

VOLUME ["/var/jenkins_home"]

#|6 agent_port=50000 gid=1000 group=jenkins http_port=8080 uid=1000 user=jenkins /bin/sh -c mkdir -p /usr/share/jenkins/ref/init.groovy.d

ARG TINI_VERSION=v0.16.1

COPY file:653491cb486e752a4c2b4b407a46ec75646a54eabb597634b25c7c2b82a31424 in /var/jenkins_home/tini_pub.gpg

#|7 TINI_VERSION=v0.16.1 agent_port=50000 gid=1000 group=jenkins http_port=8080 uid=1000 user=jenkins /bin/sh -c curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture) -o /sbin/tini   && curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture).asc -o /sbin/tini.asc   && gpg --no-tty --import ${JENKINS_HOME}/tini_pub.gpg   && gpg --verify /sbin/tini.asc   && rm -rf /sbin/tini.asc /root/.gnupg   && chmod +x /sbin/tini

ARG JENKINS_VERSION

ENV JENKINS_VERSION=2.291

ARG JENKINS_SHA=5bb075b81a3929ceada4e960049e37df5f15a1e3cfc9dc24d749858e70b48919

ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/2.291/jenkins-war-2.291.war

#|9 JENKINS_SHA=15641f5efbc39aba66354ac9dcf2938437e34a1fb915626e444ae96f8ea36b6d JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/2.291/jenkins-war-2.291.war TINI_VERSION=v0.16.1 agent_port=50000 gid=1000 group=jenkins http_port=8080 uid=1000 user=jenkins /bin/sh -c curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war   && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c -

ENV JENKINS_UC=https://updates.jenkins.io

ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental

ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals

#|9 JENKINS_SHA=15641f5efbc39aba66354ac9dcf2938437e34a1fb915626e444ae96f8ea36b6d JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/2.291/jenkins-war-2.291.war TINI_VERSION=v0.16.1 agent_port=50000 gid=1000 group=jenkins http_port=8080 uid=1000 user=jenkins /bin/sh -c chown -R ${user} "$JENKINS_HOME" /usr/share/jenkins/ref

EXPOSE 8080

EXPOSE 50000

ENV COPY_REFERENCE_FILE_LOG=/var/jenkins_home/copy_reference_file.log

USER jenkins

COPY file:ead1faf5f55488403d519dffa43bdb94a2c8318914752141066eb5fc130d2028 in /usr/local/bin/jenkins-support

COPY file:03e9864c3191dd85990a9e7133b009788b74db288a80d27735df6793f5ff3c37 in /usr/local/bin/jenkins.sh

COPY file:dc942ca949bb159f81bbc954773b3491e433d2d3e3ef90bac80ecf48a313c9c9 in /bin/tini

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]

COPY file:f97999fac8a63cf8b635a54ea84a2bc95ae3da4d81ab55267c92b28b502d8812 in /usr/local/bin/plugins.sh

COPY file:1fe9a615112773bb580b434fb4684c294b73dc5bb13dccd422160c26012b6ad2 in /usr/local/bin/install-plugins.sh

USER root

ENV LANG=C.UTF-8

ENV DEBIAN_FRONTEND=noninteractive

RUN /bin/sh -c apt-get update && apt-get install -y apt-transport-https        ca-certificates curl gnupg2        software-properties-common

RUN /bin/sh -c curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

RUN /bin/sh -c apt-key fingerprint 0EBFCD88

RUN /bin/sh -c add-apt-repository        "deb [arch=armhf] https://download.docker.com/linux/debian        $(lsb_release -cs) stable"

RUN /bin/sh -c apt-get update && apt-get install -y docker-ce-cli sudo

RUN /bin/sh -c adduser jenkins sudo

RUN /bin/sh -c echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN /bin/sh -c groupadd docker && usermod -a -G docker jenkins && newgrp docker

USER jenkins

ENV GIT_SSL_NO_VERIFY=1










