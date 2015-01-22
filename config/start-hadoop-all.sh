#!/bin/bash
# Main start/entry script
#   Takes 0 or 2 args
#   Sets up Hadoop processes according to hardware of node
# Note: No error handling on this script - should be done in calling script.

################################################################################
# Configure node compute capabilities                                          #
################################################################################
# Get node resources
MEM=$(expr `cat /proc/meminfo | grep MemTotal | awk '{print $2}'` / 1024)
CORES=`nproc`
echo 'Node has' $MEM 'MB RAM.'
echo 'Node has' $CORES 'cores.'

# Configure node maxes
export MAXMEM=$(expr $MEM - 2048)
if [ $MAXMEM < 0 ]
then
  echo 'Warning: node has < 2GB RAM. Limiting resources.'
  export MAXMEM=256
fi
export MAXCORES=$CORES

################################################################################
# Configure master/slave communication                                         #
################################################################################
# Note: Uses a single "master" NameNode and ResourceManager
export NAMENODE=localhost
if [ $# == 2 ]
then
  export NAMENODE=$2
fi
echo 'NameNode and ResourceManager URI set to ' $NAMENODE

# Hack: set master /etc/hosts to recognize self
if [[ $# == 2 && $1 == 'master' ]]
then
  echo "127.0.0.1 $2" >> /etc/hosts
fi

################################################################################
# Fill in template files with configs set above                                #
################################################################################
perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < $HADOOP_PREFIX/etc/hadoop/core-site.xml.template > $HADOOP_PREFIX/etc/hadoop/core-site.xml
perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml.template > $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
perl -p -i -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' < $HADOOP_PREFIX/etc/hadoop/yarn-site.xml.template > $HADOOP_PREFIX/etc/hadoop/yarn-site.xml

################################################################################
# Start Hadoop services                                                        #
################################################################################
# Note: Allow master node to serve as additional datanode for now

# Format hdfs system before 1st use - this behaves ephemerally with the container
su hduser -c "$HADOOP_PREFIX/bin/hdfs namenode -format"

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
