class zookeeper {
  # get files
  file {"zookeeper-${zookeeper_version}.tar.gz":
    path => "${zookeeper_parent_dir}/zookeeper-${zookeeper_version}.tar.gz",
    source => "puppet:///repo/zookeeper-${zookeeper_version}.tar.gz",
    owner => "$user",
    group => "$user",
    require => [],
    backup => false,
  }

  exec { "zookeeper_untar":
    command => "tar xzf zookeeper-${zookeeper_version}.tar.gz;",
    cwd => "${zookeeper_parent_dir}",
    require => File["zookeeper-${zookeeper_version}.tar.gz"],
    creates => "${zookeeper_parent_dir}/zookeeper-${zookeeper_version}",
  }

  file { "zookeeper-reown-build":
    path => "${zookeeper_parent_dir}/zookeeper-${zookeeper_version}",
    recurse => true,
    owner => $user,
    group => $group,
    require => Exec["zookeeper_untar"],
    backup => false,
  }

  file { "$zookeeper_home":
    target => "${zookeeper_parent_dir}/zookeeper-${zookeeper_version}", 
    ensure => symlink, 
    require => File["zookeeper-reown-build"],
    owner => $user,
    group => $group,
    backup => false,
  }

  $log_path = $operatingsystem ? {
    Darwin   => "/Users/$user/Library/Logs/zookeeper/",
    default => "/var/log/zookeeper",
  }

  file { "zookeeper_log_folder":
    path => $log_path, 
    owner => $user,
    group => $group,
    mode => 644,
    ensure => directory,
    backup => false, 
  }

  file { "zookeeper_datastore":
    path => "${zookeeper_datastore}", 
    ensure => directory, 
    owner => $user,
    group => $group,
    mode => 644, 
    backup => false,
  }

  file { "zookeeper_datastore_myid":
    path => "${zookeeper_datastore}/myid", 
    ensure => file, 
    content => template("zookeeper/conf/${environment}/myid.erb"), 
    owner => $user,
    group => $group,
    mode => 644, 
    backup => false,
  }

  file { "zookeeper_datastore_log":
    path => "${zookeeper_datastore_log}", 
    ensure => directory, 
    owner => $user,
    group => $group,
    mode => 644, 
    backup => false,
  }

  include zookeeper::copy_conf
  include zookeeper::copy_services

}

class zookeeper::copy_conf {

  file { "conf/zoo.cfg":
    path => "$zookeeper_home/conf/zoo.cfg",
    owner => $user,
    group => $group,
    mode => 644,
    content => template("zookeeper/conf/${environment}/zoo.cfg.erb"), 
    require => File["$zookeeper_home"], 
  }

  file { "zookeeper_java.env":
    path => "$zookeeper_home/conf/java.env",
    owner => $user,
    group => $group,
    mode => 644,
    content => template("zookeeper/conf/${environment}/java.env.erb"), 
    require => File["$zookeeper_home"], 
  }

  file { "zookeeper_log4j":
    path => "$zookeeper_home/conf/log4j.properties",
    owner => $user,
    group => $group,
    mode => 644,
    content => template("zookeeper/conf/${environment}/log4j.properties.erb"), 
    require => File["$zookeeper_home"], 
  }
}

class zookeeper::copy_services {
  if $operatingsystem != Darwin {
    file { "zookeeper-server-service":
      path => "/etc/init.d/zookeeper-server",
      content => template("zookeeper/service/zookeeper-server.erb"),
      ensure => file,
      owner => "root",
      group => "root",
      mode => 755
    }
  }
}

class zookeeper::copy_dev_services {
  $init_d_path = $operatingsystem ?{
    Darwin => "/usr/bin/zookeeper_service",
    default => "/etc/init.d/zookeeper",
  }

  $init_d_template = $operatingsystem ?{
    Darwin => "zookeeper/service/zookeeper_service.erb",
    default => "zookeeper/service/zookeeper.erb",
  }

  file { "zookeeper-init-service":
    path => $init_d_path,
    content => template($init_d_template),
    ensure => file,
    owner => $user,
    group => $group,
    mode => 755
  }
}

