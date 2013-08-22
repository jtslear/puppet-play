# == Class: play
#
# This will install the play server
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
# John T Skarbek <jtslear@gmail.com>
#
# === Copyright
#
# Take this code, I don't care
#
class play (
  $mysql_root_password = 'foo',
  $music_directory = '/opt/music',
) inherits play::params {

  class { "apt": 
    always_apt_update => true,
    before => Class["mysql"],
  }
  class { "mysql": 
    require => Class["apt"],
  }

  Class["apt"] -> Class["mysql"]
}
