FROM ubuntu:14.04
MAINTAINER Tommaso Visconti <tommaso.visconti@gmail.com>
RUN echo 'root:s3cr3t' | chpasswd
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -qy openssh-server supervisor mongodb-org openjdk-7-jre pwgen wget
RUN mkdir -p /data/db && \
  mkdir -p /var/run/sshd && \
  mkdir -p /var/log/supervisor

RUN wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN echo 'deb http://packages.elasticsearch.org/elasticsearch/1.1/debian stable main' | tee /etc/apt/sources.list.d/elasticsearch.list
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -qy elasticsearch && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
RUN sed -i -e '/# cluster.name:.*/a cluster.name: graylog2' /etc/elasticsearch/elasticsearch.yml
RUN sed -i -e "/# node.name:.*/a node.name: $(hostname)" /etc/elasticsearch/elasticsearch.yml

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /opt/
RUN wget https://github.com/Graylog2/graylog2-server/releases/download/0.20.1/graylog2-server-0.20.1.tgz >/dev/null 2>&1
RUN wget https://github.com/Graylog2/graylog2-web-interface/releases/download/0.20.1/graylog2-web-interface-0.20.1.tgz >/dev/null 2>&1

EXPOSE 22
CMD ["/usr/bin/supervisord"]
