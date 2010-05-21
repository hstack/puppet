# drbd-primary.pp
#

class drbd-primary {

    exec {"initialize_primary":
        command => "drbdadm -- --overwrite-data-of-peer primary $resource_name",
        cwd => "/root",
        refreshonly => "true",
        subscribe => Service["drbd"],

    }

    exec {"mkfs":
        command => "mkfs.ext3 /dev/drbd0",
        cwd => "/root",
        refreshonly => true,
        subscribe => Exec["initialize_primary"],
    }
}
