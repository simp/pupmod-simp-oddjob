# class oddjob::mkhomedir
#
# This configures the oddjob-mkhomedir
#
# @param umask
#
# @param package_ensure The ensure status of packages to be managed
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
class oddjob::mkhomedir (
  Simplib::Umask $umask          = '0027',
  String         $package_ensure = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })
) {
  validate_umask($umask)

  include 'oddjob'

  package { 'oddjob-mkhomedir':
    ensure => $package_ensure
  }

  file { '/etc/oddjobd.conf.d/oddjobd-mkhomedir.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['oddjobd'],
    content => template('oddjob/etc/oddjobd.conf.d/oddjobd-mkhomedir.conf.erb')
  }
}
