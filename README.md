[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/oddjob.svg)](https://forge.puppetlabs.com/simp/oddjob)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/oddjob.svg)](https://forge.puppetlabs.com/simp/oddjob)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-oddjob.svg)](https://travis-ci.org/simp/pupmod-simp-oddjob)

# oddjob

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [Module Description](#module-description)
* [Setup](#setup)
  * [What oddjob affects](#what-oddjob-affects)
  * [Setup Requirements](#setup-requirements)
  * [Beginning with oddjob](#beginning-with-oddjob)
* [Usage](#usage)
  * [I want to set default user umask for home directories](#i-want-to-set-default-user-umask-for-home-directories)
* [Limitations](#limitations)
* [Development](#development)
* [Acceptance tests](#acceptance-tests)

<!-- vim-markdown-toc -->

## Module Description

This module ensures the oddjobd package is installed, service is running and
configures oddjob-mkhomedir.

See [REFERENCE.md](./REFERENCE.md) for API details.

## Setup

### What oddjob affects

This module will ensure oddjob is installed and the service is running.
Additionally, it will use a custom template to create the mkhomedir oddjob
enforcing umask.

### Setup Requirements

`simp/oddjob` requires `simp/simplib` if using the mkhomedir class.

### Beginning with oddjob

```puppet
include 'oddjob'
```

## Usage

### I want to set default user umask for home directories

```puppet
include 'oddjob'
include 'oddjob::mkhomdir'
```

With Hieradata:

```yaml
oddjob::mkhomedir::umask: '0077'
```

## Limitations

SIMP Puppet modules are generally intended to be used on a Red Hat Enterprise
Linux-compatible distribution.

## Development

Please read our [Contribution Guide](https://simp.readthedocs.io/en/stable/contributors_guide/index.html).

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net).

## Acceptance tests

To run the system tests, you need `Vagrant` installed.

You can then run the following to execute the acceptance tests:

```shell
   bundle exec rake beaker:suites
```

Some environment variables may be useful:

```shell
   BEAKER_debug=true
   BEAKER_provision=no
   BEAKER_destroy=no
   BEAKER_use_fixtures_dir_for_modules=yes
```

*  ``BEAKER_debug``: show the commands being run on the STU and their output.
*  ``BEAKER_destroy=no``: prevent the machine destruction after the tests
   finish so you can inspect the state.
*  ``BEAKER_provision=no``: prevent the machine from being recreated.  This can
   save a lot of time while you're writing the tests.
*  ``BEAKER_use_fixtures_dir_for_modules=yes``: cause all module dependencies
   to be loaded from the ``spec/fixtures/modules`` directory, based on the
   contents of ``.fixtures.yml``. The contents of this directory are usually
   populated by ``bundle exec rake spec_prep``. This can be used to run
   acceptance tests to run on isolated networks.
