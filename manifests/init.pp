# == Class: oddjob
#
# This class ensures that the basic oddjobd service is running and
# provides for an entry point to other oddjob functions and
# configuration.
#
# == Parameters
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class oddjob {
  package { 'oddjob': ensure => 'latest' }

  service { 'oddjobd':
    ensure  => 'running',
    enable  => true,
    require => Package['oddjob']
  }
}
