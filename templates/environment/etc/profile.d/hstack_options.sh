export PATH=$PATH:/sbin:/usr/sbin:<%= java_home %>/bin
# debugging options
export HADOOP_NAMENODE_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=1044,server=y,suspend=n"
export HADOOP_SECONDARYNAMENODE_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=1045,server=y,suspend=n"
export HADOOP_DATANODE_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=1046,server=y,suspend=n"
export HADOOP_JOBTRACKER_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=1047,server=y,suspend=n"
export HADOOP_TASKTRACKER_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=1048,server=y,suspend=n"
export HBASE_MASTER_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=1049,server=y,suspend=n"
export HBASE_REGIONSERVER_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=1050,server=y,suspend=n"
export ZOOKEEPER_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=1052,server=y,suspend=n"

alias hadoop='$HOME/hadoop/bin/hadoop'
alias hdfs='$HOME/hadoop/bin/hdfs'
alias mapred='$HOME/hadoop/bin/mapred'
alias hbase='$HOME/hbase/bin/hbase'
alias zk='$HOME/zookeeper/bin/zkCli.sh'

# functions
function ps? {
  idx=0
  for i in $*; do
    grepstr=[${i:0:1}]${i:1:${#i}}
    tmp=`ps axwww | grep $grepstr | awk '{print $1}'`
    echo "${i}: ${tmp/\\n/,}"
  done
}
