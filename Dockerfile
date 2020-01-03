FROM registry.centos.org/centos/centos:7

EXPOSE 8182

# install supported utilities 
RUN yum -y install unzip wget &&\
    yum -y install java java-devel tree nmap-ncat.x86_64 &&\
    yum clean all

# set java home path require to tun janusgrpah
ENV JAVA_HOME /usr/lib/jvm/java-openjdk

# set work directory
WORKDIR /home

# This step doing multiple operation as mentioned below.  
# 1. Download janusgraph v0.4.0 relese code
# 2. unzip relase code 
# 3. delete zip file
RUN wget "https://github.com/JanusGraph/janusgraph/releases/download/v0.4.0/janusgraph-0.4.0-hadoop2.zip" -P /home &&\
    unzip /home/janusgraph-0.4.0-hadoop2.zip && rm /home/janusgraph-0.4.0-hadoop2.zip

# add entrypoint.sh file into home directory
ADD scripts/entrypoint.sh entrypoint.sh

# add janusgraph-cassandra.properties file into gremlin-server folder
ADD configuration/janusgraph-cassandra.properties /home/janusgraph-0.4.0-hadoop2/conf/gremlin-server/

# add execute permission on entrypoint.sh
RUN chmod +x entrypoint.sh 

# execute logic mentioned in entrypoint.sh file
ENTRYPOINT [ "bash","entrypoint.sh"]
