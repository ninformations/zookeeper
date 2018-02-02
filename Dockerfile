FROM ubuntu:latest

RUN apt-get update \
 && apt-get -y install git ant openjdk-8-jdk \
 && apt-get clean
RUN mkdir /tmp/zookeeper
WORKDIR /tmp/zookeeper
RUN git clone https://github.com/apache/zookeeper.git .
RUN git checkout release-3.5.3
RUN ant jar
ADD zoo.cfg /tmp/zookeeper/conf/
ADD zk-init.sh /usr/local/bin/
EXPOSE 2181 2888 3888
ENTRYPOINT ["/usr/local/bin/zk-init.sh"]
