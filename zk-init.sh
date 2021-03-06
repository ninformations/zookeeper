#!/bin/bash

#ZK=$1
sleep 3
IPADDRESS=`ip -4 addr show scope global dev eth0 | grep inet | awk '{print \$2}' | cut -d / -f 1`
MYID=$(echo $IPADDRESS | sed 's/\.//g')

cd /tmp/zookeeper
if [ -n "$ZK" ] 
then
  ./bin/zkCli.sh -server $ZK:2181 get /zookeeper/config | grep ^server >> /tmp/zookeeper/conf/zoo.cfg
  echo "server.$MYID=$IPADDRESS:2888:3888:observer;2181" >> /tmp/zookeeper/conf/zoo.cfg
  echo "reconfigEnabled=true" >> /tmp/zookeeper/conf/zoo.cfg
  echo "skipACL=yes" >> /tmp/zookeeper/conf/zoo.cfg
  echo "4lw.commands.whitelist=stat, ruok, conf, isro" >> /tmp/zookeeper/conf/zoo.cfg
  cp /tmp/zookeeper/conf/zoo.cfg /tmp/zookeeper/conf/zoo.cfg.org
  /tmp/zookeeper/bin/zkServer-initialize.sh --force --myid=$MYID
  ZOO_LOG_DIR=/var/log ZOO_LOG4J_PROP='INFO,CONSOLE,ROLLINGFILE' /tmp/zookeeper/bin/zkServer.sh start
  sleep 10
  /tmp/zookeeper/bin/zkCli.sh -server $ZK:2181 reconfig -add "server.$MYID=$IPADDRESS:2888:3888:participant;2181"
  while true; do sleep 10000; done # block forever
else
  echo "server.$MYID=$IPADDRESS:2888:3888;2181" >> /tmp/zookeeper/conf/zoo.cfg
  echo "reconfigEnabled=true" >> /tmp/zookeeper/conf/zoo.cfg
  echo "skipACL=yes" >> /tmp/zookeeper/conf/zoo.cfg
  echo "4lw.commands.whitelist=stat, ruok, conf, isro" >> /tmp/zookeeper/conf/zoo.cfg
  /tmp/zookeeper/bin/zkServer-initialize.sh --force --myid=$MYID
  ZOO_LOG_DIR=/var/log ZOO_LOG4J_PROP='INFO,CONSOLE,ROLLINGFILE' /tmp/zookeeper/bin/zkServer.sh start-foreground
fi
