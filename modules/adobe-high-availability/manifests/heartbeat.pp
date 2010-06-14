# Class: heartbeat
#
# This module manages heartbeat
#
# Parameters:
#   $hostname[primary|secondary]
# Actions:
#   deploy heartbeat
#   configure heartbeat from templates
# Requires:
#   the two machines' details: hostnames, ips
# Sample Usage:
#   include heartbeat
class heartbeat {

    package { "heartbeat": 
        ensure => installed,
        require => Service["drbd"],
        }

    service { "heartbeat":
        # name of the init script?
        name => heartbeat,
        ensure => running,
        hasstatus => true,
        enable => true
    }


    file { "/etc/ha.d/ha.cf":
        mode => 444, 
        content => template("heartbeat/ha.cf.erb"),
        require => Package["heartbeat"],
        notify => Service["heartbeat"];
    }

    file { "/etc/ha.d/haresources":
        mode => 644,
        content => template("heartbeat/haresources.erb"),
        require => Package["heartbeat"],
        notify => Service["heartbeat"];
    }

    file { "/etc/ha.d/authkeys":
        mode => 400, 
        content => template("heartbeat/authkeys"),
        require => Package["heartbeat"],
        notify => Service["heartbeat"];
    }
}

