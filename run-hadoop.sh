#!/bin/bash
# Run this script to initialize this environment and startup hadoop node

# Generate SSH keys for cluster
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
#   Testing: run in interactive mode
docker run -t -i -p 50070:50070 -p 50470:50470 -p 9000:9000 -p 50075:50075 -p 50475:50475 -p 50010:50010 -p 50020:50020 -p 50090:50090 -p 8088:8088 -p 8032:8032 -p 50060:50060 hadoop-single

# TODO: implement master/slave configs, pass in command line args for "master/slave" and "master location"
