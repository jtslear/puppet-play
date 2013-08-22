# == Class: play
#
# Full description of class play here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { play:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class play (
  $mysql_root_password = 'foo',
  $music_directory = '/opt/music',
) {

  stage { 'first':
    before => Stage["main"],
  }

  class { "apt":
    always_apt_update => true,
    stage             => first,
  }

  class { "mysql::server":
      config_hash => { 
        "root_password" => "$mysql_root_password",
      }
  }

  package { [
      "git",
    ]:
    ensure  => "present",
  }

  define play_user {
    user { "${name}":
      ensure => "present",
      comment => "Muzica User",
      managehome => true,
    }

    file { "/opt/music":
      ensure => "directory",
      owner => "${name}",
      group => "${name}",
      mode => "0777",
    }

    vcsrepo { "/home/${name}/play":
      ensure   => "latest",
      user => "${name}",
      provider => "git",
      source   => "git://github.com/play/play.git",
      revision => "v3",
      require => User["${name}"],
    }
    file { "play.yml":
      path    => "/home/${name}/play/config/play.yml",
      owner   => "${name}",
      group   => "${name}",
      mode    => "0644",
      require => Vcsrepo["/home/${name}/play"],
      content => template("play/play.yml.erb"),
    }
    file { "mpd.conf":
      path    => "/home/${name}/play/config/mpd.conf",
      owner   => "${name}",
      group   => "${name}",
      mode    => "0644",
      require => Vcsrepo["/home/${name}/play"],
      content => template("play/mpd.conf.erb"),
    }
    rbenv::install { "${name}":
      home    => "/home/${name}",
      require => User["${name}"],
    }
    rbenv::compile { "2.0.0-p247":
      user   => "${name}",
      home   => "/home/${name}",
      global => true,
    }
  }

  play_user { "muzak": }
}
