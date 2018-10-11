# This class ensures that the basic oddjobd service is running and
# provides for an entry point to other oddjob functions and
# configuration.
#
# @param package_ensure The ensure status of packages to be managed
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
class oddjob (
  String $package_ensure = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })
) {

  package { 'oddjob':
    ensure => $package_ensure
  }

  service { 'oddjobd':
    ensure  => 'running',
    enable  => true,
    require => Package['oddjob']
  }
}
