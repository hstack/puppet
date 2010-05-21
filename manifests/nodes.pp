# nodes.pp
#
# module imports
import "mon"
import "grinder"
import "gitorious"
import "hbase"
import "hbase/services"

import "hadoop"
import "hadoop/services"

import "zookeeper"
import "zookeeper/services"

import "high-availability/drbd"
import "high-availability/drbd-primary"
import "high-availability/heartbeat"


# puppet roles for different servers
# zookeeper - server participating in a zookeeper quporum
# namenode - hadoop namenode. Will be setup with the hadoop namenode configuration and drbd / ha recipe for namenode failover
# datanode - hadoop datanode
# jobtracker - hadoop jobtracker
# tasktracker - hadoop tasktracker
# hbasemaster - hbase master server
# hbaseregion - hbase regionserver

class drbd-base {
    $virtual_ip = "192.168.1.1/24"
    $resource_name = "r0"
    $hostname_primary="server1"
    $disk_dev_primary="/dev/sda2"
    $ip_primary="192.168.1.12"

    $hostname_secondary="server2"
    $disk_dev_secondary="/dev/sda2"
    $ip_secondary="192.168.1.13"
    
    $hadoop_namenode_dir="/var/hadoop-namenode"
    include drbd
    include heartbeat
    include mon
}

# LA based machines

node base {
  include jdk
  include virtual_users, virtual_groups
  realize(Group["hadoop"], User["hadoop"])
  $user="hadoop"
  $group="hadoop"  
  $hadoop_namenode_dir = "/var/hadoop_namenode/"
  $hadoop_default_fs_name = "hdfs://server0:9000/"
  $hadoop_datastore = ["/mnt/data_1/hadoop_data/", "/mnt/data_2/hadoop_data/"]
  $mapred_job_tracker = "server0:9001"
  $hadoop_mapred_local = ["/mnt/data_1/hadoop_mapred_local/", "/mnt/data_2/hadoop_mapred_local/"]
  $environment="production"
  $hadoop_home="/home/hadoop/hadoop"
  $hadoop_from_source = false
  $hbase_home="/home/hadoop/hbase"
  $hbase_from_source = false
  $zookeeper_home="/home/hadoop/zookeeper"
  $zookeeper_from_source = false
  include environment
}


class hadoop {
    $hadoop_version="core-0.21.0-31"
    $hadoop_parent_dir="/home/hadoop"
    include hadoop
    include hadoop-jmx-metrics
}

class hbase {
    $hbase_version="0.21.0-38"
    $zookeeper_quorum = "l2,l3,l4,l5,l6,l7"
    $hbase_rootdir = "hdfs://l0:9000/hbase"
    $hbase_parent_dir = "/home/hadoop"
    include hbase
    include hbase-snmp-metrics
}

class zookeeper {
    $zookeeper_version = "3.2.1"
    $zookeeper_parent_dir = "/home/hadoop"
    $zookeeper_datastore = "/var/zookeeper_datastore"
    $zookeeper_datastore_log = "/var/zookeeper_datastore_log"
    include zookeeper
}

node "server1" extends base {
  include drbd
  include drbd-primary
  include hadoop
  include hbase
  include zookeeper
  $zookeeper_myid = "2"  

  include services::datanode
  include services::hbase-master
  include services::hbase-regionserver
  include services::tasktracke
  include services::zookeeper
  include services::tasktracker
  }
