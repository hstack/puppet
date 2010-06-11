class services {
  # do nothing; magic auto-lookup helper
}

class services::zookeeper {
    service { "zookeeper-server":
        ensure => running,
        enable => true,
        hasstatus => false,
        pattern => "QuorumPeerMain",
        require => [File["zookeeper-server-service"], File["$zookeeper_home"]]
    }
}

class services::zookeeper_all {
    if $operatingsystem != Darwin {
        service {"zookeeper":
            ensure => running,
            enable => false,
            hasstatus => false,
            pattern => "QuorumPeerMain",
        }
    } else {
        exec { "zookeeper_service":
            command => "zookeper_service start",
            cwd => "/usr/bin/",
        }

    }
}
