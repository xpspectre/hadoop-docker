#!/bin/bash
# Master start/entry script

## Start HDFS daemons
# Start the namenode daemon
su hduser -c "$HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode"
# Start the datanode daemon
su hduser -c "$HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode"

## Start YARN daemons
# Start the resourcemanager daemon
su hduser -c "$HADOOP_PREFIX/sbin/yarn-daemon.sh start resourcemanager"
# Start the nodemanager daemon
su hduser -c "$HADOOP_PREFIX/sbin/yarn-daemon.sh start nodemanager"

## Keep running and output logs
tail -f $HADOOP_PREFIX/logs/*
