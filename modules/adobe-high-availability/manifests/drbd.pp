# Class: drbd
#
# This module manages drbd
#
# Parameters:
#   $hadoop_namenode_dir
#   $hostname[primary|secondary]
# Actions:
#   initialize a drbd partition
#   formats a drbd partition
# Requires:
#   the partition to be used as rbd should not contain a filesystem
#   otherwise you need to zero-it out
# Sample Usage:
#   include drbd-primary
class drbd {

    #package {"drbd": ensure => installed}


    case $operatingsystem {
        redhat:  {
            package {"kmod-drbd82.": ensure => installed}
        }
    }

    $drbd_pkg = $operatingsystem? {
        ubuntu => "drbd8-utils",
        default => "drbd82.",
    }

    package {"drbd": 
        name => $drbd_pkg,
        ensure => installed,
    }

    package {"kmod-drbd82.":
        ensure => installed,
        require => Package["drbd"]
    }

    file {"drbd.conf":
        path => "/etc/drbd.conf",
        content => template("drbd/drbd.conf.erb"),
        ensure => present,
        require => Package["drbd"],
    }

    exec { "mount-hadoop-namenode-partition":
        command => " echo \"/dev/drbd0 $hadoop_namenode_dir     ext3     defaults,noauto     0 0\" >> /etc/fstab",
        unless => "grep $hadoop_namenode_dir /etc/fstab"
    }

    exec {"create_resource":
        command => "yes yes| drbdadm create-md r0",
        require => Exec["mount-hadoop-namenode-partition"],
        unless => "drbdadm sh-resource r0",
    }

    service { "drbd":
        ensure => running,
        require => Exec["create_resource"],
        enable => true,
    }

}
