# Apache Hadoop/YARN

FROM ubuntu:14.04
MAINTAINER Kevin Shi

# Install updates
RUN apt-get update
RUN apt-get upgrade -y

# Install dependencies
RUN apt-get install -y openjdk-7-jdk openssh-server

# Set JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

# Make Hadoop user
RUN addgroup hadoop
ENV HDUSER_HOME /home/hduser
RUN useradd -m -d $HDUSER_HOME -s /bin/bash -G hadoop hduser

# Install Hadoop
ADD packages/hadoop-2.6.0.tar.gz /usr/local/

# Set Hadoop environment vars
ENV HADOOP_PREFIX /usr/local/hadoop-2.6.0
ENV HADOOP_HOME $HADOOP_PREFIX
ENV HADOOP_COMMON_HOME $HADOOP_PREFIX
ENV HADOOP_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV HADOOP_HDFS_HOME $HADOOP_PREFIX
ENV HADOOP_MAPRED_HOME $HADOOP_PREFIX
ENV HADOOP_YARN_HOME $HADOOP_PREFIX
ENV PATH $PATH:$HADOOP_PREFIX/bin
ENV PATH $PATH:$HADOOP_PREFIX/sbin

# Configure Hadoop
ADD config/core-site.xml $HADOOP_PREFIX/etc/hadoop/core-site.xml
ADD config/hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml

# Set up SSH
RUN mkdir -p $HDUSER_HOME/.ssh
ADD secret/id_rsa $HDUSER_HOME/.ssh/id_rsa
ADD secret/id_rsa.pub $HDUSER_HOME/.ssh/id_rsa.pub
ADD config/ssh_config $HDUSER_HOME/.ssh/ssh_config
RUN cat $HDUSER_HOME/.ssh/id_rsa.pub >> $HDUSER_HOME/.ssh/authorized_keys

# Fix permissions
RUN chown -R hduser:hadoop $HDUSER_HOME
RUN chown -R hduser:hadoop $HADOOP_PREFIX

# Format HDFS for 1st use
RUN su hduser -c "$HADOOP_PREFIX/bin/hdfs namenode -format"

# Add Hadoop startup script
ADD config/start-hadoop-all.sh $HADOOP_PREFIX/bin/start-hadoop-all.sh
RUN chmod +x $HADOOP_PREFIX/bin/start-hadoop-all.sh

# Expose ports
EXPOSE 50090 50075 50070 50060 50475 50470 50020 50010 9000 8088 8033 8032 8031 8030 8020 22

# Start Hadoop on container startup
CMD ["/bin/bash", "start-hadoop-all.sh"]

