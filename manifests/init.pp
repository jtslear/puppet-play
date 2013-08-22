class play {
  class { "apt": 
    always_apt_update => true,
    before => Class["mysql"],
  }
  class { "mysql": 
    require => Class["apt"],
  }

  Class["apt"] -> Class["mysql"]
}
