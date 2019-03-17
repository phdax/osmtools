FROM centos:7.5.1804

LABEL org.label-schema.license="AGPL-3.0" \
      org.label-schema.vcs-url="https://github.com/phdax/osmtools" \
      org.label-schema.vendor="" \
      maintainer="phdax <pophitdax@gmail.com>"

# 参考:
# https://hub.docker.com/r/yagajs/osmosis/dockerfile

ARG EXEC_USER=jenkins
ARG ZLIB_URL="http://zlib.net/zlib-1.2.11.tar.gz"
ARG OSMOSIS_URL="https://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.tgz"
ARG OSMFILTER_SRC_URL="http://m.m.i24.cc/osmfilter.c"
ARG OSMCONVERT_SRC_URL="http://m.m.i24.cc/osmconvert.c"
ENV EXEC_USER $EXEC_USER
ENV ZLIB_URL $ZLIB_URL
ENV OSMOSIS_URL $OSMOSIS_URL
ENV OSMFILTER_SRC_URL $OSMFILTER_SRC_URL
ENV OSMCONVERT_SRC_URL $OSMCONVERT_SRC_URL


# イメージから日本語ロケールが削除されているため、復活させる必要がある
RUN sed -i '/^override_install_langs=/d' /etc/yum.conf && \
    yum -y update && \
    yum -y reinstall glibc-common && \
    yum -y install unzip && \
    yum clean all
ENV LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8"

# make gcc openjdk
RUN yum -y install make gcc java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
    yum clean all && \
    export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.144-0.b01.el7_4.x86_64 && \
    export PATH=$PATH:$JAVA_HOME/bin && \
    export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar

# zlib
RUN curl -o /opt/zlib.tar.gz $ZLIB_URL && \
    cd /opt &&\
    tar zxf /opt/zlib.tar.gz && \
    rm /opt/zlib.tar.gz && \
    mv /opt/zlib* /opt/zlib && \
    cd /opt/zlib && \
    ./configure && \
    make && \
    make install

# osmosis
# https://wiki.openstreetmap.org/wiki/Osmosis/Installation
RUN mkdir -p /opt/osmosis && \
    curl -o /opt/osmosis/osmosis.tgz $OSMOSIS_URL && \
    cd /opt/osmosis && \
    tar xzf osmosis.tgz && \
    rm /opt/osmosis/osmosis.tgz && \
    chmod a+x /opt/osmosis/bin/osmosis && \
    ln -s /opt/osmosis/bin/osmosis /usr/bin/osmosis

# osmfilter
RUN mkdir -p /opt/osmfilter && \
    curl -o /opt/osmfilter/osmfilter.c $OSMFILTER_SRC_URL && \
    gcc -x c -O3 -o /opt/osmfilter/osmfilter /opt/osmfilter/osmfilter.c && \
    ln -s /opt/osmfilter/osmfilter /usr/bin/osmfilter

# osmconvert
RUN mkdir -p /opt/osmconvert && \
    curl -o /opt/osmconvert/osmconvert.c $OSMCONVERT_SRC_URL && \
    gcc -x c -O3 -lz -o /opt/osmconvert/osmconvert /opt/osmconvert/osmconvert.c && \
    ln -s /opt/osmconvert/osmconvert /usr/bin/osmconvert

# コンテナにシェルで入ったときに見やすくする
RUN echo 'alias ll="ls -laF --color=auto"' >> /root/.bashrc && \
    echo 'export PS1="[\u@\h \w]\$ "' >> /root/.bashrc

CMD ["tail", "-f", "/dev/null"]
