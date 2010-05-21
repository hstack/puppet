#
# Miscellaneous puppet defines not substantial enough to warrant a module.
#

#
# Manipulate a line in a file.
#
define line($file, $line, $ensure = 'present') {
   case $ensure {
      default : { err ( "unknown ensure value ${ensure}" ) }
      present: {
         exec { "/bin/echo '${line}' >> '${file}'":
            command => "/bin/echo '${line}' >> '${file}'",
            unless => "/bin/grep -qFx '${line}' '${file}'"
         }
      }
      absent: {
         exec { "/usr/bin/perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'":
            command => "/usr/bin/perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'",
            onlyif => "/bin/grep -qFx '${line}' '${file}'"
         }
      }
   }
}


#
# Pull a file from elsewhere not using puppet://...
#
 define download_file(
         $site="",
         $cwd="",
         $unless="",
         $timeout = 300) {

     exec { $name:
         command => "wget ${site} -O ${name}",
         cwd => $cwd,
         creates => "${cwd}/${name}",
         timeout => $timeout,
         unless => $unless
     }

 }



define firewall_port( $port, $protocol = "tcp" ) {

  exec { "open_port_${port}_${protocol}":
    command => "system-config-securitylevel-tui --quiet --port=${port}:${protocol}",
    unless => "grep -q ' -p ${protocol} --dport ${port} -j ACCEPT' /etc/sysconfig/iptables"
  }

}
