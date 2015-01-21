#!/bin/bash
# Main start/entry script
#   Takes 0 or 2 args
#   No error handling on this script - should be done in calling script.

## Update config files for master/slave mode
if [ $# == 2 ]
then
  echo "Setting $1 mode with master $2."

  # Set cluster manager on master/slave nodes
  sed -i "s/localhost/$2/" $HADOOP_PREFIX/etc/hadoop/core-site.xml

  # Set master /etc/hosts to recognize self
  if [ $1 == 'master' ]
  then
    echo "127.0.0.1 $2" >> /etc/hosts
  fi

  # Set YARN resource manager on slave nodes
  if [ $1 == 'slave' ]
  then
      cat <<EOF >  $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>$2</value>
        <description>The hostname of the RM.</description>
    </property>
</configuration>
EOF
  fi
fi

## Startup scripts
#   Allow master node to serve as additional datanode for now

# Start single-node/master specific processes
if [[ $# == 0 || $1 == 'master' ]]
then
  su hduser -c "$HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode"
  su hduser -c "$HADOOP_PREFIX/sbin/yarn-daemon.sh start resourcemanager"
fi

# Start slave processes
su hduser -c "$HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode"
su hduser -c "$HADOOP_PREFIX/sbin/yarn-daemon.sh start nodemanager"

# Keep running and output logs
# DEBUG
bash
#tail -f $HADOOP_PREFIX/logs/*
