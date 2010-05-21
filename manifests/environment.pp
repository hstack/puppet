class environment {
    $java_home= $operatingsystem ?{
        Darwin => "/System/Library/Frameworks/JavaVM.framework/Versions/1.6.0/Home/",
        redhat => "/usr/java/latest",
        CentOS => "/usr/java/latest",
        default => "/usr/lib/jvm/java-6-sun",
    }

    if $operatingsystem != Darwin {
      
        file { "hstack_environment":
            path => "/etc/profile.d/hstack_profile.sh",
            content => template("environment/etc/profile.d/hstack_options.sh"),
            ensure => file,
            owner => "root",
            group => "root",
            mode => 755
        }
        
        file {"tmpwatch":
          path => "/etc/cron.daily/tmpwatch",
          content => template("environment/etc/cron.daily/tmpwatch"),
          ensure => file,
          owner => "root",
          group => "root",
          mode => 755,
        }
    }

  line {"upgrade_system_limit":
    file => "/etc/security/limits.conf",
    line => "hadoop   hard    nofile    200000",
    ensure => present,
  }    
}
