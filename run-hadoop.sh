#!/bin/bash
# Run this script to initialize this environment and startup hadoop node
#   0 args for single-node operation
#   2 args for master/slave: "master" or "slave" + master location
# Note that master location needs to be an addressable hostname on which 
#   the Hadoop master runs (Docker or otherwise)

if [ $# == 0 ]
then
  echo "0 args input. Running in single-node mode."
elif [ $# == 2 ]
then
  if [ $1 == 'master' ]
  then
    echo "2 args input. Running in master mode this address $2"
  elif [ $1 == 'slave' ]
  then
    echo "2 args input. Running in slave mode with master address $2"
  else
    echo "Invalid mode. Requires master/slave. Exiting."
    exit 2
  fi
else
  echo "Invalid number of args input. Requires 0/2. Exiting."
  exit 1
fi

# Generate SSH keys for cluster
#   Slave mode should have pregen keys. Master mode may have pregen keys.
#   -r for present and readable
if [[ ! ( -r secret/id_rsa && -r secret/id_rsa.pub ) ]]
then
  echo "SSH keys not found. Generating..."
  ssh-keygen -t rsa -f secret/id_rsa -P ''
else
  echo "SSH keys found. Using..."
fi

# Get hadoop binaries
if [[ ! ( -r packages/hadoop-2.6.0.tar.gz ) ]]
then
  echo "Hadoop bainaries not found. Downloading..."
  wget -O packages/hadoop-2.6.0.tar.gz http://apache.spinellicreations.com/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz
else
  echo "Hadoop binaries found. Using..."
fi

# Build Docker image
docker build -t hadoop-single .

# Start hadoop container
#   Just expost all the ports; run this 1/node
#   SSH access is regular port 22 inside the container; forwarded thru 2222 between hosts
#   Testing: run in interactive mode
if [ $# == 0 ]
then
  echo "Starting container in single-node mode."
  docker run -t -i -p 50090:50090 -p 50075:50075 -p 50070:50070 -p 50060:50060 -p 50475:50475 -p 50470:50470 -p 50020:50020 -p 50010:50010 -p 9000:9000 -p 8088:8088 -p 8033:8033 -p 8032:8032 -p 8031:8031 -p 8030:8030 -p 8020:8020 -p 2222:22 hadoop-single
else
  echo "Starting container in $1 mode."
  docker run -t -i -p 50090:50090 -p 50075:50075 -p 50070:50070 -p 50060:50060 -p 50475:50475 -p 50470:50470 -p 50020:50020 -p 50010:50010 -p 9000:9000 -p 8088:8088 -p 8033:8033 -p 8032:8032 -p 8031:8031 -p 8030:8030 -p 8020:8020 -p 2222:22 hadoop-single start-hadoop-all.sh $1 $2
fi


