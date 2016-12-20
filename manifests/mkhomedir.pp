# class oddjob::mkhomedir
#
# This configures the oddjob-mkhomedir
#
# @param umask
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
class oddjob::mkhomedir (
  Simplib::Umask $umask = '0027'
) {
  validate_umask($umask)

  include 'oddjob'

  package { 'oddjob-mkhomedir': ensure => 'latest' }

  file { '/etc/oddjobd.conf.d/oddjobd-mkhomedir.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['oddjobd'],
    content => template('oddjob/etc/oddjobd.conf.d/oddjobd-mkhomedir.conf.erb')
  }
}
