# Class: mon
#
# This module manages mon
#
# Parameters:
#	  $mon_home - where to copy mon files
#		  default: /usr/lib/mon
#	  $mon_log_dir - where to store the mon log files
#	  	default: /var/log/mon
# Actions:
#   deploy mon files
#   deploy custom alert and action script
# Requires:
#
# Sample Usage:
# include mon

# mon.pp - Monitors NameNode and forces failover
# http://mon.wiki.kernel.org/index.php/
# depends:

class mon {

	$default_mon_home = "/usr/lib/mon"
	$default_mon_log_dir = "/var/log/mon"
	
	if $mon_home {
		$mon_home = $mon_home
	} else {
		$mon_home = $default_mon_home	
	}

	if $mon_log_dir {
		$mon_log_dir = $mon_log_dir
	} else {
		$mon_log_dir = $default_mon_log_dir
	}

	notify {"mon_home_stats":
		message => "MON_HOME IS: $mon_home",
	}
	
	download_file {"mon-1.2.0.tar.gz":
		site => "ftp://ftp.kernel.org/pub/software/admin/mon/mon-1.2.0.tar.gz",
		cwd => "/root/",
	}

	# file {"/root/mon-1.2.0.tar.gz":
	# 	source => "puppet:///mon/mon-1.2.0.tar.gz",
	# 	owner => "root",
	# 	group => "root",	
	# }
	
	exec {"untar_mon":
		command => "tar -xzf mon-1.2.0.tar.gz",
		cwd => "/root/",
		unless => "ls ${mon_home}",
		require => Download_file["mon-1.2.0.tar.gz"],
	}
	
	exec {"move_to_home":
		command => "mv mon-1.2.0 ${mon_home}",
		cwd => "/root/",
		creates => "${mon_home}",
		require => Exec["untar_mon"],	
	}
	
	file {"/etc/init.d/mon":
		content => template("mon/service/mon.erb"),
		mode => 755,
		owner => "root",
		group => "root",
	}
	
	include mon::dependencies

	include mon::addons
	include mon::config
	
}

class mon::addons {

	file {"${mon_home}/alert.d/stopha.alert":
		source => "puppet:///mon/alert.d/stopha.alert",
		mode => 755,
		owner => "root",
		group => "root",
		require => Exec["move_to_home"],
	}
	
	file { "${mon_home}/mon.d/ps.monitor":
		source => "puppet:///mon/mon.d/ps.monitor",
		mode => 755,
		owner => "root",
		group => "root",
		require => Exec["move_to_home"],		
	}
}

class mon::config {

	file {"${mon_home}/conf":
		ensure => directory,
		owner => root,
		group => root,
		require => Exec["move_to_home"],
	}
	
	file {"$mon_log_dir":
		ensure => directory,
		owner => "root",
		group => "root",
	}
	
	file {"${mon_home}/conf/auth.cf":
		content => template("mon/conf/auth.cf"),
		mode => 600,
		owner => "root",
		group => "root",
		require => File["${mon_home}/conf"],
	}
	
	file {"${mon_home}/conf/mon.cf":
		content => template("mon/conf/mon.cf.erb"),
		owner => "root",
		group => "root",
		require => File["${mon_home}/conf"],		
	}
}


class mon::dependencies {

	package {"perl": ensure => installed}
	package {"gcc": ensure => installed}
	
	download_file { "Proc-ProcessTable-0.45.tar.gz":
		site => "http://search.cpan.org/CPAN/authors/id/D/DU/DURIST/Proc-ProcessTable-0.45.tar.gz",
		cwd => "/root/",
	}
	
	exec {"untar_proc_processtable":
		command => "tar -xzf Proc-ProcessTable-0.45.tar.gz",
		cwd => "/root",
		creates => "/root/Proc-ProcessTable-0.45",
		require => Download_file["Proc-ProcessTable-0.45.tar.gz"],
	}
	
	exec {"install_proc_processtable":
		command => "perl Makefile.PL && make && make install",
		cwd => "/root/Proc-ProcessTable-0.45",
		require => [Package["perl"], Package["gcc"], Exec["untar_proc_processtable"]],
	}
	
	download_file { "Period-1.20.tar.gz":
		site => "http://search.cpan.org/CPAN/authors/id/P/PR/PRYAN/Period-1.20.tar.gz",
		cwd => "/root/",
	}

	exec {"untar_time_period":
		command => "tar -xzf Period-1.20.tar.gz",
		cwd => "/root",
		creates => "/root/Period-1.20",
		require => Download_file["Period-1.20.tar.gz"],
	}
	
	exec {"install_time_period":
		command => "perl Makefile.PL && make && make install",
		cwd => "/root/Period-1.20",
		require => [Package["perl"], Package["gcc"], Exec["untar_time_period"]],
	}
	
}
