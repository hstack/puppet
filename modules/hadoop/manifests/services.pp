class services {
  # do nothing, magic lookup helper
}

class services::namenode {
    service { "hadoop-namenode":
        ensure => running,
        enable => true,
        require => [File["hadoop-namenode-service"], File["$hadoop_home"]]
    }
}

class services::secondarynamenode {
    service { "hadoop-secondarynamenode":
        ensure => running,
        enable => true,
        require => [File["hadoop-secondarynamenode-service"], File["$hadoop_home"]]
    }
}

class services::datanode {
    service { "hadoop-datanode":
        ensure => running,
        enable => true,
        require => [File["hadoop-datanode-service"], File["$hadoop_home"]]
    }
}

class services::jobtracker {
    service { "hadoop-jobtracker":
        ensure => running,
        enable => true,
        require => [File["hadoop-jobtracker-service"], File["$hadoop_home"]]
    }
}

class services::tasktracker {
    service { "hadoop-tasktracker":
        ensure => running,
        enable => true,
        require => [File["hadoop-tasktracker-service"], File["$hadoop_home"]]
    }
}

