# Class: hadoop
#
# This module manages hadoop
#
# Parameters:
#   $environment=dev|stage|production - used to read different conf files
#   $hadoop_home: home of hadoop (e.g. /home/hadoop)
#   $hadoop_version = version of Hadoop to deploy
#   $hadoop_parent_dir = location of the hadoop folder parent - where to extract the variables, create symlinks, etc
#   $hadoop_datastore = list of mount points to be used for the datanodes
#   $hadoop_namenode_dir = dfs.name.dir value
#   $hadoop_default_fs_name - htdfs://host:port/
#   $mapred_job_tracker - url for the jobtracker (host:port)
#
# Actions:
#  get archive, untar, symlink
#  configure hadoop
#  deploy init.d services
#
# Requires:
#  CentOS / MacOSX
#
# Sample Usage:
#
#  $hadoop_home=/home/hadoop/hadoop
#  $hadoop_datastore=["/var/hadoop_datastore", "/mnt/hadoop_store_2"]
#  $hadoop_version=0.21.0-SNAPSHOT
#  $hadoop_parent_dir=/home/hadoop
#  $hadoop_default_fs_name=hdfs://namenode:9000
#  
#  include hadoop
#  include services::hadoop-namenode
class hadoop {

    # get files
    file { "hadoop-${hadoop_version}.tar.gz":
      path => "${hadoop_parent_dir}/hadoop-${hadoop_version}.tar.gz",
      source => "puppet:///repo/hadoop-${hadoop_version}.tar.gz",
      backup => false,
      owner => "root",
      group => "root",
    }
    
    exec { "hadoop_untar":
        command => "tar xzf hadoop-${hadoop_version}.tar.gz; chown -R ${user}:${group} /home/hadoop/hadoop-${hadoop_version}",
        cwd => "${hadoop_parent_dir}/",
        require => File["hadoop-${hadoop_version}.tar.gz"],
        creates => "${hadoop_parent_dir}/hadoop-${hadoop_version}",
    }

    file { "hadoop-reown-build":
        path => "${hadoop_parent_dir}/hadoop-${hadoop_version}",
        backup => false,
        recurse => true,
        owner => $user,
        group => $group,
        require => Exec["hadoop_untar"],
    }

    file { "$hadoop_home":
        target => "${hadoop_parent_dir}/hadoop-${hadoop_version}", 
        backup => false,
        ensure => symlink, 
        require => File["hadoop-reown-build"],
        owner => $user,
        group => $group,
    }

    file { "$hadoop_home/pids":
        path =>"$hadoop_home/pids",
        backup => false,
        ensure => directory,
        owner => $user,
        group => $group,
        mode => 644,
        require => File["$hadoop_home"]
    }            

    file { $hadoop_datastore:
        backup => false,
        ensure => directory,
        owner => $user,
        group => $group,
        mode => 644,
    }
    
    file { "/var/hadoop_namenode":
        backup => false,
        ensure => directory,
        owner => $user,
        group => $group,
        mode => 644,
    }        
    
    #define logging paths
    $log_path = $operatingsystem ? {
        Darwin   => "/Users/$user/Library/Logs/hadoop/",
        default => "/var/log/hadoop/",
    }

    include hadoop::copy_conf
    include hadoop::copy_services
}

class hadoop::copy_conf {
    #put the HDFS configuration
    file { "hdfs-site-xml":
        path => "${hadoop_home}/conf/hdfs-site.xml",
        content => template("hadoop/conf/${environment}/hdfs-site.xml.erb"),
        owner => $user,
        group => $group,
        mode => 644,
        ensure => file,
        require => File["$hadoop_home"], 
    }

    file { "core-site-xml":
        path => "${hadoop_home}/conf/core-site.xml",
        content => template("hadoop/conf/${environment}/core-site.xml.erb"),
        owner => $user,
        group => $group,
        mode => 644,
        ensure => file,
        require => File["$hadoop_home"], 
    }

    file { "mapred-site-xml":
        path => "${hadoop_home}/conf/mapred-site.xml",
        content => template("hadoop/conf/${environment}/mapred-site.xml.erb"),
        owner => $user,
        group => $group,
        mode => 644,
        ensure => file,
        require => File["$hadoop_home"], 
    }

    $java_home= $operatingsystem ?{
        Darwin => "/System/Library/Frameworks/JavaVM.framework/Versions/1.6.0/Home/",
        redhat => "/usr/java/latest",
        CentOS => "/usr/java/latest",
        default => "/usr/lib/jvm/java-6-sun",
    }
    
    file { "hadoop-env":
        path => "${hadoop_home}/conf/hadoop-env.sh",
        content => template("hadoop/conf/${environment}/hadoop-env.sh.erb"),
        owner => $user,
        group => $group,
        mode => 644,
        ensure => file,
        require => File["$hadoop_home"], 
    }    

    file { "hadoop_log_folder":
        path => $log_path, 
        owner => $user,
        group => $group,
        mode => 644,
        ensure => directory, 
        require => File["$hadoop_home"], 
    }

    file { "hadoop_log4j":
        path => "$hadoop_home/conf/log4j.properties",
        owner => $user,
        group => $group,
        mode => 644,
        content => template("hadoop/conf/${environment}/log4j.properties.erb"), 
        require => File["$hadoop_home"], 
    }

    file {"hadoop_masters":
        path => "$hadoop_home/conf/masters",
        owner => $user,
        group => $group,
        mode => 644,
        content => template("hadoop/conf/${environment}/masters.erb"),         
        require => File["$hadoop_home"], 
    }

    file {"hadoop_slaves":
        path => "$hadoop_home/conf/slaves",
        owner => $user,
        group => $group,
        mode => 644,
        content => template("hadoop/conf/${environment}/slaves.erb"),         
        require => File["$hadoop_home"], 
    }
}

class hadoop::copy_services {
    #install the hadoop services
    $init_d_path = $operatingsystem ?{
        Darwin => "/usr/bin/hadoop_service", #"/Users/${user}/Library/LaunchAgents/hadoop.launchd",
        default => "/etc/init.d/hadoop",
    }

    $init_d_template = $operatingsystem ?{
        Darwin => "hadoop/service/hadoop_service.erb", #"hadoop/service/hadoop.launchd.erb",
        default => "hadoop/service/hadoop.erb",
    }

    file { "hadoop-start-all-service":
        path => $init_d_path,
        content => template($init_d_template),
        ensure => file,
        owner => $user,
        group => $group,
        mode => 755
    }

    if $operatingsystem != Darwin {
        $os = $operatingsystem? {
            Ubuntu => "ubuntu",
            Debian => "ubuntu",
            default => "redhat",
        }

        file { "hadoop-namenode-service":
            path => "/etc/init.d/hadoop-namenode",
            content => template("hadoop/service/${os}/hadoop-namenode.erb"),
            ensure => file,
            owner => "root",
            group => "root",
            mode => 755
        }

        file { "hadoop-datanode-service":
            path => "/etc/init.d/hadoop-datanode",
            content => template("hadoop/service/${os}/hadoop-datanode.erb"),
            ensure => file,
            owner => "root",
            group => "root",
            mode => 755
        }    

        file { "hadoop-secondarynamenode-service":
            path => "/etc/init.d/hadoop-secondarynamenode",
            content => template("hadoop/service/${os}/hadoop-secondarynamenode.erb"),
            ensure => file,
            owner => "root",
            group => "root",
            mode => 755
        }

        file { "hadoop-jobtracker-service":
            path => "/etc/init.d/hadoop-jobtracker",
            content => template("hadoop/service/${os}/hadoop-jobtracker.erb"),
            ensure => file,
            owner => "root",
            group => "root",
            mode => 755
        }    

        file { "hadoop-tasktracker-service":
            path => "/etc/init.d/hadoop-tasktracker",
            content => template("hadoop/service/${os}/hadoop-tasktracker.erb"),
            ensure => file,
            owner => "root",
            group => "root",
            mode => 755
        }
    }
}

