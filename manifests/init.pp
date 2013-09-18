class play (
  $mysql_root_password = 'foo',
  $music_directory = '/opt/music',
  $play_user = $title,
) {

  stage { 'first':
    before => Stage["main"],
  }

  #class update_os {
  #  case $::osfamily {
  #    Linux, redhat: {
  #    }
  #    debian, ubuntu: {
  #      class { "apt":
  #        always_apt_update => true,
  #        stage => 'first',
  #      }
  #    }
  #  }
  #}

  class prepare_server {
    class { 'apt':
      always_apt_update => true,
    }
  }

  class { 'prepare_server':
    stage => 'first',
  }

  class { "mysql::server":
      config_hash => { 
        "root_password" => "$mysql_root_password",
      }
  }

  define play_user (
      $play_user = $title
    ) {
    user { "${play_user}":
      ensure     => "present",
      comment    => "Muzica User",
      shell      => '/bin/bash',
      password   => ':$6$3OVGSiJe$emh3DDGX4gBfRF641hi5FX5v3LLXtIHBF77LEfnimpnoKmUQfYKDMA5a9DeQOt5aDSwz5xL3NziZnN/f8C/sT1',
      managehome => true,
    }

    file { "/opt/music":
      ensure => "directory",
      owner => "${play_user}",
      group => "${play_user}",
      mode => "0777",
    }

    vcsrepo { "/home/${play_user}/play":
      ensure   => "latest",
      user => "${play_user}",
      provider => "git",
      source   => "git://github.com/play/play.git",
      revision => "v3",
      require => User["${play_user}"],
    }
    file { "play.yml":
      path    => "/home/${play_user}/play/config/play.yml",
      owner   => "${play_user}",
      group   => "${play_user}",
      mode    => "0644",
      require => Vcsrepo["/home/${play_user}/play"],
      content => template("play/play.yml.erb"),
    }
    file { "mpd.conf":
      path    => "/home/${play_user}/play/config/mpd.conf",
      owner   => "${play_user}",
      group   => "${play_user}",
      mode    => "0644",
      require => Vcsrepo["/home/${play_user}/play"],
      content => template("play/mpd.conf.erb"),
    }
    rbenv::install { "${play_user}":
      home    => "/home/${play_user}",
      require => Class['apt'],
    }
    rbenv::compile { "ruby 2.0":
      ruby    => "2.0.0-p195",
      user    => "${play_user}",
      global  => true,
      require => Rbenv::Install["${play_user}"],
    }
  }

  play_user { "${play_user}": }
}
